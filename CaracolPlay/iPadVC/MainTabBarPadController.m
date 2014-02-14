//
//  MainTabBarPadController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MainTabBarPadController.h"
#import "HomePadViewController.h"
#import "CategoriesMasterPadViewController.h"
#import "CategoriesDetailPadViewController.h"
#import "SearchPadViewController.h"
#import "MyListsPadViewController.h"

@interface MainTabBarPadController ()

@end

@implementation MainTabBarPadController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //1. Homescreen view
    HomePadViewController *homePadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    [homePadViewController.tabBarItem initWithTitle:@"Inicio" image:[UIImage imageNamed:@"HomeTabBarIcon.png"] tag:1];
    
    //2. Categories view
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    CategoriesMasterPadViewController *categoriesMasterPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Root"];
    CategoriesDetailPadViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Detail"];
    splitViewController.viewControllers = @[categoriesMasterPadViewController, detailVC];
    [splitViewController.tabBarItem initWithTitle:@"Categorías" image:[UIImage imageNamed:@"CategoriesTabBarIcon.png"] tag:4];
    
    //3. Search View
    SearchPadViewController *searchPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchPad"];
    [searchPadViewController.tabBarItem initWithTitle:@"Buscar" image:[UIImage imageNamed:@"SearchTabBarIcon.png"] tag:3];
    
    if (!self.userDidSkipRegisterProcess) {
        //4. MyLists View
        MyListsPadViewController *myListsPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsPad"];
        [myListsPadViewController.tabBarItem initWithTitle:@"Mis Listas" image:[UIImage imageNamed:@"MyListsTabBarIcon.png"] tag:4];
        
        self.viewControllers = @[homePadViewController, splitViewController, searchPadViewController, myListsPadViewController];
        return;
    }
    self.viewControllers = @[homePadViewController, splitViewController, searchPadViewController];
}

@end
