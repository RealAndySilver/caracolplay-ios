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
#import "MorePadMasterViewController.h"
#import "MyAccountDetailPadViewController.h"

@interface MainTabBarPadController ()

@end

@implementation MainTabBarPadController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //1. Homescreen view
    HomePadViewController *homePadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    homePadViewController.tabBarItem.title = @"Inicio";
    homePadViewController.tabBarItem.image = [UIImage imageNamed:@"HomeTabBarIcon.png"];
    homePadViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"HomeTabBarIconSelected.png"];
    
    //2. Categories view
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    CategoriesMasterPadViewController *categoriesMasterPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Root"];
    CategoriesDetailPadViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Detail"];
    splitViewController.viewControllers = @[categoriesMasterPadViewController, detailVC];
    splitViewController.tabBarItem.title = @"Categorías";
    splitViewController.tabBarItem.image = [UIImage imageNamed:@"CategoriesTabBarIcon.png"];
    splitViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"CategoriesTabBarIconSelected.png"];
    
    //3. Search View
    SearchPadViewController *searchPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchPad"];
    searchPadViewController.tabBarItem.title = @"Buscar";
    searchPadViewController.tabBarItem.image = [UIImage imageNamed:@"SearchTabBarIcon.png"];
    searchPadViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"SearchTabBarIconSelected.png"];
    
    if (!self.userDidSkipRegisterProcess) {
        //4. MyLists View
        UISplitViewController *myListsSplitViewController = [[UISplitViewController alloc] init];
        MyListsMasterPadViewController *myListsMasterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsMaster"];
        MyListsDetailPadViewController *myListsDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsDetail"];
        myListsSplitViewController.viewControllers = @[myListsMasterVC, myListsDetailVC];
        myListsSplitViewController.tabBarItem.title = @"Mis Listas";
        myListsSplitViewController.tabBarItem.image = [UIImage imageNamed:@"MyListsTabBarIcon.png"];
        myListsSplitViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"MyListsTabBarIconSelected.png"];
        
        //5 'Mas' splitview controller
        UISplitViewController *moreSplitViewController = [[UISplitViewController alloc] init];
        MorePadMasterViewController *morePadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MorePadMaster"];
        MyAccountDetailPadViewController *myAccountDetailPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAccountDetailPad"];
        moreSplitViewController.viewControllers = @[morePadViewController, myAccountDetailPadVC];
        moreSplitViewController.tabBarItem.title = @"Más";
        moreSplitViewController.tabBarItem.image = [UIImage imageNamed:@"MoreTabBarIcon.png"];
        moreSplitViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"MoreTabBarIconSelected.png"];
        
        self.viewControllers = @[homePadViewController, splitViewController, searchPadViewController, myListsSplitViewController, moreSplitViewController];
        return;
    }
    self.viewControllers = @[homePadViewController, splitViewController, searchPadViewController];
}
@end
