//
//  MoviesTableViewCell.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MoviesTableViewCell.h"

@interface MoviesTableViewCell()
@property (strong, nonatomic) UIView *shadowView;
@end

@implementation MoviesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.shadowView = [[UIView alloc] init];
        self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shadowView.layer.shadowOffset = CGSizeMake(4.0, 4.0);
        self.shadowView.layer.shadowOpacity = 0.8;
        self.shadowView.layer.shadowRadius = 4.0;
        [self.contentView addSubview:self.shadowView];
        
        //1. Create an ImageView to display the movie image
        self.movieImageView = [[UIImageView alloc] init];
        self.movieImageView.clipsToBounds = YES;
        self.movieImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.shadowView addSubview:self.movieImageView];
        
        self.freeImageView = [[UIImageView alloc] init];
        self.freeImageView.clipsToBounds = YES;
        self.freeImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.movieImageView addSubview:self.freeImageView];
      
        //2. Create a label to display the movie title.
        self.movieTitleLabel = [[UILabel alloc] init];
        self.movieTitleLabel.textColor = [UIColor whiteColor];
        self.movieTitleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [self.contentView addSubview:self.movieTitleLabel];
        
        //////////////////////////////////////////////////////////
        //Stars
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
    CGRect frame;
    frame = CGRectMake(10.0, 10.0, 80.0, contentRect.size.height - 20.0);
    self.shadowView.frame = frame;
    self.movieImageView.frame = CGRectMake(0.0, 0.0, self.shadowView.frame.size.width, self.shadowView.frame.size.height);
    self.freeImageView.frame = CGRectMake(0.0, self.movieImageView.frame.size.height - 15.0, self.movieImageView.frame.size.width, 15.0);
    
    frame = CGRectMake(self.shadowView.frame.origin.x + self.shadowView.frame.size.width + 10.0,
                       contentRect.size.height/2 - 15.0,
                       contentRect.size.width - (self.shadowView.frame.origin.x + self.shadowView.frame.size.width + 10.0),
                       30.0);
    self.movieTitleLabel.frame = frame;
    self.starsView.frame = CGRectMake(self.movieTitleLabel.frame.origin.x, contentRect.size.height/1.7, 120.0, 20.0);
    
    /*if (self.showStars) {
        [self createStarsImageViewsWithGoldStarsNumber:self.stars];
    }*/
}

#pragma mark - Custom Methods

-(void)setStars:(int)stars {
    _stars = stars;
    [self rateStar:self.star1 WithRate:stars andTag:self.star1.tag];
    [self rateStar:self.star2 WithRate:stars andTag:self.star2.tag];
    [self rateStar:self.star3 WithRate:stars andTag:self.star3.tag];
    [self rateStar:self.star4 WithRate:stars andTag:self.star4.tag];
    [self rateStar:self.star5 WithRate:stars andTag:self.star5.tag];
}

-(void)rateStar:(UIImageView*)star WithRate:(int)goldStars andTag:(int)tag{
    if (goldStars>=tag) {
        star.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
    }
    else{
        star.tintColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0];
    }
}

/*-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.movieTitleLabel.frame.origin.x + (i*20),
                                                                                   self.contentView.bounds.size.height/1.7,
                                                                                   20.0,
                                                                                   20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars > i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithRed:122.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:starImageView];
    }
}*/

@end
