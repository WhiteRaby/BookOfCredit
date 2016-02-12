//
//  BOCDebtorDetailViewController.m
//  BookOfCredit
//
//  Created by Alexandr on 04.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

#import "BOCDebtorDetailViewController.h"
#import <CoreData/CoreData.h>
#import "BOCDataManager.h"
#import "BOCDebt.h"
#import "BOCDebtor.h"
#import "BOCCurrency.h"
#import "BOCDebtTableViewCell.h"
#import "BOCNewDebtViewController.h"

@interface BOCDebtorDetailViewController () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation BOCDebtorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ %@",
                  self.debtor.firstName, self.debtor.lastName];
    
    //self.navigationController.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    
    /*
    BOCDebt *debt1 = [NSEntityDescription insertNewObjectForEntityForName:@"BOCDebt"
                                                       inManagedObjectContext:[self managedObjectContext]];
    debt1.amount = @200;
    debt1.debtor = self.debtor;
    
    BOCDebt *debt2 = [NSEntityDescription insertNewObjectForEntityForName:@"BOCDebt"
                                                       inManagedObjectContext:[self managedObjectContext]];
    debt2.amount = @20;*/
    
    /*NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BOCDebt"];
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (BOCDebt *debt in results) {

        NSLog(@"%@",debt);
    }*/
    
    //[self.managedObjectContext save:nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Назад";
}

- (IBAction)actionAddDebt:(id)sender {
    
    BOCNewDebtViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BOCNewDebtViewController"];
    vc.debtor = self.debtor;
    vc.debt = nil;
    
    [self presentViewController:vc animated:YES completion:^{
        [self.tableView reloadData];
    }];
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
    
    static NSString *reuseIdentifier = @"BOCDebtTableViewCell";
    
    BOCDebtTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                                 forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    BOCDebt *debt = [self.fetchedResultsController objectAtIndexPath:
                     [NSIndexPath indexPathForRow:0 inSection:section]];
    
    if ([debt.isBorrow boolValue]) {
        return @"Вы должны";
    } else {
        return @"Вам должны";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"Удалить";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOCNewDebtViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BOCNewDebtViewController"];
    vc.debtor = self.debtor;
    vc.debt = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [self presentViewController:vc animated:YES completion:^{
        [self.tableView reloadData];
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableView

- (void)configureCell:(BOCDebtTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    BOCDebt *debt = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.amount.text = [NSString stringWithFormat:@"%@", debt.amount];
    cell.currency.image =[UIImage imageNamed:debt.currency.imageName];
    NSLocale *ruLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yy"];
    [formatter setDateFormat:@"dd MMM yyyy"];
    [formatter setLocale:ruLocale];
    if (debt.endDate) {
        cell.date.text = [NSString stringWithFormat:@"от: %@\n\nдо: %@",
                          [formatter stringFromDate:debt.startDate],
                          [formatter stringFromDate:debt.endDate]];
    } else {
        cell.date.text = [NSString stringWithFormat:@"от: %@",
                          [formatter stringFromDate:debt.startDate]];
    }
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BOCDebt" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"isBorrow" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"debtor == %@", self.debtor];
    [fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:@"isBorrow"
                                                   cacheName:nil];
    
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
