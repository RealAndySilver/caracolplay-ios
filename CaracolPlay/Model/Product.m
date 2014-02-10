//
//  Product.m
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "Product.h"

@implementation Product

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _name = dictionary[@"name"];
        _type = dictionary[@"type"];
        _rate = dictionary[@"rate"];
        _myRate = dictionary[@"my_rate"];
        _categoryID = dictionary[@"category_id"];
        _identifier = dictionary[@"id"];
        _imageURL = dictionary[@"image_url"];
        _trailerURL = dictionary[@"trailer_url"];
        _hasSeasons = [dictionary[@"has_seasons"] boolValue];
        _description = dictionary[@"description"];
        _episodes = dictionary[@"episodes"];
        _seasonList = dictionary[@"season_list"];
    }
    return self;
}

@end
