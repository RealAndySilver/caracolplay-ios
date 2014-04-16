//
//  ValidateCodePadViewController.h
//  CaracolPlay
//
//  Created by Diego Vidal on 16/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ValidateCodePadViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedFromInitialScreen;
@property (assign, nonatomic) BOOL controllerWasPresentedFromProductionScreen;
@property (assign, nonatomic) BOOL controllerWasPresentedFromContentNotAvailable;
@end
