//
//  IngresarViewController.m
//  CaracolPlay
//
//  Created by Developer on 30/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarViewController.h"
#import "MainTabBarViewController.h"
#import "FXBlurView.h"
#import "FileSaver.h"
#import "MBHUDView.h"
#import "RentContentConfirmationViewController.h"
#import "CPIAPHelper.h"

@interface IngresarViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@end

@implementation IngresarViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Register as an observer of the notification -UserDidSuscribe.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
    
    self.nameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    [self.enterButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    //Create a tap gesture to dismiss the keyboard when the user taps
    //outside of it.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tapGesture];
    
    /*self.blurView = [[FXBlurView alloc] init];
    self.blurView.blurRadius = 7.0;
    self.blurView.alpha = 0.0;
    [self.view addSubview:self.blurView];
    
    self.navigationBarBlurView = [[FXBlurView alloc] init];
    self.navigationBarBlurView.blurRadius = 7.0;
    self.navigationBarBlurView.alpha = 0.0;
    [self.navigationController.navigationBar addSubview:self.navigationBarBlurView];
    [self.navigationController.navigationBar bringSubviewToFront:self.navigationBarBlurView];*/
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Custom Methods

-(void)tap {
    //Used to dismiss the keyboard when the user taps outside of it.
    [self.nameTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

-(void)goToHomeScreen {
    if (([self.nameTextfield.text length] > 0) && [self.passwordTextfield.text length]) {
        //Testing purposes only. If the user has entered information in both textfields,
        //make a succesful login and save a key to know that the user is login.
        FileSaver *fileSaver = [[FileSaver alloc] init];
        [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
        
        if (self.controllerWasPresentedFromInitialScreen) {
            [MBHUDView hudWithBody:@"Ingreso Exitoso" type:MBAlertViewHUDTypeCheckmark hidesAfter:2.0 show:YES];
            //Present the home screen modally if the user came here from the initial screen.
            MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
            [self presentViewController:mainTabBarVC animated:YES completion:nil];
            
        } else if (self.controllerWasPresentedFromRentScreen) {
            [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
                if (success) {
                    IAPProduct *product = [products lastObject];
                    [[CPIAPHelper sharedInstance] buyProduct:product];
                }
            }];
            
        } else {
            //Pop all view controllers to the root view controller (home screen) if the
            //user came here from a production screen.
            [MBHUDView hudWithBody:@"Ingreso Exitoso" type:MBAlertViewHUDTypeCheckmark hidesAfter:2.0 show:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self createAditionalTabsInTabBarController];
        }
        
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Error en la información. Por favor revisa que hayas completado todos los campos correctamente." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)createAditionalTabsInTabBarController {
    //This method create the two aditional tab bars in the tab bar. this is neccesary because
    //when the user is logout, we activate just three tabs, but when the user is log in, we activate
    //the five tabs.
    
    //4. Fourth view of the TabBar - MyLists
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

#pragma mark - Notification Handlers 

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    RentContentConfirmationViewController *rentContentVC =
        [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentConfirmation"];
    [self.navigationController pushViewController:rentContentVC animated:YES];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
