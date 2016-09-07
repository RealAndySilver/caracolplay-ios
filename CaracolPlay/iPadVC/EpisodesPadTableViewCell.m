//
//  EpisodesPadTableViewCell.m
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "EpisodesPadTableViewCell.h"

@interface EpisodesPadTableViewCell()
@property (strong, nonatomic) UIImageView *playIconImageView;
@property (strong, nonatomic) UIButton *addToListButton;
@end

@implementation EpisodesPadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.episodeNumberLabel = [[UILabel alloc] init];
        self.episodeNumberLabel.textColor = [UIColor darkGrayColor];
        self.episodeNumberLabel.font = [UIFont  boldSystemFontOfSize:15.0];
        [self.contentView addSubview:self.episodeNumberLabel];
        
        self.episodeNameLabel = [[UILabel alloc] init];
        self.episodeNameLabel.textColor = [UIColor darkGrayColor];
        self.episodeNameLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [self.contentView addSubview:self.episodeNameLabel];
        
        self.playIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlayIcon.png"]];
        self.playIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.playIconImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.playIconImageView];
        
        /*self.addToListButton = [[UIButton alloc] init];
        [self.addToListButton setImage:[UIImage imageNamed:@"AddToListIcon.png"] forState:UIControlStateNormal];
        [self.addToListButton addTarget:self action:@selector(addToList) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.addToListButton];*/
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.episodeNumberLabel.frame = CGRectMake(20.0, contentRect.size.height/2 - 15.0, 50.0, 30.0);
    self.episodeNameLabel.frame = CGRectMake(70.0, contentRect.size.height/2 - 15.0, 300.0, 30.0);
    self.playIconImageView.frame = CGRectMake(contentRect.size.width - 30.0, contentRect.size.height/2.0 - 10.0, 20.0, 20.0);
    self.addToListButton.frame = CGRectMake(contentRect.size.width - 80.0, contentRect.size.height/2.0 - 15.0, 30.0, 30.0);
}

#pragma mark - Actions 

-(void)addToList {
    NSLog(@"me tocasteeee veee");
    [self.delegate addButtonWasSelectedInCell:self];
}

@end
