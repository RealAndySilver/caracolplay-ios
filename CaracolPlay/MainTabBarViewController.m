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
    
    //3. Third view of the TabBar - Search
    SearchViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Search"];
    UINavigationController *SearchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [SearchNavigationController.tabBarItem initWithTitle:@"Buscar" image:Nil tag:3];
    
    //4. Fourth view of the TabBar - MyLists
    MyListsViewController *myListsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyLists"];
    UINavigationController *myListsNavigationController = [[UINavigationController alloc] initWithRootViewController:myListsViewController];
    [myListsNavigationController.tabBarItem initWithTitle:@"Mis Listas" image:nil tag:4];
    
    //5. Fifth view of the TabBar - My Account
    MyAccountViewController *myAccountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAccount"];
    UINavigationController *myAccountNavigationController = [[UINavigationController alloc] initWithRootViewController:myAccountViewController];
    [myAccountNavigationController.tabBarItem initWithTitle:@"Mi Cuenta" image:nil tag:5];
    
    self.viewControllers = @[homeNavigationController, categoriesNavigationController, SearchNavigationController, myListsNavigationController, myAccountNavigationController];
    self.selectedIndex = 0;
}

@end
