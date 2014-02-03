//
//  IngresarPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarPadViewController.h"
#import "MainTabBarPadController.h"
@import QuartzCore;

@interface IngresarPadViewController ()
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@end

@implementation IngresarPadViewController

#pragma mark - View Lifecycle

-(void)UISetup {
    
    //1. Background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundIngresarPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //2. 'Cerrar' button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //3. 'Ingresar' button
    [self.enterButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}


-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //Set our superview bounds, in order to present this view with the correct size (320, 386)
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 386.0);
    
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame=CGRectMake(-10, -10, 320 + 20.0, 386 + 20);

    //Set Subviews frames
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 25.0, 0.0, 25.0, 25.0);
    self.backgroundImageView.frame = self.view.bounds;
}

#pragma mark - Actions

-(void)goToHomeScreen {
    
    if (!([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0)) {
        //Show an alert to the user indicating that the info is wrong
        [[[UIAlertView alloc] initWithTitle:nil message:@"Error en los datos ingresados." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        //The user can pass to the home screen
        MainTabBarPadController *mainTabBarPadController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarPadController animated:YES completion:nil];
    }
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
