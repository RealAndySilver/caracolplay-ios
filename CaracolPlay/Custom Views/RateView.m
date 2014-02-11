//
//  RateView.m
//  CaracolPlay
//
//  Created by Developer on 11/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RateView.h"
#import <QuartzCore/QuartzCore.h>

@interface RateView()
@property (strong, nonatomic) UIImageView *starImageView1;
@property (strong, nonatomic) UIImageView *starImageView2;
@property (strong, nonatomic) UIImageView *starImageView3;
@property (strong, nonatomic) UIImageView *starImageView4;
@property (strong, nonatomic) UIImageView *starImageView5;
@property (strong, nonatomic) NSArray *starsImageViewsArray;
@property (strong, nonatomic) UILabel *label;
@property (nonatomic) int goldStars;
@end

@implementation RateView

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor grayColor];
        self.layer.cornerRadius = 5.0;
        self.alpha = 1.0;
        
        self.label = [[UILabel alloc] init];
        self.label.text = @"Califica esta producción";
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:12.0];
        [self addSubview:self.label];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectMake(self.bounds.size.width/2 - 80.0, 10.0, 160.0, 30.0);
    [self createStarsImageViews];
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
    starImageView.tag = position;
    starImageView.userInteractionEnabled = YES;
    [starImageView addGestureRecognizer:tapGesture];
    starImageView.contentMode = UIViewContentModeScaleAspectFill;
    return starImageView;
}

-(void)starImageViewTap:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"me tapearon");
    self.goldStars = tapGesture.view.tag;
    [self modifyGoldStarsNumber:self.goldStars];
}

-(void)modifyGoldStarsNumber:(NSInteger)goldStarsNumber {
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = self.starsImageViewsArray[i];
        if (goldStarsNumber >= i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0];
        }
    }
}

@end
