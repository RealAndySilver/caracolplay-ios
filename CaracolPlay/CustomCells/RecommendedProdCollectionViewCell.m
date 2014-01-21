//
//  RecommendedProdCollectionViewCell.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RecommendedProdCollectionViewCell.h"

@implementation RecommendedProdCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cellImageView = [[UIImageView alloc] init];
        self.cellImageView.clipsToBounds = YES;
        self.cellImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.cellImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGRect frame;
    frame = CGRectMake(10.0, 10.0, contentRect.size.width - 20.0, contentRect.size.height - 20.0);
    self.cellImageView.frame = frame;
}

@end
