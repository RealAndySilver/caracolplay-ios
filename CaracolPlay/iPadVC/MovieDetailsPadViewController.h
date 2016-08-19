//
//  MovieDetailsViewController.h
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoviesDocumentariesDetailDelegate
-(void)movieRemovedWithId:(NSString *)productionId;
-(void)movieAddedToMyListWithId:(NSString *)productionId;
@end

@interface MovieDetailsPadViewController : UIViewController
@property (strong, nonatomic) id <MoviesDocumentariesDetailDelegate> delegate;
@property (strong, nonatomic) NSString *productID;
@end
