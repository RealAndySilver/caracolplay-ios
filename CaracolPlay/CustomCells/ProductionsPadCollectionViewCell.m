//
//  ProductionsPadCollectionViewCell.m
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ProductionsPadCollectionViewCell.h"

@interface ProductionsPadCollectionViewCell()
@property (strong, nonatomic) UIView *shadowView;
//@property (strong, nonatomic) UIImageView *freeImageView;
@end

@implementation ProductionsPadCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.shadowView = [[UIView alloc] init];
        self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shadowView.layer.shadowOffset = CGSizeMake(8.0, 8.0);
        self.shadowView.layer.shadowOpacity = 0.6;
        self.shadowView.layer.shadowRadius = 5.0;
        [self.contentView addSubview:self.shadowView];
        
        self.productionImageView = [[UIImageView alloc] init];
        self.productionImageView.backgroundColor = [UIColor clearColor];
        self.productionImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.productionImageView.clipsToBounds = YES;
        [self.shadowView addSubview:self.productionImageView];
        
        self.freeImageView = [[UIImageView alloc] init];
        self.freeImageView.backgroundColor = [UIColor clearColor];
        self.freeImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.freeImageView.clipsToBounds = YES;
        [self.productionImageView addSubview:self.freeImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self.productionImageView addSubview:self.titleLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.shadowView.frame = CGRectMake(10.0, 10.0, contentRect.size.width - 20.0, contentRect.size.height - 60.0);
    self.productionImageView.frame = CGRectMake(0.0, 0.0, self.shadowView.frame.size.width, self.shadowView.frame.size.height);
    self.freeImageView.frame = CGRectMake(0.0, self.productionImageView.frame.size.height - 20.0, self.productionImageView.frame.size.width, 20.0);
    self.titleLabel.frame = CGRectMake(0.0, self.productionImageView.frame.size.height - 40.0, self.productionImageView.frame.size.width, 40.0);
    //[self createStarsImageViewsWithGoldStarsNumber:self.goldStars];
}

-(void)setGoldStars:(int)goldStars {
    _goldStars = goldStars;
    [self createStarsImageViewsWithGoldStarsNumber:goldStars];
}

#pragma mark - Custom Methods

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    
    for (int i = 1; i < 6; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0*i, 210.0, 20.0, 20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars >= i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:starImageView];
    }
}

@end
