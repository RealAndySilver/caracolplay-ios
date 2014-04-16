//
//  Featured.m
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "Featured.h"

@implementation Featured

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _name = dictionary[@"name"];
        _type = dictionary[@"type"];
        _featureText = dictionary[@"feature_text"];
        _identifier = dictionary[@"id"];
        _rate = dictionary[@"rate"];
        _categoryID = dictionary[@"category_id"];
        _imageURL = dictionary[@"image_url"];
        _isCampaign = [dictionary[@"is_campaing"] boolValue];
        _campaignURL = dictionary[@"campaing_url"];
    }
    return self;
}

@end
