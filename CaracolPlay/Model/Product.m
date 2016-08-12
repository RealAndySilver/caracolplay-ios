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
        if (dictionary[@"rate"] == nil || dictionary[@"rate"] == [NSNull null]) {
            _rate = @0;
        } else {
            _rate = dictionary[@"rate"];
        }
        _categoryID = dictionary[@"category_id"];
        _identifier = dictionary[@"id"];
        _imageURL = dictionary[@"image_url"];
        _trailerURL = dictionary[@"trailer"];
        _hasSeasons = [dictionary[@"has_seasons"] boolValue];
        _detailDescription = dictionary[@"description"];
        _episodes = dictionary[@"episodes"];
        _seasonList = dictionary[@"season_list"];
        _free = dictionary[@"free"];
        _statusRent = [dictionary[@"status_rent"] boolValue];
        _viewType = [dictionary[@"type_view"] intValue];
        if (dictionary[@"is_webview"] == nil || dictionary[@"is_webview"] == [NSNull null]) {
            _isWebView = NO;
        } else {
            _isWebView = [dictionary[@"is_webview"] boolValue];
        }
        _webviewUrl = dictionary[@"alias"];
    }
    return self;
}

@end
