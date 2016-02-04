//
//  BOCDebt+CoreDataProperties.h
//  BookOfCredit
//
//  Created by Alexandr on 04.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BOCDebt.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOCDebt (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isBorrow;
@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) BOCCurrency *currency;
@property (nullable, nonatomic, retain) BOCDebtor *debtor;

@end

NS_ASSUME_NONNULL_END
