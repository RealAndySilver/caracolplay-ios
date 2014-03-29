//
//  IngresarPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarPadViewController.h"
#import "SuscriptionConfirmationPadViewController.h"
#import "MainTabBarPadController.h"
#import "FileSaver.h"
#import "CPIAPHelper.h"
#import "MBHUDView.h"
@import QuartzCore;

@interface IngresarPadViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *shadowView;
@end

@implementation IngresarPadViewController

#pragma mark - View Lifecycle

-(void)UISetup {
    if (self.controllerWasPresentedFromInitialScreen) {
        [self.enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(goToHomeScreenDirectly) forControlEvents:UIControlEventTouchUpInside];
        
    } else if (self.controllerWasPresentedFromInitialSuscriptionScreen) {
        [self.enterButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(enterSuscribeAndGoToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
        
        //Register as an observer of the notification 'UserDidSuscribe'
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidSuscribeNotificationReceived:)
                                                     name:@"UserDidSuscribe"
                                                   object:nil];
        
    }
    
    //1. Background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundIngresarPad.png"]];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //2. 'Cerrar' button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    self.userTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self UISetup];
}


-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //Set our superview bounds, in order to present this view with the correct size (320, 386)
    if (self.viewHeight != 0 && self.viewWidth != 0) {
        //320 597
        NSLog(@"entré acá mirá con los datos %f, %f", self.viewWidth, self.viewHeight);
        self.view.superview.bounds = CGRectMake(0.0, 0.0, self.viewWidth, self.viewHeight);
        self.view.frame = CGRectMake(-10, -10, self.viewWidth + 20.0, self.viewHeight + 20);
    } else {
        NSLog(@"entre aca porque no habia altura ni ancho");
        self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 386.0);
        self.view.frame = CGRectMake(-10.0, -10.0, 320.0, 386.0);
    }
    
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;

    //Set Subviews frames
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 58, -25.0, 88.0, 88.0);
    self.backgroundImageView.frame = self.view.bounds;
}

#pragma mark - Actions

-(void)enterSuscribeAndGoToHomeScreen {
    if (([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0)) {
        [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            [MBHUDView dismissCurrentHUD];
            if (success) {
                IAPProduct *product = [products firstObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)goToHomeScreenDirectly {
    
    if (!([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0)) {
        //Show an alert to the user indicating that the info is wrong
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        //Save a key locally indicating that the user has logged in.
        FileSaver *fileSaver = [[FileSaver alloc] init];
        [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
        
        //The user can pass to the home screen
        MainTabBarPadController *mainTabBarPadController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarPadController animated:YES completion:nil];
    }
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification Handlers

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"Me llegó la notificación de compraaaa");
    //Save a key locally, indicating that the user has logged in.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
    
    //The user can pass to the suscription confirmation view controller
    SuscriptionConfirmationPadViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmationPad"];
    suscriptionConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    suscriptionConfirmationVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:suscriptionConfirmationVC animated:YES completion:nil];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
