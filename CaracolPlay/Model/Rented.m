//
//  Rented.m
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "Rented.h"

@implementation Rented

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _pricePayed = dictionary[@"price_payed"];
        _productID = dictionary[@"product_id"];
        _imageURL = dictionary[@"image_url"];
        _trailerURL = dictionary[@"trailer_url"];
        _name = dictionary[@"name"];
        _type = dictionary[@"type"];
        _categoryID = dictionary[@"category_id"];
        _episodes = dictionary[@"episodes"];
        _expires = [dictionary[@"expires"] boolValue];
        _expireDate = dictionary[@"expire_date"];
    }
    return self;
}

@end
