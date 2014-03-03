//
//  SearchPadCollectionViewCell.h
//  CaracolPlay
//
//  Created by Developer on 3/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StarsView;

@interface SearchPadCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *productionImageView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) StarsView *productionStarsView;
@end
