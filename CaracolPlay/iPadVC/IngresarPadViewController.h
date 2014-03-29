//
//  IngresarPadViewController.h
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IngresarPadViewController : UIViewController
@property (assign, nonatomic) CGFloat viewHeight;
@property (assign, nonatomic) CGFloat viewWidth;
@property (nonatomic) BOOL controllerWasPresentedFromInitialScreen;
@property (nonatomic) BOOL controllerWasPresentedFromProductionScreen;
@property (nonatomic) BOOL controllerWasPresentedFromInitialSuscriptionScreen;
@property (nonatomic) BOOL controllerWasPresentedFromProductionSuscriptionScreen;
@end
