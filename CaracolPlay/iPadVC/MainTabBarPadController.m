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
#import "MyListsDetailPadViewController.h"
#import "MyListsMasterPadViewController.h"
#import "MorePadViewController.h"

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
        UISplitViewController *myListsSplitViewController = [[UISplitViewController alloc] init];
        MyListsMasterPadViewController *myListsMasterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsMaster"];
        MyListsDetailPadViewController *myListsDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsDetail"];
        myListsSplitViewController.viewControllers = @[myListsMasterVC, myListsDetailVC];
        [myListsSplitViewController.tabBarItem initWithTitle:@"Mis Listas" image:[UIImage imageNamed:@"MyListsTabBarIcon.png"] tag:4];
        
        //5 'Mas' viewcontroller
        MorePadViewController *morePadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MorePad"];
        [morePadViewController.tabBarItem initWithTitle:@"Más" image:[UIImage imageNamed:@"MoreTabBarIcon.png"] tag:5];
        
        self.viewControllers = @[homePadViewController, splitViewController, searchPadViewController, myListsSplitViewController, morePadViewController];
        return;
    }
    self.viewControllers = @[homePadViewController, splitViewController, searchPadViewController];
}

@end
