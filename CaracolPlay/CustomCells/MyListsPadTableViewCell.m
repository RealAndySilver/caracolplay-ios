//
//  MyListsPadTableViewCell.m
//  CaracolPlay
//
//  Created by Developer on 17/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsPadTableViewCell.h"

@interface MyListsPadTableViewCell()
@property (strong, nonatomic) UIImageView *playIconImageView;
@property (strong, nonatomic) UIView *shadowView;
@end

@implementation MyListsPadTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.shadowView = [[UIView alloc] init];
        //self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        //self.shadowView.layer.shadowOffset = CGSizeMake(4.0, 4.0);
        //self.shadowView.layer.shadowOpacity = 0.8;
        //self.shadowView.layer.shadowRadius = 5.0;
        [self.contentView addSubview:self.shadowView];
        
        // 1. Production image view
        self.productionImageView = [[UIImageView alloc] init];
        self.productionImageView.clipsToBounds = YES;
        self.productionImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.shadowView addSubview:self.productionImageView];
        
        // 2. Production name label setup
        self.productionNameLabel = [[UILabel alloc] init];
        self.productionNameLabel.textColor = [UIColor darkGrayColor];
        self.productionNameLabel.font = [UIFont boldSystemFontOfSize:20.0];
        [self.contentView addSubview:self.productionNameLabel];
        
        //3. Production detail label setup
        self.productionDetailLabel = [[UILabel alloc] init];
        self.productionDetailLabel.textColor = [UIColor whiteColor];
        self.productionDetailLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:self.productionDetailLabel];
        
        // 4. Play icon image view setup
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.playIconImageView = [[UIImageView alloc] init];
            self.playIconImageView.clipsToBounds = YES;
            self.playIconImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.playIconImageView.image = [UIImage imageNamed:@"PlayIcon.png"];
            [self.contentView addSubview:self.playIconImageView];
        }
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    
    //Set subviews frames
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.shadowView.frame = CGRectMake(50.0, 10.0, 60.0, bounds.size.height - 20.0);
        self.productionImageView.frame = CGRectMake(0.0, 0.0, self.shadowView.frame.size.width, self.shadowView.frame.size.height);
        self.productionNameLabel.frame = CGRectMake(130.0, bounds.size.height/2 - 30.0, 500.0, 30.0);
        self.productionDetailLabel.frame = CGRectMake(130.0, bounds.size.height/2, 500.0, 30.0);
        self.playIconImageView.frame = CGRectMake(bounds.size.width - 50.0, bounds.size.height/2 - 12.0, 24.0, 24.0);
    } else {
        self.productionImageView.frame = CGRectMake(10.0, 10.0, 80.0, bounds.size.height - 20.0);
        self.productionNameLabel.frame = CGRectMake(110.0, bounds.size.height/2 - 30.0, bounds.size.width - 130.0, 30.0);
        self.productionDetailLabel.frame = CGRectMake(110.0, bounds.size.height/2, bounds.size.width - 130.0, 50.0);
        self.productionDetailLabel.numberOfLines = 2;
    }
}

@end
