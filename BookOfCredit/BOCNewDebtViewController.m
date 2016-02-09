//
//  BOCNewDebtViewController.m
//  BookOfCredit
//
//  Created by Alexandr on 05.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

#import "BOCNewDebtViewController.h"

@interface BOCNewDebtViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *borrowSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *amountTextView;
@property (weak, nonatomic) IBOutlet UIStepper *amountStepper;
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *dateOnSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSArray *currencys;

- (IBAction)actionSave:(id)sender;
- (IBAction)actionCencel:(id)sender;
- (IBAction)actionChengeDateSwitch:(UISwitch *)sender;
- (IBAction)actionStepper:(UIStepper *)sender;

@end

@implementation BOCNewDebtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currencys = @[@"Dollar", @"Euro", @"Rub"];
    self.amountTextView.text = @"0";
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [self.currencys count];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.currencys[row];
}



- (IBAction)actionSave:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionCencel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionChengeDateSwitch:(UISwitch *)sender {
    self.datePicker.userInteractionEnabled = sender.on;
    //NSLog(@"%d", (sender.on ? 1:0));
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

@end















