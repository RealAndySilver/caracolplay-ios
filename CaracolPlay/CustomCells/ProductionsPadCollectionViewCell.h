//
//  ProductionsPadCollectionViewCell.h
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductionsPadCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *productionImageView;
@property (strong, nonatomic) UIImageView *freeImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *starsView;


@property (strong, nonatomic) UIImageView *star1;
@property (strong, nonatomic) UIImageView *star2;
@property (strong, nonatomic) UIImageView *star3;
@property (strong, nonatomic) UIImageView *star4;
@property (strong, nonatomic) UIImageView *star5;


@property (nonatomic) int goldStars;

//@property (assign, nonatomic) BOOL isFree;
@end
