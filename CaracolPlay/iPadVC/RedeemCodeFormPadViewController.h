//
//  RedeemCodeFormPadViewController.h
//  CaracolPlay
//
//  Created by Diego Vidal on 12/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedeemCodeFormPadViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedFromSuscriptionAlertScreen;
@property (strong, nonatomic) NSString *redeemedCode;
@end
