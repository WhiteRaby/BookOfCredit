//
//  BOCNewDebtViewController.m
//  BookOfCredit
//
//  Created by Alexandr on 05.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

#import "BOCNewDebtViewController.h"
#import "BOCDebt.h"
#import <CoreData/CoreData.h>
#import "BOCDataManager.h"
#import "BOCCurrency.h"


@interface BOCNewDebtViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *borrowSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *amountTextView;
@property (weak, nonatomic) IBOutlet UIStepper *amountStepper;
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *dateOnSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateCell;

@property (strong, nonatomic) NSArray *currencys;
@property (strong, nonatomic) NSIndexPath *dateCellIndexPath;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)actionSave:(id)sender;
- (IBAction)actionCencel:(id)sender;
- (IBAction)actionChengeDateSwitch:(UISwitch *)sender;
- (IBAction)actionStepper:(UIStepper *)sender;

@end

@implementation BOCNewDebtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BOCCurrency"];
    self.currencys = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    self.amountTextView.text = @"0";
    
    self.amountTextView.delegate = self;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    [numberToolbar sizeToFit];
    self.amountTextView.inputAccessoryView = numberToolbar;
    
    [self loadContent];
}

- (void)loadContent {
    
    if (self.debt) {
        self.amountTextView.text = [NSString stringWithFormat:@"%@", self.debt.amount];
        self.borrowSegmentedControl.selectedSegmentIndex = (int)[self.debt.isBorrow boolValue];
        [self.currencyPickerView selectRow:[self.currencys indexOfObject:self.debt.currency]
                               inComponent:0
                                  animated:NO];
        self.newDebt = NO;
    } else {
        self.debt = [NSEntityDescription insertNewObjectForEntityForName:@"BOCDebt"
                                                inManagedObjectContext:[self managedObjectContext]];
        self.newDebt = YES;
    }
    
}

- (void)doneWithNumberPad{
    [self.amountTextView resignFirstResponder];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [self.currencys count];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [self.currencys[row] name];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (self.dateCell == cell) {
        if (!self.dateOnSwitch.isOn){
            return 0;
        }
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (IBAction)actionSave:(id)sender {
    self.debt.amount = [NSNumber numberWithInteger:[self.amountTextView.text integerValue]];
    self.debt.debtor = self.debtor;
    self.debt.currency = [self.currencys objectAtIndex:[self.currencyPickerView selectedRowInComponent:0]];
    self.debt.isBorrow = [NSNumber numberWithBool:(BOOL)self.borrowSegmentedControl.selectedSegmentIndex];
    
    [self.managedObjectContext save:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionCencel:(id)sender {
    if (self.newDebt) {
        [self.managedObjectContext deleteObject:self.debt];
        [self.managedObjectContext save:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionChengeDateSwitch:(UISwitch *)sender {
    [self.tableView reloadData];
}

- (IBAction)actionStepper:(UIStepper *)sender {
    NSInteger num = [[self.amountTextView.text substringWithRange:NSMakeRange(0, 1)] integerValue];
    num += (int)sender.value;
    
    if (num > 0) {
        self.amountTextView.text =
        [NSString stringWithFormat:@"%ld%@", (long)num, [self.amountTextView.text substringFromIndex:1]];
    } else if (num == 0) {
        if ([self.amountTextView.text length] == 1) {
            self.amountTextView.text = @"0";
        } else {
            self.amountTextView.text =
            [NSString stringWithFormat:@"%d%@", 9, [self.amountTextView.text substringFromIndex:2]];
        }
    }
    sender.value = 0.f;
}

#pragma mark - NSManagedObjectContext

- (NSManagedObjectContext*)managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[BOCDataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([self.amountTextView.text isEqualToString:@""]) {
        self.amountTextView.text = @"0";
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([self.amountTextView.text isEqualToString:@"0"]) {
        self.amountTextView.text = @"";
    }
}

@end














