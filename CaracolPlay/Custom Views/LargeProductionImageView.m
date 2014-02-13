//
//  LargeProductionImageView.m
//  CaracolPlay
//
//  Created by Developer on 13/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LargeProductionImageView.h"

@interface LargeProductionImageView()
//@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@end

@implementation LargeProductionImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        // 1. ImageView
        self.largeImageView = [[UIImageView alloc] init];
        self.largeImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.largeImageView.clipsToBounds = YES;
        [self addSubview:self.largeImageView];
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
        [self addGestureRecognizer:self.tapGesture];
        
        // 2. Close button
        /*self.closeButton = [[UIButton alloc] init];
        [self.closeButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];*/
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.largeImageView.frame = self.bounds;
    //self.closeButton.frame = CGRectMake(self.bounds.size.width - 30.0, 0.0, 30.0, 30.0);
    
    [self showView];
}

-(void)showView {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished){}];
}

-(void)dismissView {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

@end
