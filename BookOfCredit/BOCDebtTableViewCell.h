//
//  BOCDebtTableViewCell.h
//  BookOfCredit
//
//  Created by Alexandr on 05.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BOCDebtTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *currency;
@property (strong, nonatomic) IBOutlet UILabel *amount;
@property (strong, nonatomic) IBOutlet UILabel *date;

@end
