//
//  RedeemCodeFormViewController.h
//  CaracolPlay
//
//  Created by Diego Vidal on 9/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedeemCodeFormViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedFromInitialScreen;
@property (assign, nonatomic) BOOL controllerWasPresentedFromProductionScreen;
@property (strong, nonatomic) NSString *redeemCode;
@end
