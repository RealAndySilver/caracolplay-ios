//
//  Video.h
//  CaracolPlay
//
//  Created by Developer on 31/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject
@property (assign, nonatomic) BOOL status;
@property (assign, nonatomic) BOOL is3G;
@property (assign, nonatomic) int codMessage;
@property (strong, nonatomic) NSString *message;
@property (assign, nonatomic) int progressSec;
@property (strong, nonatomic) NSString *embedSD;
@property (strong, nonatomic) NSString *embedHD;
@property (strong, nonatomic) NSString *trailer;
@property (assign, nonatomic) int typeView;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
