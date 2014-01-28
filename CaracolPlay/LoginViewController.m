//
//  LoginViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LoginViewController.h"
#import "SuscriptionFormViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Volver" style:UIBarButtonItemStylePlain target:self action:nil];
    
    //1. Set the background image of the view
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"Inicio.png"];
    [self.view addSubview:backgroundImageView];
    
    //2. Set the enter and suscribe buttons
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 120.0, self.view.bounds.size.height/2 + 80.0, 240.0, 45.0)];
    [enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:enterButton];
    
    UIButton *suscribeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 120.0, self.view.bounds.size.height/2 + 140.0, 240.0, 45.0)];
    [suscribeButton setTitle:@"Suscríbete" forState:UIControlStateNormal];
    [suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [suscribeButton addTarget:self action:@selector(goToSuscribeViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suscribeButton];
    
    //3. Set the 'redeem code' button
    UIButton *redeemCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 50.0, self.view.bounds.size.height - 80.0, 100.0, 100.0)];
    [redeemCodeButton setTitle:@"Redimir\nCódigo" forState:UIControlStateNormal];
    [redeemCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [redeemCodeButton setBackgroundImage:[UIImage imageNamed:@"BotonRedimir.png"] forState:UIControlStateNormal];
    redeemCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    redeemCodeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    redeemCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:redeemCodeButton];
    
    //4. Set the 'Skip' button
    UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0, 22.0, 50.0, 30.0)];
    [skipButton setTitle:@"Saltar" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:skipButton];
}

#pragma mark - Button Actions 

-(void)goToEnterViewController {
    
}

-(void)goToSuscribeViewController {
    SuscriptionFormViewController *suscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Suscription"];
    [self.navigationController pushViewController:suscriptionViewController animated:YES];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
