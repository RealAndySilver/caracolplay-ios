//
//  RedeemCodeViewController.h
//  CaracolPlay
//
//  Created by Developer on 30/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedeemCodeViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedFromInitialScreen;
@property (assign, nonatomic) BOOL controllerWasPresentedFromProductionScreen;
@property (strong, nonatomic) NSString *redeemedCode;
@end
