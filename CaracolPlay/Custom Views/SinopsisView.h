//
//  SinopsisView.h
//  CaracolPlay
//
//  Created by Developer on 19/08/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SinopsisView;

@protocol SinopsisViewDelegate <NSObject>
-(void)closeButtonPressedInSinopsisView:(SinopsisView *)sinopsisView;
-(void)sinopsisViewDidDissapear:(SinopsisView *)sinopsisView;
@end

@interface SinopsisView : UIView
@property (strong, nonatomic) id <SinopsisViewDelegate> delegate;
@property (strong, nonatomic) UILabel *mainTitle;
@property (strong, nonatomic) NSString *sinopsisString;
-(void)showInView:(UIView *)view;
@end
