//
//  LoginViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LoginViewController.h"
#import "SuscriptionFormViewController.h"
#import "FXBlurView.h"
#import "IngresarViewController.h"
#import "RedeemCodeViewController.h"
#import "Reachability.h"
#import "MainTabBarViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *enterButton;
@property (strong, nonatomic) UIButton *suscribeButton;
@property (strong, nonatomic) UIButton *redeemCodeButton;
@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) UIButton *alertTestButton;
@end

@implementation LoginViewController

-(void)UISetup {
    //1. Set the background image of the view
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.image = [UIImage imageNamed:@"Inicio.png"];
    [self.view addSubview:self.backgroundImageView];
    
    //2. Set the enter and suscribe button
    self.enterButton = [[UIButton alloc] init];
    [self.enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [self.enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.enterButton addTarget:self action:@selector(goToEnterViewController) forControlEvents:UIControlEventTouchUpInside];
    self.enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:self.enterButton];
    
    self.suscribeButton = [[UIButton alloc] init];
    [self.suscribeButton setTitle:@"Suscríbete" forState:UIControlStateNormal];
    [self.suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.suscribeButton addTarget:self action:@selector(goToSuscribeViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.suscribeButton];
    
    //3. Set the 'redeem code' button
    self.redeemCodeButton = [[UIButton alloc] init];
    [self.redeemCodeButton setTitle:@"Redimir\nCódigo" forState:UIControlStateNormal];
    [self.redeemCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.redeemCodeButton addTarget:self action:@selector(goToRedeemCodeViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.redeemCodeButton setBackgroundImage:[UIImage imageNamed:@"BotonRedimir.png"] forState:UIControlStateNormal];
    self.redeemCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.redeemCodeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.redeemCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.redeemCodeButton];
    
    //4. Set the 'Skip' button
    self.skipButton = [[UIButton alloc] init];
    [self.skipButton setTitle:@"Saltar" forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    self.skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.skipButton addTarget:self action:@selector(skipAndGoToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.skipButton];
    
    //5. boton para probar el alertview
    self.alertTestButton = [[UIButton alloc] init];
    [self.alertTestButton setTitle:@"Alerta" forState:UIControlStateNormal];
    [self.alertTestButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.alertTestButton addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.alertTestButton];
    
    /*//6. Add a blurview to be displayed when a low connection alert has been displayed.
    self.blurView = [[FXBlurView alloc] init];
    self.blurView.blurRadius = 7.0;
    self.blurView.dynamic = NO;
    self.blurView.alpha = 0.0;
    //[self.view addSubview:self.blurView];*/
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
     [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Volver" style:UIBarButtonItemStylePlain target:self action:nil];
    [self UISetup];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [self showAlert];
    } else if (status == ReachableViaWiFi) {
        NSLog(@"Hay Wifi");
    } else if (status == ReachableViaWWAN) {
        [self showAlert];
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"me llame");
    self.backgroundImageView.frame = self.view.bounds;
    self.enterButton.frame = CGRectMake(self.view.bounds.size.width/2 - 120.0, self.view.bounds.size.height/1.7, 240.0, 45.0);
    self.suscribeButton.frame = CGRectMake(self.view.bounds.size.width/2 - 120.0, self.view.bounds.size.height/1.4, 240.0, 45.0);
    self.redeemCodeButton.frame = CGRectMake(self.view.bounds.size.width/2 - 50.0, self.view.bounds.size.height - 80.0, 100.0, 100.0);
    self.skipButton.frame = CGRectMake(250.0, 10.0, 50.0, 44.0);
    self.alertTestButton.frame = CGRectMake(20.0, 20.0, 100.0, 30.0);
}

#pragma mark - Button Actions 

-(void)showAlert {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Tu conexión es muy lenta. Conéctate a una red Wi-Fi para poder acceder al contenido." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)goToRedeemCodeViewController {
    RedeemCodeViewController *redeemCodeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Redeem"];
    [self.navigationController pushViewController:redeemCodeVC animated:YES];
}

-(void)goToEnterViewController {
    IngresarViewController *ingresarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Ingresar"];
    [self.navigationController pushViewController:ingresarViewController animated:YES];
}

-(void)goToSuscribeViewController {
    SuscriptionFormViewController *suscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Suscription"];
    [self.navigationController pushViewController:suscriptionViewController animated:YES];
}

-(void)skipAndGoToHomeScreen {
    MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    mainTabBarVC.userDidSkipRegisterProcess = YES;
    [self presentViewController:mainTabBarVC animated:YES completion:nil];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
