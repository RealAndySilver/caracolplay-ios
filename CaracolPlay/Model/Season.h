//
//  Season.h
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Season : NSObject

@property (strong, nonatomic) NSString *seasonName;
@property (strong, nonatomic) NSNumber *seasonNumber;
@property (strong, nonatomic) NSArray *episodes; // Of Episode

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
