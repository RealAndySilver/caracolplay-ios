//
//  TelenovelSeriesViewController.h
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TelenovelSeriesTableViewCell.h"

@protocol TelenovelSeriesDetailDelegate
-(void)productionRemovedWithId:(NSString *)productionId;
-(void)productionAddedToMyListWithId:(NSString *)productionId;
@end

@interface TelenovelSeriesDetailViewController : UIViewController
@property (strong, nonatomic) NSString *serieID;
@property (strong, nonatomic) id <TelenovelSeriesDetailDelegate> delegate;
@end
