//
//  MoviesViewController.h
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoviesTableViewCell.h"
#import "MoviesEventsDetailsViewController.h"
#import "TelenovelSeriesDetailViewController.h"

@interface ProductionsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *navigationBarTitle;
@property (strong, nonatomic) NSString *categoryID;
@property (strong, nonatomic) NSString *displayType;
@end
