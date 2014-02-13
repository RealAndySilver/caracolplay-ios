//
//  RateView.h
//  CaracolPlay
//
//  Created by Developer on 11/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RateView;

@protocol RateViewDelegate <NSObject>
@optional
-(void)rateButtonWasTappedInRateView:(RateView *)rateView withRate:(int)rate;
-(void)cancelButtonWasTappedInRateView:(RateView *)rateView;
@end

@interface RateView : UIView
@property (strong, nonatomic) id <RateViewDelegate> delegate;
@end
