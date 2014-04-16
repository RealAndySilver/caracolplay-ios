//
//  ValidateCodeViewController.h
//  CaracolPlay
//
//  Created by Diego Vidal on 15/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ValidateCodeViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresenteFromInitiaScreen;
@property (assign, nonatomic) BOOL controllerWasPresentedFromProductionScreen;
@property (assign, nonatomic) BOOL controllerWasPresentedFromContentNotAvailable;
@end
