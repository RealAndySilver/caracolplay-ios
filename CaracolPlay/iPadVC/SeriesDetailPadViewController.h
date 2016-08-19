//
//  SeriesDetailPadViewController.h
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TelenovelSeriesDetailDelegate
-(void)productionRemovedWithId:(NSString *)productionId;
-(void)productionAddedToMyListWithId:(NSString *)productionId;
@end

@interface SeriesDetailPadViewController : UIViewController
@property (strong, nonatomic) id <TelenovelSeriesDetailDelegate> delegate;
@property (strong, nonatomic) NSString *productID;
@end
