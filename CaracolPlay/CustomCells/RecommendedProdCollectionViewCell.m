//
//  RecommendedProdCollectionViewCell.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RecommendedProdCollectionViewCell.h"

@interface RecommendedProdCollectionViewCell()
@property (strong, nonatomic) UIView *shadowView;
@end

@implementation RecommendedProdCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.shadowView = [[UIView alloc] init];
        self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shadowView.layer.shadowOffset = CGSizeMake(4.0, 4.0);
        self.shadowView.layer.shadowOpacity = 1.0;
        self.shadowView.layer.shadowRadius = 4.0;
        [self.contentView addSubview:self.shadowView];
        
        self.cellImageView = [[UIImageView alloc] init];
        self.cellImageView.clipsToBounds = YES;
        self.cellImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.shadowView addSubview:self.cellImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGRect frame;
    frame = CGRectMake(10.0, 10.0, contentRect.size.width - 20.0, contentRect.size.height - 20.0);
    self.shadowView.frame = frame;
    self.cellImageView.frame = CGRectMake(0.0, 0.0, self.shadowView.frame.size.width, self.shadowView.frame.size.height);
}

@end
