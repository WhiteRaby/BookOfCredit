//
//  BOCNewDebtViewController.h
//  BookOfCredit
//
//  Created by Alexandr on 05.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BOCDebt;
@class BOCDebtor;

@interface BOCNewDebtViewController : UITableViewController



@property (strong, nonatomic) BOCDebtor *debtor;
@property (strong, nonatomic) BOCDebt *debt;
@property (assign, nonatomic) BOOL newDebt;


@end
