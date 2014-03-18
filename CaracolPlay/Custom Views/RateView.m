//
//  RateView.m
//  CaracolPlay
//
//  Created by Developer on 11/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RateView.h"
#import <QuartzCore/QuartzCore.h>
#import "MyUtilities.h"

@interface RateView()
@property (strong, nonatomic) UIImageView *starImageView1;
@property (strong, nonatomic) UIImageView *starImageView2;
@property (strong, nonatomic) UIImageView *starImageView3;
@property (strong, nonatomic) UIImageView *starImageView4;
@property (strong, nonatomic) UIImageView *starImageView5;
@property (strong, nonatomic) NSArray *starsImageViewsArray;
@property (strong, nonatomic) UILabel *label;
@property (nonatomic) int goldStars;
@property (strong, nonatomic) UIButton *rateButton;
@property (strong, nonatomic) UIButton *cancelButton;
@end

@implementation RateView

-(id)initWithFrame:(CGRect)frame goldStars:(NSUInteger)goldStars {
    if (self = [super initWithFrame:frame]) {
        self.goldStars = goldStars;
        //////////////////////////////////////////////////////
        [MyUtilities addParallaxEffectWithMovementRange:20.0 inView:self];
        
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        self.layer.cornerRadius = 5.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, frame.size.width, 30.0)];
        self.label.text = @"Califica esta producción";
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:12.0];
        [self addSubview:self.label];
        
        self.rateButton = [[UIButton alloc] initWithFrame:CGRectMake(40.0, frame.size.height - 44.0, frame.size.width - 80.0, 30.0)];
        [self.rateButton setTitle:@"Calificar" forState:UIControlStateNormal];
        [self.rateButton addTarget:self action:@selector(rateButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.rateButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [self.rateButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
        [self.rateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:self.rateButton];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 40.0, -38.0, 78.0, 78.0)];
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        [self addSubview:self.cancelButton];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self createStarsImageViews];
    [self modifyGoldStarsNumber:self.goldStars];
    [self animateTransition];
}

-(void)animateTransition {
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL success){}];
    
}

-(void)createStarsImageViews {
    
    self.starImageView1 = [self createStarImageViewAtPosition:0];
    self.starImageView2 = [self createStarImageViewAtPosition:1];
    self.starImageView3 = [self createStarImageViewAtPosition:2];
    self.starImageView4 = [self createStarImageViewAtPosition:3];
    self.starImageView5 = [self createStarImageViewAtPosition:4];
    
    //We have to add the views to an array to access them using an index, in the method
    //-modifyGoldStarNumber, which is called when the user tap a star.
    self.starsImageViewsArray = [NSMutableArray arrayWithObjects:self.starImageView1, self.starImageView2, self.starImageView3, self.starImageView4, self.starImageView5, nil];
    
    [self addSubview:self.starImageView1];
    [self addSubview:self.starImageView2];
    [self addSubview:self.starImageView3];
    [self addSubview:self.starImageView4];
    [self addSubview:self.starImageView5];
}

-(UIImageView *)createStarImageViewAtPosition:(NSUInteger)position {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starImageViewTap:)];
    tapGesture.numberOfTapsRequired = 1;
    
    UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40.0 + (position*30),
                                                                               45.0,
                                                                               20.0,
                                                                               20.0)];
    starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    starImageView.clipsToBounds = YES;
    starImageView.tintColor = [UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0];
    starImageView.tag = position;
    starImageView.userInteractionEnabled = YES;
    [starImageView addGestureRecognizer:tapGesture];
    starImageView.contentMode = UIViewContentModeScaleAspectFill;
    return starImageView;
}

-(void)starImageViewTap:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"me tapearon");
    self.goldStars = tapGesture.view.tag + 1;
    [self modifyGoldStarsNumber:self.goldStars];
}

-(void)modifyGoldStarsNumber:(NSInteger)goldStarsNumber {
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = self.starsImageViewsArray[i];
        if (goldStarsNumber > i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0];
        }
    }
}

#pragma mark - Button Actions 

-(void)cancelButtonTapped {
    [self.delegate cancelButtonWasTappedInRateView:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL success){}];
}

-(void)rateButtonTapped {
    [self.delegate rateButtonWasTappedInRateView:self withRate:self.goldStars];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL success){}];
}

@end
