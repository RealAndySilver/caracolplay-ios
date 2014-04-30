//
//  RedeemCodeAlertViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 19/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodeAlertViewController.h"
#import "IngresarViewController.h"
#import "SuscriptionFormViewController.h"
#import "FileSaver.h"
#import "MainTabBarViewController.h"
#import "FileSaver.h"

@interface RedeemCodeAlertViewController ()

@end

@implementation RedeemCodeAlertViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (self.controllerWasPresentedFromProductionScreen) {
        self.tabBarController.tabBar.hidden = YES;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    if (self.controllerWasPresentedFromProductionScreen) {
        self.tabBarController.tabBar.hidden = NO;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(void)UISetup {
    // 1. Background image
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:screenFrame];
    backgroundImageView.image = [UIImage imageNamed:@"RedeemCodeAlertBackground.png"];
    [self.view addSubview:backgroundImageView];
    
    // 2. Textview
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(30.0, screenFrame.size.height/2 - 30.0, screenFrame.size.width - 60.0, 150.0)];
    textView.backgroundColor = [UIColor clearColor];
    textView.text = [@"Tu código ha sido aceptado. Ahora puedes disfrutar del siguiente contenido:\n\n" stringByAppendingString:self.redeemedProductions];
    textView.userInteractionEnabled = NO;
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont systemFontOfSize:15.0];
    textView.textColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    //2. Set the enter and suscribe button
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, self.view.frame.size.height/1.2, screenFrame.size.width - 60.0, 50.0)];
    [enterButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    if (self.controllerWasPresentedFromInitialScreen) {
        [enterButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    } else if (self.controllerWasPresentedFromProductionScreen) {
        [enterButton addTarget:self action:@selector(returnToProduction) forControlEvents:UIControlEventTouchUpInside];
    }
    enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:enterButton];
    
    /*UIButton *suscribeButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, enterButton.frame.origin.y + enterButton.frame.size.height + 10.0, screenFrame.size.width - 60.0, 50.0)];
    [suscribeButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
    [suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [suscribeButton addTarget:self action:@selector(goToSuscribeViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suscribeButton];
    
    //4. Set the 'Skip' button
    UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width - 100.0, 22.0, 100.0, 30.0)];
    [skipButton setTitle:@"Saltar ▶︎" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [skipButton addTarget:self action:@selector(skipAndGoToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];*/
}

#pragma mark - Actions

-(void)returnToProduction {
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (int i = [viewControllers count] - 1; i >= 0; i--){
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[TelenovelSeriesDetailViewController class]] || [obj isKindOfClass:[MoviesEventsDetailsViewController class]]){
            [self.navigationController popToViewController:obj animated:YES];
            
            //Post a notification to tell the production view controller that it needs to display the video inmediatly
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoShouldBeDisplayed" object:nil userInfo:nil];
            break;
        }
    }
    if (self.userWasLogout) {
        //If the user hasn't logged in with his user, create the aditional tabs
        NSLog(@"Cree los tabs");
        [self createAditionalTabsInTabBarController];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];

    } else  {
        NSLog(@"no cree los tabs porque el usuario ya estaba ingresado");
    }
}

-(void)goToHomeScreen {
    NSLog(@"iré al home screen");
    MainTabBarViewController *mainTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    [self presentViewController:mainTabBar animated:YES completion:nil];
}

-(void)createAditionalTabsInTabBarController {
    NSLog(@"crearé los tabs");
    //4. Fourth view of the TabBar - My Lists
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
