//
//  SearchPadCollectionViewCell.h
//  CaracolPlay
//
//  Created by Developer on 3/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPadCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *productionImageView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) UIView *starsView;

@property (strong, nonatomic) UIImageView *star1;
@property (strong, nonatomic) UIImageView *star2;
@property (strong, nonatomic) UIImageView *star3;
@property (strong, nonatomic) UIImageView *star4;
@property (strong, nonatomic) UIImageView *star5;

@property (assign, nonatomic) int rate;
//@property (assign, nonatomic) BOOL showStars;
//@property (strong, nonatomic) StarsView *productionStarsView;
@end
