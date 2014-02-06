//
//  SuscribeViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscribePadViewController.h"
#import "CheckmarkView.h"
#import "MainTabBarPadController.h"
@import QuartzCore;

@interface SuscribePadViewController ()
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) CheckmarkView *checkBox1;
@property (strong, nonatomic) CheckmarkView *checkBox2;
@end

@implementation SuscribePadViewController

-(void)UISetup {
    
    //1. Set background image
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundFormularioPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //2. Dismiss view controller button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //3. Checkboxes
    self.checkBox1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(40.0, 423.0, 20.0, 20.0)];
    [self.view addSubview:self.checkBox1];
    
    self.checkBox2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(40.0, 463.0, 20.0, 20.0)];
    [self.view addSubview:self.checkBox2];
    
    //4. 'Continuar' button
    [self.continueButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"bound: %@", NSStringFromCGRect(self.view.bounds));
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 597.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 597.0 + 20.0);
    
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 25.0, 0.0, 25.0, 25.0);
}

#pragma mark - Custom Methods 

-(void)goToHomeScreen {
    if ([self areTermsAndConditionsAccepted]) {
        NSLog(@"Si puede pasar");
        MainTabBarPadController *mainTabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Debes aceptar los terminos y condiciones y las políticas de privacidad para poder continuar." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(BOOL)areTermsAndConditionsAccepted {
    if ([self.checkBox1 viewIsChecked] && [self.checkBox2 viewIsChecked]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Actions

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
