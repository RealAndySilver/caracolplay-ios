//
//  CheckmarkView.h
//  CaracolPlay
//
//  Created by Developer on 27/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckmarkView : UIView


/** The Checkbox background color. Default is darkGrayColor*/
@property (strong, nonatomic) UIColor *bgColor;

/** The Checkbox corner radius. Default is 5.0*/
@property (nonatomic) CGFloat cornerRadius;

/** The Checkbox border color. Default is whiteColor*/
@property (strong, nonatomic) UIColor *borderColor;

/** The Checkbox border width. Default is 1.0*/
@property (nonatomic) CGFloat borderWidth;

/** Set if the Checkbox has a border. Default is YES*/
@property (nonatomic) BOOL hasBorder;

/** The image to display when the user tap in the Checkbox. By default, it has 
 a checkmark image.*/
@property (strong, nonatomic) UIImage *checkmarkImage;

/** The checkmark image tint color. Default is whiteColor. */
@property (strong, nonatomic) UIColor *checkmarkImageTintColor;

/** Set if the Checkbox is checked or not. Default is NO*/
@property (nonatomic) BOOL isChecked;

/** Obtain a BOOL indicating if the Checkbox is checked or not.*/
-(BOOL)viewIsChecked;
@end
