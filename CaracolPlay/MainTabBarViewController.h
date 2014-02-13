//
//  MainTabBarViewController.h
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "CategoriesViewController.h"
#import "SearchViewController.h"
#import "MyListsViewController.h"
#import "ConfigurationViewController.h"
#import "MyNavigationController.h"

@interface MainTabBarViewController : UITabBarController <UITabBarControllerDelegate>
@property (nonatomic) BOOL userDidSkipRegisterProcess;
@end
