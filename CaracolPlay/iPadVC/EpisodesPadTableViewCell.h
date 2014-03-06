//
//  EpisodesPadTableViewCell.h
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EpisodesPadTableViewCell;

@protocol EpisodesPadTableViewCellDelegate <NSObject>
-(void)addButtonWasSelectedInCell:(EpisodesPadTableViewCell *)cell;
@end

@interface EpisodesPadTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *episodeNumberLabel;
@property (strong, nonatomic) UILabel *episodeNameLabel;
@property (strong, nonatomic) id <EpisodesPadTableViewCellDelegate> delegate;
@end
