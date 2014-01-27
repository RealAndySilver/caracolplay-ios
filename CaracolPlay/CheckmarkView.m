//
//  CheckmarkView.m
//  CaracolPlay
//
//  Created by Developer on 27/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CheckmarkView.h"
@import QuartzCore;
@interface CheckmarkView()
@property (strong, nonatomic) UIImageView *checkmarkImageView;
@end

@implementation CheckmarkView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor darkGrayColor];
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 1.0;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tapGesture];
        
        self.checkmarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/5.0, self.bounds.size.height/5.0, self.bounds.size.width - (self.bounds.size.width/5.0)*2, self.bounds.size.height - (self.bounds.size.height/5.0)*2)];
        self.checkmarkImageView.tintColor = [UIColor whiteColor];
        [self addSubview:self.checkmarkImageView];
        
        self.checkmarkImage = [UIImage imageNamed:@"Checkmark.png"];
        self.checkmarkImage = [self.checkmarkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return self;
}

#pragma mark - Setters

-(void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    if (_isChecked) {
        self.checkmarkImageView.image = self.checkmarkImage;
    } else {
        self.checkmarkImageView.image = nil;
    }
}

-(void)setCheckmarkImageTintColor:(UIColor *)checkmarkImageTintColor {
    _checkmarkImageTintColor = checkmarkImageTintColor;
    self.checkmarkImageView.tintColor = checkmarkImageTintColor;
}

-(void)setCheckmarkImage:(UIImage *)checkmarkImage {
    _checkmarkImage = checkmarkImage;
}

-(void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    self.backgroundColor = bgColor;
}

-(void)setCornerRadius:(CGFloat )cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

-(void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = [borderColor CGColor];
}

-(void)setBorderWidth:(CGFloat )borderWidth {
    _borderWidth = borderWidth;
    if (self.hasBorder) {
        self.layer.borderWidth = borderWidth;
    } else {
        self.layer.borderWidth = 0.0;
    }
}

-(void)setHasBorder:(BOOL)hasBorder {
    _hasBorder = hasBorder;
    if (!hasBorder) {
        self.layer.borderWidth = 0.0;
    }
}

/*---------------------------------------------------*/

-(void)tap {
    if (self.isChecked) {
        self.checkmarkImageView.image = nil;
    } else {
        self.checkmarkImageView.image = self.checkmarkImage;
    }
    self.isChecked = !self.isChecked;
}

-(BOOL)viewIsChecked {
    return self.isChecked;
}

@end
