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
    CategoriesPadViewController *categoriesPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
    [categoriesPadViewController.tabBarItem initWithTitle:@"Categorías" image:[UIImage imageNamed:@"CategoriesTabBarIcon.png"] tag:2];
    
    //3. Search View
    SearchPadViewController *searchPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchPad"];
    [searchPadViewController.tabBarItem initWithTitle:@"Buscar" image:[UIImage imageNamed:@"SearchTabBarIcon.png"] tag:3];
    
    //4. MyLists View
    MyListsPadViewController *myListsPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsPad"];
    [myListsPadViewController.tabBarItem initWithTitle:@"Mis Listas" image:[UIImage imageNamed:@"MyListsTabBarIcon.png"] tag:4];
    
    self.viewControllers = @[homePadViewController, categoriesPadViewController, searchPadViewController, myListsPadViewController];
}

@end
