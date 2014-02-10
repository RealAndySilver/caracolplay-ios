//
//  List.m
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "List.h"

@implementation List

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _listName = dictionary[@"list_name"];
        _listID = dictionary[@"list_id"];
        _episodes = dictionary[@"episodes"];
    }
    return  self;
}

@end
