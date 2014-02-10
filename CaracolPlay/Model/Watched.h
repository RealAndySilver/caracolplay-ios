//
//  Watched.h
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Watched : NSObject

@property (strong, nonatomic) NSString *pricePayed;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *trailerURL;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *categoryID;
@property (strong, nonatomic) NSArray *episodes; // Of Episode
@property (nonatomic) BOOL expires;
@property (strong, nonatomic) NSString *expireDate;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
