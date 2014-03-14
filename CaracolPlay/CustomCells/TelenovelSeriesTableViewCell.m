//
//  TelenovelSeriesTableViewCell.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TelenovelSeriesTableViewCell.h"
#import "AddToListView.h"

@interface TelenovelSeriesTableViewCell()
@property (strong, nonatomic) UILabel *capLabel;
@property (strong, nonatomic) UIButton *addToListButton;
@end

@implementation TelenovelSeriesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
        self.backgroundColor = [UIColor clearColor];
        
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
        
        self.addToListButton = [[UIButton alloc] init];
        [self.addToListButton setImage:[UIImage imageNamed:@"AddToListIcon.png"] forState:UIControlStateNormal];
        [self.addToListButton addTarget:self action:@selector(showAddToListView) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.addToListButton];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    self.capLabel.frame = CGRectMake(12.0, 5.0, 50.0, 20.0);
    self.chapterNumberLabel.frame = CGRectMake(5.0, 20.0, 40.0, 30.0);
    self.chapterNameLabel.frame = CGRectMake(50.0, contentRect.size.height/2 - 15.0, contentRect.size.width - 100, 30.0);
    self.addToListButton.frame = CGRectMake(contentRect.size.width - 45.0, contentRect.size.height/2.0 - 14.0, 30.0, 30.0);
}

-(void)showAddToListView {
    [self.delegate addButtonWasSelectedInCell:self];
}

@end
