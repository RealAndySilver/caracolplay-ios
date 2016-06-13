//
//  Product.h
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *rate;
@property (strong, nonatomic) NSString *categoryID;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *trailerURL;
@property (nonatomic) BOOL hasSeasons;
@property (strong, nonatomic) NSString *detailDescription;
@property (strong, nonatomic) NSArray *episodes; //Of Episode (Only if there are no seasons)
@property (strong, nonatomic) NSArray *seasonList; //Of Season
@property (strong, nonatomic) NSString *free;
@property (assign, nonatomic) BOOL statusRent;
@property (assign, nonatomic) NSUInteger viewType;
@property (assign, nonatomic) BOOL isWebView;
@property (assign, nonatomic) NSString *webviewUrl;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
