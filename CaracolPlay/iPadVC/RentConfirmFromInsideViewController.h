//
//  RentConfirmFromInsideViewController.h
//  CaracolPlay
//
//  Created by Diego Vidal on 4/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RentConfirmFromInsideViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedFromIngresarFromInside;
@property (assign, nonatomic) BOOL controllerWasPresentedFromRentFromInside;
@property (assign, nonatomic) BOOL controllerWasPresentedFromContentNotAvailable;
@property (strong, nonatomic) NSString *rentedProductionName;
@property (assign, nonatomic) BOOL userIsLoggedIn;
@end
