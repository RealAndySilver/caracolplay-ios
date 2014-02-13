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
    MyNavigationController *homeNavigationController = [[MyNavigationController alloc] initWithRootViewController:homeViewController];
    [homeNavigationController.tabBarItem initWithTitle:@"Inicio" image:[UIImage imageNamed:@"HomeTabBarIcon.png"] tag:1];
    
    //2. Second view of the TabBar - Categories
    CategoriesViewController *categoriesViewController;
    MyNavigationController *categoriesNavigationController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        categoriesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
        categoriesNavigationController = [[MyNavigationController alloc] initWithRootViewController:categoriesViewController];
        [categoriesNavigationController.tabBarItem initWithTitle:@"Categorías" image:[UIImage imageNamed:@"CategoriesTabBarIcon.png"] tag:2];
    } /*else {
        categoriesiPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
        categoriesNavigationController = [[MyNavigationController alloc] initWithRootViewController:categoriesiPadViewController];
        [categoriesNavigationController.tabBarItem initWithTitle:@"Categorías" image:[UIImage imageNamed:@"CategoriesTabBarIcon.png"] tag:2];
    }*/
    
    //3. Third view of the TabBar - Search
    SearchViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Search"];
    MyNavigationController *SearchNavigationController = [[MyNavigationController alloc] initWithRootViewController:searchViewController];
    [SearchNavigationController.tabBarItem initWithTitle:@"Buscar" image:[UIImage imageNamed:@"SearchTabBarIcon.png"] tag:3];
    
    if (!self.userDidSkipRegisterProcess) {
        //4. Fourth view of the TabBar - MyLists
        MyListsViewController *myListsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyLists"];
        MyNavigationController *myListsNavigationController = [[MyNavigationController alloc] initWithRootViewController:myListsViewController];
        [myListsNavigationController.tabBarItem initWithTitle:@"Mis Listas" image:[UIImage imageNamed:@"MyListsTabBarIcon.png"] tag:4];
        
        //5. Fifth view of the TabBar - My Account
        ConfigurationViewController *myAccountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Configuration"];
        MyNavigationController*myAccountNavigationController = [[MyNavigationController alloc] initWithRootViewController:myAccountViewController];
        [myAccountNavigationController.tabBarItem initWithTitle:@"Mas" image:[UIImage imageNamed:@"ConfigTabBarIcon.png"] tag:5];
        
        self.viewControllers = @[homeNavigationController, categoriesNavigationController, SearchNavigationController, myListsNavigationController, myAccountNavigationController];
        return;
    }
    self.viewControllers = @[homeNavigationController, categoriesNavigationController, SearchNavigationController];
}

- (BOOL)shouldAutorotate
{
    
    return [[[self.viewControllers objectAtIndex:self.selectedIndex]topViewController] shouldAutorotate];
    
}

- (NSUInteger) supportedInterfaceOrientations
{
    return [[[self.viewControllers objectAtIndex:self.selectedIndex]topViewController]supportedInterfaceOrientations];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [[[self.viewControllers objectAtIndex:self.selectedIndex]topViewController] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

/*-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSLog(@"me llamé");
    int selected = self.selectedIndex;
    UIViewController *con = [self.storyboard instantiateViewControllerWithIdentifier:@"Empty"];
    [[self.viewControllers objectAtIndex:selected] pushViewController:con animated:NO];
    [[self.viewControllers objectAtIndex:selected]popViewControllerAnimated:NO];
    [[self.viewControllers objectAtIndex:selected] setDelegate:nil];
}*/

@end
