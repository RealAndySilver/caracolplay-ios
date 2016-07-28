//
//  Categoria.m
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "Categoria.h"

@implementation Categoria

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _name = dictionary[@"name"];
        _identifier = dictionary[@"id"];
        _displayType = dictionary[@"display_type"];
    }
    return self;
}

@end
