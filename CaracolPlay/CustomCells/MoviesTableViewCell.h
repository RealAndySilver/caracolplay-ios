//
//  MoviesTableViewCell.h
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StarsView;

@interface MoviesTableViewCell : UITableViewCell
@property (strong, nonatomic) UIImageView *movieImageView;
@property (strong, nonatomic) UILabel *movieTitleLabel;
@property (strong, nonatomic) UIImageView *freeImageView;
@property (nonatomic) int stars;
@property (assign, nonatomic) BOOL showStars;
@end
