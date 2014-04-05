//
//  VideoPlayerPadViewController.h
//  CaracolPlay
//
//  Created by Diego Vidal on 14/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerPadViewController : UIViewController
@property (assign, nonatomic) int progressSec;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *embedCode;
@property (assign, nonatomic) BOOL isWatchingTrailer;
@property (assign, nonatomic) NSString *episodeID;
@end
