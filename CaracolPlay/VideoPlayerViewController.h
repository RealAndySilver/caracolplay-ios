//
//  VideoPlayerViewController.h
//  CaracolPlay
//
//  Created by Developer on 24/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerViewController : UIViewController
@property (strong, nonatomic) NSString *embedCode;
@property (assign, nonatomic) int progressSec;
@property (strong, nonatomic) NSString *productID;
@end
