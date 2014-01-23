//
//  TelenovelSeriesTableViewCell.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TelenovelSeriesTableViewCell.h"

@interface TelenovelSeriesTableViewCell()
@property (strong, nonatomic) UILabel *capLabel;
@end

@implementation TelenovelSeriesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
        self.backgroundColor = [UIColor blackColor];
        
        self.capLabel = [[UILabel alloc] init];
        self.capLabel.text = @"Cap";
        self.capLabel.textColor = [UIColor whiteColor];
        self.capLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [self.contentView addSubview:self.capLabel];
        
        self.chapterNumberLabel = [[UILabel alloc] init];
        self.chapterNumberLabel.textColor = [UIColor whiteColor];
        self.chapterNumberLabel.font = [UIFont boldSystemFontOfSize:20.0];
        self.chapterNumberLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.chapterNumberLabel];
        
        self.chapterNameLabel = [[UILabel alloc] init];
        self.chapterNameLabel.textColor = [UIColor whiteColor];
        self.chapterNameLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self.contentView addSubview:self.chapterNameLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.capLabel.frame = CGRectMake(10.0, 5.0, 50.0, 20.0);
    self.chapterNumberLabel.frame = CGRectMake(10.0, 20.0, 25.0, 30.0);
    self.chapterNameLabel.frame = CGRectMake(50.0, contentRect.size.height/2 - 15.0, contentRect.size.width - 50, 30.0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
