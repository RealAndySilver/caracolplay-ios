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
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        self.label = [[UILabel alloc] init];
        self.label.text = @"Califica esta producción";
        self.label.textColor = [UIColor darkGrayColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:12.0];
        [self addSubview:self.label];
        
        self.rateButton = [[UIButton alloc] init];
        [self.rateButton setTitle:@"Calificar" forState:UIControlStateNormal];
        [self.rateButton addTarget:self action:@selector(rateButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.rateButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [self.rateButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self addSubview:self.rateButton];
        
        self.cancelButton = [[UIButton alloc] init];
        [self.cancelButton setTitle:@"Cancelar" forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [self addSubview:self.cancelButton];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectMake(self.bounds.size.width/2 - 80.0, 4.0, 160.0, 30.0);
    self.rateButton.frame = CGRectMake(0.0, self.bounds.size.height - 30.0, self.bounds.size.width/2, 30.0);
    self.cancelButton.frame = CGRectMake(self.bounds.size.width/2, self.bounds.size.height - 30.0, self.bounds.size.width/2, 30.0);
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
                                                                               40.0,
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
