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
@property (nonatomic) int stars;
@end
