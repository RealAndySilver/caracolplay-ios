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
    homeNavigationController.tabBarItem.title = @"Inicio";
    homeNavigationController.tabBarItem.image = [UIImage imageNamed:@"HomeTabBarIcon.png"];
    homeNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"HomeTabBarIconSelected.png"];
    
    //2. Second view of the TabBar - Categories
    CategoriesViewController *categoriesViewController;
    MyNavigationController *categoriesNavigationController;
    categoriesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
    categoriesNavigationController = [[MyNavigationController alloc] initWithRootViewController:categoriesViewController];
    categoriesNavigationController.tabBarItem.title = @"Categorías";
    categoriesNavigationController.tabBarItem.image = [UIImage imageNamed:@"CategoriesTabBarIcon.png"];
    categoriesNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"CategoriesTabBarIconSelected.png"];
    
    //3. Third view of the TabBar - Search
    SearchViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Search"];
    MyNavigationController *SearchNavigationController = [[MyNavigationController alloc] initWithRootViewController:searchViewController];
    SearchNavigationController.tabBarItem.title = @"Buscar";
    SearchNavigationController.tabBarItem.image = [UIImage imageNamed:@"SearchTabBarIcon.png"];
    SearchNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"SearchTabBarIconSelected.png"];
    
    if (!self.userDidSkipRegisterProcess) {
        //4. Fourth view of the TabBar - MyLists
        MyListsViewController *myListsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyLists"];
        MyNavigationController *myListsNavigationController = [[MyNavigationController alloc] initWithRootViewController:myListsViewController];
        myListsNavigationController.tabBarItem.title = @"Mis Listas";
        myListsNavigationController.tabBarItem.image = [UIImage imageNamed:@"MyListsTabBarIcon.png"];
        myListsNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"MyListsTabBarIconSelected.png"];
        
        //5. Fifth view of the TabBar - My Account
        ConfigurationViewController *myAccountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Configuration"];
        MyNavigationController*myAccountNavigationController = [[MyNavigationController alloc] initWithRootViewController:myAccountViewController];
        myAccountNavigationController.tabBarItem.title = @"Más";
        myAccountNavigationController.tabBarItem.image = [UIImage imageNamed:@"MoreTabBarIcon.png"];
        myAccountNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"MoreTabBarIconSelected.png"];
        
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
