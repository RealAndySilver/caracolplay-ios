//
//  SuscriptionConfirmationViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 19/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionConfirmationViewController.h"
#import "MainTabBarViewController.h"
#import "MBHUDView.h"

@interface SuscriptionConfirmationViewController ()

@end

@implementation SuscriptionConfirmationViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //self.navigationController.navigationBarHidden = NO;
}

-(void)UISetup {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    // Background image setup
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:screenFrame];
    backgroundImageView.image = [UIImage imageNamed:@"SuscriptionConfirmationBackground.png"];
    [self.view addSubview:backgroundImageView];
    
    // 2. Textview
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(30.0, screenFrame.size.height/2 - 10.0, screenFrame.size.width - 60.0, 150.0)];
    textView.backgroundColor = [UIColor clearColor];
    textView.text = @"Tu pago ha sido realizado de forma satisfactoria. Ahora puedes disfrutar ilimitadamente de nuestro contenido durante una año";
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont systemFontOfSize:15.0];
    textView.userInteractionEnabled = NO;
    textView.textColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    //2. Set the enter and suscribe button
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, 410.0, screenFrame.size.width - 60.0, 50.0)];
    [continueButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(goToHomeViewController) forControlEvents:UIControlEventTouchUpInside];
    continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:continueButton];
}

#pragma mark - Actions 

-(void)goToHomeViewController {
    if (self.controllerWasPresentedFromInitialScreen) {
        MainTabBarViewController *mainTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBar animated:YES completion:nil];
    } else {
        //Create the 'Mis Listas' tab & 'Mas' tab
        [self createAditionalTabsInTabBarController];
        [MBHUDView hudWithBody:@"Suscripcion Exitosa" type:MBAlertViewHUDTypeCheckmark hidesAfter:2.0 show:YES];
        
        NSArray *viewControllers = [self.navigationController viewControllers];
        for (int i = [viewControllers count] - 1; i >= 0; i--){
            id obj = [viewControllers objectAtIndex:i];
            if ([obj isKindOfClass:[TelenovelSeriesDetailViewController class]] || [obj isKindOfClass:[MoviesEventsDetailsViewController class]]){
                [self.navigationController popToViewController:obj animated:YES];
                return;
            }
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
