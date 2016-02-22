//
//  AppDelegate.m
//  BookOfCredit
//
//  Created by Alexandr on 04.02.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

#import "BOCAppDelegate.h"
#import <CoreData/CoreData.h>
#import "BOCDataManager.h"
#import "BOCCurrency.h"

NSString *currencyNames[] = {@"Доллар", @"Евро", @"Рубли", @"Белорусские рубли"};
NSString *currencyImageNames[] = {@"dollar", @"euro", @"rubl", @"blr"};

@implementation BOCAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSManagedObjectContext *context = [[BOCDataManager sharedManager] managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BOCCurrency"];
    NSArray *results = [context executeFetchRequest:request error:nil];
    if ([results count] == 0) {
        for (int i = 0; i < 4; i++) {
            BOCCurrency *currency = [NSEntityDescription insertNewObjectForEntityForName:@"BOCCurrency"
                                                                  inManagedObjectContext:context];
            currency.name = currencyNames[i];
            currency.imageName = currencyImageNames[i];
            [context save:nil];
        }
    }
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {

    [[BOCDataManager sharedManager] saveContext];
}

@end
