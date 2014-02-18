//
//  StarsView.h
//  CaracolPlay
//
//  Created by Developer on 14/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarsView : UIView
@property (nonatomic) NSUInteger rate;
-(instancetype)initWithFrame:(CGRect)frame rate:(int)rate;
@end
