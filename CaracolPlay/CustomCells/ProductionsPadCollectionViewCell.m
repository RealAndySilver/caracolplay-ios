//
//  ProductionsPadCollectionViewCell.m
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ProductionsPadCollectionViewCell.h"

@implementation ProductionsPadCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.productionImageView = [[UIImageView alloc] init];
        self.productionImageView.backgroundColor = [UIColor clearColor];
        self.productionImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.productionImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.productionImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.productionImageView.frame = CGRectMake(10.0, 10.0, contentRect.size.width - 20.0, contentRect.size.height - 60.0);
    [self createStarsImageViewsWithGoldStarsNumber:self.goldStars];
}

#pragma mark - Custom Methods

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    
    for (int i = 1; i < 6; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0*i, 200.0, 20.0, 20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars >= i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:starImageView];
    }
}

@end
