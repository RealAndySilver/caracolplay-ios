//
//  Video.m
//  CaracolPlay
//
//  Created by Developer on 31/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "Video.h"

@implementation Video

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _status = [dictionary[@"status"] boolValue];
        _codMessage = [dictionary[@"cod_message"] intValue];
        _message = dictionary[@"message"];
        _progressSec = [dictionary[@"progress_sec"] intValue];
        _embedSD = dictionary[@"embed_sd"];
        _embedHD = dictionary[@"embed_hd"];
        _trailer = dictionary[@"trailer"];
        _is3G = [dictionary[@"is_3g"] boolValue];
        _typeView = [dictionary[@"type_view"] intValue];
    }
    return self;
}

@end
