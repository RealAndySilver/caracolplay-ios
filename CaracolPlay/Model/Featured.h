//
//  Featured.h
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Featured : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *featureText;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSNumber *rate;
@property (strong, nonatomic) NSString *categoryID;
@property (strong, nonatomic) NSString *imageURL;
@property (nonatomic) BOOL isCampaign;
@property (strong, nonatomic) NSString *campaignURL;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
