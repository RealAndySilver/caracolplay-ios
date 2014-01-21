//
//  MainTabBarViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

#pragma mark - View Lifecycicle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //1. First view of the TabBar - Home
    HomeViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    [homeNavigationController.tabBarItem initWithTitle:@"Inicio" image:nil tag:1];
    
    //2. Second view of the TabBar - Categories
    CategoriesViewController *categoriesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
    UINavigationController *categoriesNavigationController = [[UINavigationController alloc] initWithRootViewController:categoriesViewController];
    [categoriesNavigationController.tabBarItem initWithTitle:@"Categorías" image:nil tag:2];
    
    self.viewControllers = @[homeNavigationController, categoriesNavigationController];
    self.selectedIndex = 0;
}

@end
