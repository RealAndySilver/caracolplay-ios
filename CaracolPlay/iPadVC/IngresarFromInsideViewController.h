//
//  IngresarFromInsideViewController.h
//  CaracolPlay
//
//  Created by Developer on 28/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IngresarFromInsideViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedFromRentScreen;
@property (assign, nonatomic) BOOL controllerWasPresentFromAlertScreen;
@property (assign, nonatomic) BOOL controllerWasPresentedFromSuscriptionScreen;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productType;
@end
