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
@property (nonatomic) int goldStars;
//@property (assign, nonatomic) BOOL isFree;
@end
