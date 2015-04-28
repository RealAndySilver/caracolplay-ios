//
//  UserDefaultsSaver.h
//  CaracolPlay
//
//  Created by Developer on 28/04/15.
//  Copyright (c) 2015 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsSaver : NSObject

//+(UserDefaultsSaver *)sharedInstance;
+(void)savePurchaseInfoWithUserInfo:(NSString *)userInfo purchaseType:(NSString *)purchaseType transactionId:(NSString *)transactionId productId:(NSString *)productId;
+(void)deletePurchaseDics;
+(BOOL)pendingPurchaseDicExists;
+(NSDictionary *)getPurchaseDic;
@end
