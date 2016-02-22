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

static NSString *periodNames[] = {
    @"день", @"дня", @"дней",
    @"месяц", @"месяца", @"месяцев",
    @"год", @"года", @"лет",
};

#pragma mark - Public Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ %@",
                  self.debtor.firstName, self.debtor.lastName];
    
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

#pragma mark - UITableViewConfigureCell

- (void)configureCell:(BOCDebtTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    BOCDebt *debt = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *amount = [NSString stringWithFormat:@"%@", debt.amount];
    for (NSInteger i = amount.length; i > 0 ; i-=3) {
        amount = [NSString stringWithFormat:@"%@ %@",
                  [amount substringToIndex:i],
                  [amount substringFromIndex:i]];
    }
    cell.amount.text = amount;
    cell.currency.image =[UIImage imageNamed:debt.currency.imageName];
    cell.backgroundColor = [UIColor whiteColor];
    
    if (debt.endDate) {
        NSDate *leftDate = [NSDate dateWithTimeInterval:86400 sinceDate:debt.endDate];
        
        NSDateComponents *components = [[NSCalendar currentCalendar]
                                        components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                        fromDate:[NSDate dateWithTimeIntervalSinceNow:0]
                                        toDate:leftDate
                                        options:0];
        
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        NSInteger period;
        NSInteger count;
        
        if (year > 0) {
            cell.date.text = [NSString stringWithFormat:@"%ld", (long)year];
            period = 2;
            count = year;
        } else if (month > 0) {
            cell.date.text = [NSString stringWithFormat:@"%ld", (long)month];
            period = 1;
            count = month;
        } else if (day > 0) {
            cell.date.text = [NSString stringWithFormat:@"%ld", (long)day];
            period = 0;
            count = day;
        } else {
            day = 0;
            cell.date.text = [NSString stringWithFormat:@"%ld", (long)day];
            period = 0;
            count = day;
            cell.backgroundColor = [UIColor colorWithRed:1.f green:0.86f blue:0.86f alpha:1.f];
        }
        
        if (count == 1) {
            count = 0;
        } else if (count >= 2 && count <= 4) {
            count = 1;
        } else {
            count = 2;
        }
        
        cell.periodLabel.text = periodNames[period*3 + count];
        
        if (count == 0) {
            cell.leftLabel.text = @"Остался";
        } else {
            cell.leftLabel.text = @"Осталось";
        }
        
    } else {
        cell.periodLabel.text = nil;
        cell.date.text = nil;
        cell.leftLabel.text = nil;
    }
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BOCDebt" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"isBorrow" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"debtor == %@", self.debtor];
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:@"isBorrow"
                                                   cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
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
