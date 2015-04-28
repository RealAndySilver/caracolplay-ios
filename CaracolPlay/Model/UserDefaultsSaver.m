//
//  UserDefaultsSaver.m
//  CaracolPlay
//
//  Created by Developer on 28/04/15.
//  Copyright (c) 2015 iAmStudio. All rights reserved.
//

#import "UserDefaultsSaver.h"

@implementation UserDefaultsSaver

/*+(UserDefaultsSaver *)sharedInstance {
    static UserDefaultsSaver *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[UserDefaultsSaver alloc] init];
        });
    }
    return shared;
}*/

+(BOOL)pendingPurchaseDicExists {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"purchaseDic"] != nil) {
        return YES;
    } else {
        return NO;
    }
}

+(NSDictionary *)getPurchaseDic {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"purchaseDic"];
}

+(void)savePurchaseInfoWithUserInfo:(NSString *)userInfo purchaseType:(NSString *)purchaseType transactionId:(NSString *)transactionId productId:(NSString *)productId {
    NSDictionary *purchaseDic = @{@"userInfo" : userInfo, @"purchaseType" : purchaseType, @"transactionId" : transactionId, @"productId" : productId};
    [[NSUserDefaults standardUserDefaults] setObject:purchaseDic forKey:@"purchaseDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)deletePurchaseDics {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"purchaseDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
