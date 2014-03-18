//
//  RentContentConfirmationViewController.m
//  CaracolPlay
//
//  Created by Developer on 7/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RentContentConfirmationViewController.h"
#import "MyNavigationController.h"
#import "ConfigurationViewController.h"
#import "MyListsViewController.h"
#import "MBHUDView.h"
#import "TelenovelSeriesDetailViewController.h"
#import "MoviesEventsDetailsViewController.h"

@interface RentContentConfirmationViewController ()

@end

@implementation RentContentConfirmationViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Make the navigation bar totally translucent
    self.navigationController.navigationBar.hidden = YES;
    /*[self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];*/
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    /*[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;*/
}

-(void)UISetup {
    NSLog(@"view bounds: %@", NSStringFromCGRect(self.view.bounds));
    //1. Background image view
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"RentContentAlertBackground.png"];
    [self.view addSubview:backgroundImageView];
    
    //2. detail textview
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 250.0, self.view.bounds.size.width - 40.0, 80.0)];
    textView.text = @"El pago se ha realizado de forma satisfactoria. Ahora puedes disfrutar del siguiente contenido";
    textView.textColor = [UIColor whiteColor];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:textView];
    
    //3. other textview
    UITextView *productionNameTextview = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 340.0, self.view.bounds.size.width - 40.0, 60.0)];
    productionNameTextview.text = @"Mentiras Perfectas Mentiras Perfectas Mentiras Perfectas";
    productionNameTextview.textAlignment = NSTextAlignmentCenter;
    productionNameTextview.backgroundColor = [UIColor clearColor];
    productionNameTextview.font = [UIFont systemFontOfSize:15.0];
    productionNameTextview.textColor = [UIColor whiteColor];
    [self.view addSubview:productionNameTextview];
    
    //Continue button
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, productionNameTextview.frame.origin.y + productionNameTextview.frame.size.height + 20.0, self.view.bounds.size.width - 60.0, 50.0)];
    [continueButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [continueButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:continueButton];
}

#pragma mark - Actions 

-(void)goToHomeScreen {
    [MBHUDView hudWithBody:@"Alquiler Exitoso" type:MBAlertViewHUDTypeCheckmark hidesAfter:2.0 show:YES];
    [self createAditionalTabsInTabBarController];
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (int i = [viewControllers count] - 1; i >= 0; i--){
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[TelenovelSeriesDetailViewController class]] || [obj isKindOfClass:[MoviesEventsDetailsViewController class]]){
            [self.navigationController popToViewController:obj animated:YES];
            return;
        }
     }
}

-(void)createAditionalTabsInTabBarController {
    //4. Fourth view of the TabBar - My Lists
    MyListsViewController *myListsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyLists"];
    MyNavigationController *myListsNavigationController = [[MyNavigationController alloc] initWithRootViewController:myListsViewController];
    [myListsNavigationController.tabBarItem initWithTitle:@"Mis Listas" image:[UIImage imageNamed:@"MyListsTabBarIcon.png"] tag:4];
    
    //5. Fifth view of the TabBar - My Account
    ConfigurationViewController *myAccountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Configuration"];
    MyNavigationController*myAccountNavigationController = [[MyNavigationController alloc] initWithRootViewController:myAccountViewController];
    [myAccountNavigationController.tabBarItem initWithTitle:@"Mas" image:[UIImage imageNamed:@"MoreTabBarIcon.png"] tag:5];
    
    NSMutableArray *viewControllersArray = [self.tabBarController.viewControllers mutableCopy];
    [viewControllersArray addObject:myListsNavigationController];
    [viewControllersArray addObject:myAccountNavigationController];
    self.tabBarController.viewControllers = viewControllersArray;
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
