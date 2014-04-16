//
//  RedeemCodeConfirmationPadViewController.h
//  CaracolPlay
//
//  Created by Developer on 28/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedeemCodeConfirmationPadViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedFromSuscriptionAlert;
@property (assign, nonatomic) BOOL controllerWasPresentedFromContentNotAvailable;
@property (assign, nonatomic) BOOL controllerWasPresentedFromInsideRedeemWithExistingUser;
@property (strong, nonatomic) NSString *message;
@end
