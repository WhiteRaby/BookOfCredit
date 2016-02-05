//
//  BOCCreditsViewController.m
//  BookOfCredit
//
//  Created by Alexandr on 04.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

#import "BOCDebtorsViewController.h"
#import <CoreData/CoreData.h>
#import "BOCDataManager.h"
#import "BOCDebtor.h"
#import "BOCDebtorDetailViewController.h"

@interface BOCDebtorsViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation BOCDebtorsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*BOCDebtor *debtor1 = [NSEntityDescription insertNewObjectForEntityForName:@"BOCDebtor"
                                                       inManagedObjectContext:[self managedObjectContext]];
    debtor1.firstName = @"Sasha";
    
    BOCDebtor *debtor2 = [NSEntityDescription insertNewObjectForEntityForName:@"BOCDebtor"
                                                       inManagedObjectContext:[self managedObjectContext]];
    debtor2.firstName = @"John";
    
    [self.managedObjectContext save:nil];*/
    
    
}

#pragma mark - Action Methods

- (IBAction)actionAddDebtor:(id)sender {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"Создание нового Должника"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Имя";
         textField.font = [UIFont systemFontOfSize:18];
         textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Фамилия (не обязательно)";
         textField.font = [UIFont systemFontOfSize:18];
         textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
     }];
    
    
    __weak UIAlertController *weakAlertController = alertController;
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Отмена"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Сохранить"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSString *firstName = [[[weakAlertController textFields] objectAtIndex:0] text];
                                   NSString *lastName = [[[weakAlertController textFields] objectAtIndex:1] text];
                                   if (![firstName isEqualToString:@""]) {
                                       [self createDebtorWithFirstName:firstName andLastName:lastName];
                                   }
                               }];
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)createDebtorWithFirstName:(NSString*)firstName andLastName:(NSString*)lastName {
    
    BOCDebtor *debtor1 =
        [NSEntityDescription insertNewObjectForEntityForName:@"BOCDebtor"
                                      inManagedObjectContext:[self managedObjectContext]];
    debtor1.firstName = firstName;
    debtor1.lastName = lastName;
    [self.managedObjectContext save:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:0.9f green:1.f blue:0.9f alpha:1.f];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //[self performSegueWithIdentifier:@"DebtorDetailSegue" sender:self];
    //BOCDebtorDetailViewController *vc = [[BOCDebtorDetailViewController alloc] init];
    BOCDebtorDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DebtorDetail"];
    vc.debtor = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:vc animated:YES];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"Удалить";
}


#pragma mark - UITableView

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BOCDebtor *debtor = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", debtor.firstName, debtor.lastName];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BOCDebtor" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:@"Master"];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - NSManagedObjectContext

- (NSManagedObjectContext*)managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[BOCDataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

@end
