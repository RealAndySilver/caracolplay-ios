//
//  TelenovelSeriesTableViewCell.h
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TelenovelSeriesTableViewCell;

@protocol TelenovelSeriesTableViewCellDelegate <NSObject>
@optional
-(void)addButtonWasSelectedInCell:(TelenovelSeriesTableViewCell *)cell;
@end

@interface TelenovelSeriesTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *chapterNumberLabel;
@property (strong, nonatomic) UILabel *chapterNameLabel;
@property (strong, nonatomic) id <TelenovelSeriesTableViewCellDelegate> delegate;
@end
