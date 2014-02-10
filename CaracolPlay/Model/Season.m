//
//  Season.m
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "Season.h"

@implementation Season

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _seasonName = dictionary[@"season_name"];
        _seasonNumber = dictionary[@"season_number"];
        _episodes = dictionary[@"episodes"];
    }
    return self;
}

@end
