//
//  BOCDebt+CoreDataProperties.m
//  BookOfCredit
//
//  Created by Alexandr on 12.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BOCDebt+CoreDataProperties.h"

@implementation BOCDebt (CoreDataProperties)

@dynamic amount;
@dynamic isBorrow;
@dynamic startDate;
@dynamic endDate;
@dynamic currency;
@dynamic debtor;

@end
