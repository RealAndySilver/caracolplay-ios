//
//  Episode.m
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "Episode.h"

@implementation Episode

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _productName = dictionary[@"product_name"];
        _episodeName = dictionary[@"episode_name"];
        _description = dictionary[@"description"];
        _imageURL = dictionary[@"image_url"];
        _episodeNumber = dictionary[@"episode_number"];
        _identifier = dictionary[@"id"];
        _url = dictionary[@"url"];
        _trailerURL = dictionary[@"trailer_url"];
        _rate = dictionary[@"rate"];
        _views = dictionary[@"views"];
        _duration = dictionary[@"duration"];
        _categoryID = dictionary[@"category_id"];
        _progressSec = dictionary[@"progress_sec"];
        _watchedOn = dictionary[@"watched_on"];
        _is3G = [dictionary[@"is_3g"] boolValue];
    }
    return self;
}

@end
