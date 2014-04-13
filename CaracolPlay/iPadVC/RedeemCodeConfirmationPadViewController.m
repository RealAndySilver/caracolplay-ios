//
//  RedeemCodeConfirmationPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodeConfirmationPadViewController.h"
#import "IngresarPadViewController.h"
#import "SuscribePadViewController.h"
#import "MainTabBarPadController.h"

@interface RedeemCodeConfirmationPadViewController ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *enterButton;
@property (strong, nonatomic) UIButton *suscribeButton;
@property (strong, nonatomic) UIButton *skipButton;
@end

@implementation RedeemCodeConfirmationPadViewController

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.image = [UIImage imageNamed:@"RedeemCodeAlertBackground.png"];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 2. Textview
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.text = @"Tu código ha sido aceptado. Ahora puedes disfrutar del siguiente contenido: \n\nEvento en Vivo: Colombia vs Grecia\nJunio 14, 9:00 AM";
    self.textView.userInteractionEnabled = NO;
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.font = [UIFont systemFontOfSize:15.0];
    self.textView.textColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
    
    //2. Set the enter and suscribe button
    self.enterButton = [[UIButton alloc] init];
    [self.enterButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [self.enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.enterButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    self.enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:self.enterButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 597.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 597.0 + 20.0);
    
    self.backgroundImageView.frame = self.view.bounds;
    self.textView.frame = CGRectMake(30.0, self.view.bounds.size.height/2 - 30.0, self.view.bounds.size.width - 60.0, 150.0);
    self.enterButton.frame = CGRectMake(30.0, self.view.bounds.size.height/2 + 150.0, self.view.bounds.size.width - 60.0, 50.0);
    self.suscribeButton.frame = CGRectMake(30.0, self.view.bounds.size.height/2 + 220.0, self.view.bounds.size.width - 60.0, 50.0);
    self.skipButton.frame = CGRectMake(self.view.bounds.size.width - 100.0, 22.0, 100.0, 30.0);
}

#pragma mark - Actions 

-(void)goToHomeScreen {
    MainTabBarPadController *mainTabBarPadController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    [self presentViewController:mainTabBarPadController animated:YES completion:nil];
}

@end
