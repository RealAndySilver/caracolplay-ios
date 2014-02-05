//
//  MainTabBarPadController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MainTabBarPadController.h"
#import "HomePadViewController.h"
#import "CategoriesPadViewController.h"

@interface MainTabBarPadController ()

@end

@implementation MainTabBarPadController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //1. Homescreen view
    HomePadViewController *homePadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    [homePadViewController.tabBarItem initWithTitle:@"Inicio" image:[UIImage imageNamed:@"HomeTabBarIcon.png"] tag:1];
    
    //2. Categories view
    CategoriesPadViewController *categoriesPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
    //UINavigationController *categoriesNavigationController = [[UINavigationController alloc] initWithRootViewController:categoriesPadViewController];
    [categoriesPadViewController.tabBarItem initWithTitle:@"Categorías" image:[UIImage imageNamed:@"CategoriesTabBarIcon.png"] tag:2];
    
    self.viewControllers = @[homePadViewController, categoriesPadViewController];
}

@end
