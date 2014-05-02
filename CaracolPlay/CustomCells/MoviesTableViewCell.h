//
//  MoviesTableViewCell.h
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewCell : UITableViewCell
@property (strong, nonatomic) UIImageView *movieImageView;
@property (strong, nonatomic) UILabel *movieTitleLabel;
@property (strong, nonatomic) UIImageView *freeImageView;
@property (strong, nonatomic) UIView *starsView;

@property (strong, nonatomic) UIImageView *star1;
@property (strong, nonatomic) UIImageView *star2;
@property (strong, nonatomic) UIImageView *star3;
@property (strong, nonatomic) UIImageView *star4;
@property (strong, nonatomic) UIImageView *star5;

@property (nonatomic) int stars;
//@property (assign, nonatomic) BOOL showStars;
@end
