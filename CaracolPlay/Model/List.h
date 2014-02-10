//
//  List.h
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface List : NSObject

@property (strong, nonatomic) NSString *listName;
@property (strong, nonatomic) NSString *listID;
@property (strong, nonatomic) NSArray *episodes; //Of Episode

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
