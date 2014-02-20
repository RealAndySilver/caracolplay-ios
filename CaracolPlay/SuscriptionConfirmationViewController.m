//
//  SuscriptionConfirmationViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 19/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionConfirmationViewController.h"
#import "MainTabBarViewController.h"

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
    MainTabBarViewController *mainTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    [self presentViewController:mainTabBar animated:YES completion:nil];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
