//
//  StarsView.m
//  CaracolPlay
//
//  Created by Developer on 14/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "StarsView.h"

@interface StarsView()
@property (strong, nonatomic) UIImageView *starImageView1;
@property (strong, nonatomic) UIImageView *starImageView2;
@property (strong, nonatomic) UIImageView *starImageView3;
@property (strong, nonatomic) UIImageView *starImageView4;
@property (strong, nonatomic) UIImageView *StarImageView5;
@property (strong, nonatomic) NSMutableArray *starImagesViewsArray;
@end

@implementation StarsView

-(NSMutableArray *)starImagesViewsArray {
    if (!_starImagesViewsArray) {
        _starImagesViewsArray = [[NSMutableArray alloc] init];
    }
    return _starImagesViewsArray;
}

-(instancetype)initWithFrame:(CGRect)frame rate:(int)rate {
    if (self = [super initWithFrame:frame]) {
        self.starImageView1 = [self createStarImageViewAtPosition:0];
        self.starImageView2 = [self createStarImageViewAtPosition:1];
        self.starImageView3 = [self createStarImageViewAtPosition:2];
        self.starImageView4 = [self createStarImageViewAtPosition:3];
        self.starImageView5 = [self createStarImageViewAtPosition:4];
        [self tintStarsUsingRate:rate];
        [self addSubview:self.starImageView1];
        [self addSubview:self.starImageView2];
        [self addSubview:self.starImageView3];
        [self addSubview:self.starImageView4];
        [self addSubview:self.StarImageView5];

        //[self createStarsImageViewsWithGoldStarsNumber:rate];
    }
    return  self;
}

-(void)tintStarsUsingRate:(NSUInteger)rate {
    for (int i = 1; i < 6; i ++) {
        UIImageView *starImageView = self.starImagesViewsArray[i - 1];
        if (rate >= i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        }
    }
}

-(UIImageView *)createStarImageViewAtPosition:(NSUInteger)position {
    UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width/5)*position,
                                                                               0.0,
                                                                               self.bounds.size.width/5,
                                                                               self.bounds.size.width/5)];
    
    starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    /*if (goldStars > i) {
        starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
    } else {
        starImageView.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }*/
    starImageView.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    starImageView.clipsToBounds = YES;
    starImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.starImagesViewsArray addObject:starImageView];
    return starImageView;
}

/*-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width/5)*i,
                                                                                   0.0,
                                                                                   self.bounds.size.width/5,
                                                                                   self.bounds.size.width/5)];
        
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars > i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:starImageView];
    }
}*/

-(void)setRate:(NSUInteger)rate {
    _rate = rate;
    [self tintStarsUsingRate:rate];
}

@end
