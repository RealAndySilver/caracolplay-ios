//
//  RedeemCodeAlertViewController.h
//  CaracolPlay
//
//  Created by Diego Vidal on 19/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedeemCodeAlertViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedFromInitialScreen;
@property (assign, nonatomic) BOOL controllerWasPresentedFromProductionScreen;
@property (assign, nonatomic) BOOL userWasLogout;
@end
