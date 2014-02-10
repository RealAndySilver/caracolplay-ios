//
//  User.m
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _email = dictionary[@"email"];
        _password = dictionary[@"password"];
        _suscription = dictionary[@"suscription"];
        _redeemed = dictionary[@"redeemed"];
        _rented = dictionary[@"rented"];
        _watched = dictionary[@"watched"];
        _recentlyWatched = dictionary[@"recently_watched"];
        _lists = dictionary[@"my_lists"];
    }
    return self;
}

@end
