//
//  Categoria.h
//  CaracolPlay
//
//  Created by Developer on 10/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Categoria : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *identifier;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
