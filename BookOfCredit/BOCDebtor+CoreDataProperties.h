//
//  BOCDebtor+CoreDataProperties.h
//  BookOfCredit
//
//  Created by Alexandr on 04.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BOCDebtor.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOCDebtor (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSSet<BOCDebt *> *debts;

@end

@interface BOCDebtor (CoreDataGeneratedAccessors)

- (void)addDebtsObject:(BOCDebt *)value;
- (void)removeDebtsObject:(BOCDebt *)value;
- (void)addDebts:(NSSet<BOCDebt *> *)values;
- (void)removeDebts:(NSSet<BOCDebt *> *)values;

@end

NS_ASSUME_NONNULL_END
