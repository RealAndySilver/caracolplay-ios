//
//  MoviesTableViewCell.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MoviesTableViewCell.h"

@interface MoviesTableViewCell()
//@property (strong, nonatomic) UIImageView *starImageView;
@end

@implementation MoviesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        //1. Create an ImageView to display the movie image
        self.movieImageView = [[UIImageView alloc] init];
        self.movieImageView.clipsToBounds = YES;
        self.movieImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.movieImageView];
        
        //2. Create a label to display the movie title.
        self.movieTitleLabel = [[UILabel alloc] init];
        self.movieTitleLabel.textColor = [UIColor whiteColor];
        self.movieTitleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [self.contentView addSubview:self.movieTitleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGRect frame;
    frame = CGRectMake(10.0, 10.0, 100.0, contentRect.size.height - 20.0);
    self.movieImageView.frame = frame;
    
    frame = CGRectMake(self.movieImageView.frame.origin.x + self.movieImageView.frame.size.width + 10.0,
                       contentRect.size.height/2 - 15.0,
                       contentRect.size.width - (self.movieImageView.frame.origin.x + self.movieImageView.frame.size.width + 10.0),
                       30.0);
    self.movieTitleLabel.frame = frame;
    
    [self createStarsImageViewsWithGoldStarsNumber:self.stars];
}

#pragma mark - Custom Methods

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.movieTitleLabel.frame.origin.x + (i*20),
                                                                                   self.contentView.bounds.size.height/1.7,
                                                                                   20.0,
                                                                                   20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars > i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:starImageView];
    }
}

@end
