//
//  SearchPadCollectionViewCell.m
//  CaracolPlay
//
//  Created by Developer on 3/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SearchPadCollectionViewCell.h"
#import "StarsView.h"

@interface SearchPadCollectionViewCell()
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) StarsView *productionStarsView;
@end

@implementation SearchPadCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.shadowView = [[UIView alloc] init];
        self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shadowView.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        self.shadowView.layer.shadowOpacity = 0.8;
        self.shadowView.layer.shadowRadius = 3.0;
        [self.contentView addSubview:self.shadowView];
        
        self.productionImageView = [[UIImageView alloc] init];
        self.productionImageView.clipsToBounds = YES;
        self.productionImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.shadowView addSubview:self.productionImageView];
        
        self.productionNameLabel = [[UILabel alloc] init];
        self.productionNameLabel.textColor = [UIColor whiteColor];
        self.productionNameLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.contentView addSubview:self.productionNameLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.shadowView.frame = CGRectMake(10.0, 10.0, 80.0, bounds.size.height - 20.0);
    self.productionImageView.frame = CGRectMake(0.0, 0.0, self.shadowView.frame.size.width, self.shadowView.frame.size.height);
    self.productionNameLabel.frame = CGRectMake(self.productionImageView.frame.origin.x + self.productionImageView.frame.size.width + 30.0, bounds.size.height/2.0 - 30.0, bounds.size.width - (self.productionImageView.frame.origin.x + self.productionImageView.frame.size.width + 20.0), 30.0);
    
    if (self.showStars) {
        self.productionStarsView = [[StarsView alloc]initWithFrame:CGRectMake(self.productionImageView.frame.origin.x + self.productionImageView.frame.size.width + 30.0, bounds.size.height/2.0, 80.0, 16.0) rate:self.rate];
        [self.contentView addSubview:self.productionStarsView];
    }
}

-(void)setRate:(int)rate {
    _rate = rate;
    self.productionStarsView.rate = rate;
}

@end
