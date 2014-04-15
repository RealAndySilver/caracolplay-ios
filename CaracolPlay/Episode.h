//
//  Episode.h
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Episode : NSObject

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *episodeName;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSNumber *episodeNumber;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *trailerURL;
@property (strong, nonatomic) NSNumber *rate;
@property (strong, nonatomic) NSNumber *views;
@property (strong, nonatomic) NSNumber *duration;
@property (strong, nonatomic) NSString *categoryID;
@property (strong, nonatomic) NSNumber *progressSec;
@property (strong, nonatomic) NSString *watchedOn;
@property (assign, nonatomic) BOOL is3G;
@property (assign, nonatomic) BOOL lastChapter;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
