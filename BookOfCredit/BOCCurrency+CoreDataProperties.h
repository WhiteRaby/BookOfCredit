//
//  BOCCurrency+CoreDataProperties.h
//  BookOfCredit
//
//  Created by Alexandr on 04.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BOCCurrency.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOCCurrency (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<BOCDebt *> *debts;

@end

@interface BOCCurrency (CoreDataGeneratedAccessors)

- (void)addDebtsObject:(BOCDebt *)value;
- (void)removeDebtsObject:(BOCDebt *)value;
- (void)addDebts:(NSSet<BOCDebt *> *)values;
- (void)removeDebts:(NSSet<BOCDebt *> *)values;

@end

NS_ASSUME_NONNULL_END
