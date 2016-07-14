//
//  MoviesEventsViewController.h
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUtilities.h"
#import "RecommendedProdCollectionViewCell.h"
#import <Social/Social.h>
#import "FXBlurView.h"

@protocol MoviesDocumentariesDetailDelegate
-(void)movieRemovedWithId:(NSString *)productionId;
-(void)movieAddedToMyListWithId:(NSString *)productionId;
@end

@interface MoviesEventsDetailsViewController : UIViewController
@property (strong, nonatomic) id <MoviesDocumentariesDetailDelegate> delegate;
@property (strong, nonatomic) NSString *productionID;
@end
