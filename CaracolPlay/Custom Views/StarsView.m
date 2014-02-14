//
//  StarsView.m
//  CaracolPlay
//
//  Created by Developer on 14/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "StarsView.h"

@implementation StarsView

-(instancetype)initWithFrame:(CGRect)frame rate:(int)rate {
    if (self = [super initWithFrame:frame]) {
        [self createStarsImageViewsWithGoldStarsNumber:rate];
    }
    return  self;
}

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width/5)*i,
                                                                                   0.0,
                                                                                   self.bounds.size.width/5,
                                                                                   self.bounds.size.width/5)];
        
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars >= i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:starImageView];
    }
}

@end
