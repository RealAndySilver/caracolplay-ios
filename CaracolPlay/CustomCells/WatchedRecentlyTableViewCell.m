//
//  WatchedRecentlyTableViewCell.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "WatchedRecentlyTableViewCell.h"

@implementation WatchedRecentlyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.mainImageView = [[UIImageView alloc] init];
        self.mainImageView.backgroundColor = [UIColor blueColor];
        self.mainImageView.clipsToBounds = YES;
        self.mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.mainImageView];
        
        self.mainTitleLabel = [[UILabel alloc] init];
        self.mainTitleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        self.mainTitleLabel.numberOfLines = 1;
        self.mainTitleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.mainTitleLabel];
        
        self.secondaryTitleLabel = [[UILabel alloc] init];
        self.secondaryTitleLabel.font = [UIFont italicSystemFontOfSize:12.0];
        self.secondaryTitleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.secondaryTitleLabel];
        
        self.chapterNumberLabel = [[UILabel alloc] init];
        self.chapterNumberLabel.font = [UIFont italicSystemFontOfSize:12.0];
        self.chapterNumberLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.chapterNumberLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.mainImageView.frame = CGRectMake(10.0, 10.0, 80.0, contentRect.size.height - 20.0);
    self.mainTitleLabel.frame = CGRectMake(self.mainImageView.frame.origin.x + self.mainImageView.frame.size.width + 10.0, contentRect.size.height/2 - 10.0, 200.0, 20.0);
    self.secondaryTitleLabel.frame = CGRectMake(self.mainTitleLabel.frame.origin.x, self.mainTitleLabel.frame.origin.y + self.mainTitleLabel.frame.size.height, 200.0, 20.0);
    self.chapterNumberLabel.frame = CGRectMake(self.mainTitleLabel.frame.origin.x, self.mainTitleLabel.frame.origin.y + self.mainTitleLabel.frame.size.height + 15.0, 200.0, 20.0);
    
    [self createStarsImageViewsWithGoldStarsNumber:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom Methods

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mainTitleLabel.frame.origin.x + (i*12),
                                                                                   self.mainTitleLabel.frame.origin.y - 12.0,
                                                                                   12.0,
                                                                                   12.0)];
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
