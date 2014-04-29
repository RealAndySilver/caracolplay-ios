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

@implementation ProductionsPadCollectionViewCell{
}

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
        [self.contentView addSubview:self.titleLabel];
        
        self.starsView = [[UIView alloc] init];
        [self.contentView addSubview:self.starsView];
        
        self.star1 = [[UIImageView alloc]initWithFrame:CGRectMake(20.0*1, 0.0, 20.0, 20.0)];
        self.star1.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star1.tag = 1;
        [self.starsView addSubview:self.star1];
        
        self.star2 = [[UIImageView alloc]initWithFrame:CGRectMake(20.0*2, 0.0, 20.0, 20.0)];
        self.star2.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star2.tag = 2;
        [self.starsView addSubview:self.star2];
        
        self.star3 = [[UIImageView alloc]initWithFrame:CGRectMake(20.0*3, 0.0, 20.0, 20.0)];
        self.star3.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star3.tag = 3;
        [self.starsView addSubview:self.star3];
        
        self.star4 = [[UIImageView alloc]initWithFrame:CGRectMake(20.0*4, 0.0, 20.0, 20.0)];
        self.star4.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star4.tag = 4;
        [self.starsView addSubview:self.star4];
        
        self.star5 = [[UIImageView alloc]initWithFrame:CGRectMake(20.0*5, 0.0, 20.0, 20.0)];
        self.star5.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.star5.tag = 5;
        [self.starsView addSubview:self.star5];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.shadowView.frame = CGRectMake(10.0, 10.0, contentRect.size.width - 20.0, 200.0);
    self.productionImageView.frame = CGRectMake(0.0, 0.0, self.shadowView.frame.size.width, self.shadowView.frame.size.height);
    self.freeImageView.frame = CGRectMake(0.0, self.productionImageView.frame.size.height - 20.0, self.productionImageView.frame.size.width, 20.0);
    self.titleLabel.frame = CGRectMake(13.0, self.productionImageView.frame.size.height + 20, self.productionImageView.frame.size.width, 40.0);
    self.starsView.frame = CGRectMake(6.0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, 120.0, 20.0);
    //[self createStarsImageViewsWithGoldStarsNumber:self.goldStars];
}

-(void)setGoldStars:(int)goldStars {
    _goldStars = goldStars;
    [self rateStar:self.star1 WithRate:goldStars andTag:self.star1.tag];
    [self rateStar:self.star2 WithRate:goldStars andTag:self.star2.tag];
    [self rateStar:self.star3 WithRate:goldStars andTag:self.star3.tag];
    [self rateStar:self.star4 WithRate:goldStars andTag:self.star4.tag];
    [self rateStar:self.star5 WithRate:goldStars andTag:self.star5.tag];
}

#pragma mark - Custom Methods
-(void)rateStar:(UIImageView*)star WithRate:(int)goldStars andTag:(int)tag{
        if (goldStars>=tag) {
            star.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        }
        else{
            star.tintColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0];
        }
}
-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    for (int i = 1; i < 6; i++) {
        //UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0 + 20.0*i, 264.0, 20.0, 20.0)];
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0*i, 0.0, 20.0, 20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars >= i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.starsView addSubview:starImageView];
    }
}

-(void)tintStars:(int)goldStars {
    for (int i = 1; i < 6; i++) {
        //UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0 + 20.0*i, 264.0, 20.0, 20.0)];
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0*i, 0.0, 20.0, 20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars >= i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.starsView addSubview:starImageView];
    }
}

@end
