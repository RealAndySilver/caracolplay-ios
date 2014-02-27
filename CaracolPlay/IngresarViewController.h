//
//  IngresarViewController.h
//  CaracolPlay
//
//  Created by Developer on 30/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IngresarViewController : UIViewController
/* Used to identify is the controller was presented from the initial screen, 
 or from a production screen (if the user isn't allowed to watch a production,
 he could be taken to this screen to enter with it's user.)*/
@property (nonatomic) BOOL controllerWasPresentedFromInitialScreen;
@end
