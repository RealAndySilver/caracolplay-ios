//
//  SearchPadCollectionViewCell.m
//  CaracolPlay
//
//  Created by Developer on 3/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SearchPadCollectionViewCell.h"

@interface SearchPadCollectionViewCell()
@property (strong, nonatomic) UIView *shadowView;
@end

@implementation SearchPadCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.shadowView = [[UIView alloc] init];
        /*self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shadowView.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        self.shadowView.layer.shadowOpacity = 0.8;
        self.shadowView.layer.shadowRadius = 3.0;*/
        [self.contentView addSubview:self.shadowView];
        
        self.productionImageView = [[UIImageView alloc] init];
        self.productionImageView.clipsToBounds = YES;
        self.productionImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.shadowView addSubview:self.productionImageView];
        
        self.productionNameLabel = [[UILabel alloc] init];
        self.productionNameLabel.textColor = [UIColor blackColor];
        self.productionNameLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.contentView addSubview:self.productionNameLabel];
        
        /////////////////////////////////////////////////////////////
        //Stars
        self.starsView = [[UIView alloc] init];
        [self.contentView addSubview:self.starsView];
        
        self.star1 = [[UIImageView alloc]initWithFrame:CGRectMake(16.0*1, 0.0, 16.0, 16.0)];
        self.star1.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star1.tag = 1;
        [self.starsView addSubview:self.star1];
        
        self.star2 = [[UIImageView alloc]initWithFrame:CGRectMake(16.0*2, 0.0, 16.0, 16.0)];
        self.star2.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star2.tag = 2;
        [self.starsView addSubview:self.star2];
        
        self.star3 = [[UIImageView alloc]initWithFrame:CGRectMake(16.0*3, 0.0, 16.0, 16.0)];
        self.star3.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star3.tag = 3;
        [self.starsView addSubview:self.star3];
        
        self.star4 = [[UIImageView alloc]initWithFrame:CGRectMake(16.0*4, 0.0, 16.0, 16.0)];
        self.star4.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star4.tag = 4;
        [self.starsView addSubview:self.star4];
        
        self.star5 = [[UIImageView alloc]initWithFrame:CGRectMake(16.0*5, 0.0, 16.0, 16.0)];
        self.star5.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star5.tag = 5;
        [self.starsView addSubview:self.star5];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.shadowView.frame = CGRectMake(10.0, 10.0, 80.0, bounds.size.height - 20.0);
    self.productionImageView.frame = CGRectMake(0.0, 0.0, self.shadowView.frame.size.width, self.shadowView.frame.size.height);
    self.productionNameLabel.frame = CGRectMake(self.productionImageView.frame.origin.x + self.productionImageView.frame.size.width + 30.0, bounds.size.height/2.0 - 30.0, bounds.size.width - (self.productionImageView.frame.origin.x + self.productionImageView.frame.size.width + 20.0), 30.0);
    self.starsView.frame = CGRectMake(self.productionImageView.frame.origin.x + self.productionImageView.frame.size.width + 30.0, bounds.size.height/2.0, 100.0, 16.0);
    
    /*if (self.showStars) {
        self.productionStarsView = [[StarsView alloc]initWithFrame:CGRectMake(self.productionImageView.frame.origin.x + self.productionImageView.frame.size.width + 30.0, bounds.size.height/2.0, 80.0, 16.0) rate:self.rate];
        [self.contentView addSubview:self.productionStarsView];
    }*/
}

-(void)setRate:(int)rate {
    _rate = rate;
    [self rateStar:self.star1 WithRate:rate andTag:self.star1.tag];
    [self rateStar:self.star2 WithRate:rate andTag:self.star2.tag];
    [self rateStar:self.star3 WithRate:rate andTag:self.star3.tag];
    [self rateStar:self.star4 WithRate:rate andTag:self.star4.tag];
    [self rateStar:self.star5 WithRate:rate andTag:self.star5.tag];
    //self.productionStarsView.rate = rate;
}

-(void)rateStar:(UIImageView*)star WithRate:(int)goldStars andTag:(int)tag{
    if (goldStars>=tag) {
        star.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
    }
    else{
        star.tintColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0];
    }
}

@end
