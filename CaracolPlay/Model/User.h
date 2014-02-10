//
//  User.h
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSDictionary *suscription;
@property (strong, nonatomic) NSArray *redeemed; //Of Redeemed Objects
@property (strong, nonatomic) NSArray *rented; //Of Rented Objects
@property (strong, nonatomic) NSArray *lists; //Of List Objects
@property (strong, nonatomic) NSArray *watched; //Of Watched Objects
@property (strong, nonatomic) NSArray *recentlyWatched; //Of Watched Objects

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
