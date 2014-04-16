//
//  LoginPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LoginPadViewController.h"
#import "IngresarPadViewController.h"
#import "SuscribePadViewController.h"
#import "MainTabBarPadController.h"
#import "ValidateCodePadViewController.h"

@interface LoginPadViewController ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *suscribeButton;
@property (strong, nonatomic) UIButton *enterButton;
@property (strong, nonatomic) UIButton *redeemButton;
@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) UIButton *tigoButton;
@end

@implementation LoginPadViewController

-(void)UISetup {
    //1. Background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InicioiPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    
    //2. 'Suscríbete' button setup
    self.suscribeButton = [[UIButton alloc] init];
    [self.suscribeButton setTitle:@"Suscríbete" forState:UIControlStateNormal];
    [self.suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.suscribeButton addTarget:self action:@selector(showSuscribeVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.suscribeButton];
    
    //3. 'Ingresar' button setup
    self.enterButton = [[UIButton alloc] init];
    [self.enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [self.enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.enterButton addTarget:self action:@selector(showIngresarVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.enterButton];
    
    //Tigo button
    self.tigoButton = [[UIButton alloc] init];
    [self.tigoButton setBackgroundImage:[UIImage imageNamed:@"BotonTigoPad.png"] forState:UIControlStateNormal];
    [self.tigoButton addTarget:self action:@selector(goToTigo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tigoButton];
    
    //4. 'Redimir' button setup
    self.redeemButton = [[UIButton alloc] init];
    [self.redeemButton setTitle:@"Redimir\nCódigo" forState:UIControlStateNormal];
    [self.redeemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"BotonRedimirPad.png"] forState:UIControlStateNormal];
    [self.redeemButton addTarget:self action:@selector(showRedeemVC) forControlEvents:UIControlEventTouchUpInside];
    self.redeemButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.redeemButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.redeemButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:self.redeemButton];
    
    //5. 'Saltar' button
    self.skipButton = [[UIButton alloc] init];
    [self.skipButton setTitle:@"Saltar" forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    self.skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.skipButton addTarget:self action:@selector(skipAndGoToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipButton];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //Set subviews frames
    self.backgroundImageView.frame = self.view.bounds;
    self.suscribeButton.frame = CGRectMake(self.view.bounds.size.width/2 - 173.0, self.view.bounds.size.height/2 + 90.0, 163, 45.0);
    self.enterButton.frame = CGRectMake(self.view.bounds.size.width/2 + 10.0, self.view.bounds.size.height/2 + 90.0, 163, 45.0);
    self.tigoButton.frame = CGRectMake(self.view.bounds.size.width/2 - 173.0, self.view.bounds.size.height/2 + 160.0, 346.0, 45.0);
    self.redeemButton.frame = CGRectMake(self.view.bounds.size.width/2 - 60.0, self.view.bounds.size.height/2 + 230.0, 120.0, 120.0);
    self.skipButton.frame = CGRectMake(920.0, 30.0, 100.0, 28.0);
}

#pragma mark - Custom Methods

-(void)goToTigo {
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.caracolplay.com?partner=tigo"]]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No fue posible abrir la URL en este momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)skipAndGoToHomeScreen {
    MainTabBarPadController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    mainTabBarVC.userDidSkipRegisterProcess = YES;
    [self presentViewController:mainTabBarVC animated:YES completion:nil];
}

-(void)showRedeemVC {
    ValidateCodePadViewController *validateCodeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ValidateCodePad"];
    validateCodeVC.modalPresentationStyle = UIModalPresentationFormSheet;
    validateCodeVC.controllerWasPresentedFromInitialScreen = YES;
    [self presentViewController:validateCodeVC animated:YES completion:nil];
}

-(void)showIngresarVC {
    IngresarPadViewController *ingresarPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IngresarPad"];
    ingresarPadViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    ingresarPadViewController.viewWidth = 320.0;
    ingresarPadViewController.viewHeight = 386.0;
    ingresarPadViewController.controllerWasPresentedFromInitialScreen = YES;
    [self presentViewController:ingresarPadViewController animated:YES completion:nil];
}

-(void)showSuscribeVC {
    SuscribePadViewController *suscribePadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscribePad"];
    suscribePadViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:suscribePadViewController animated:YES completion:nil];
}

@end
