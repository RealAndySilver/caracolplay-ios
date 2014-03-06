//
//  SuscriptionAlertPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionAlertPadViewController.h"

@interface SuscriptionAlertPadViewController ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UITextView *detailTextView;
@property (strong, nonatomic) UIButton *rentButton;
@property (strong, nonatomic) UIButton *suscribeButton;
@property (strong, nonatomic) UIButton *redeemButton;
@end

@implementation SuscriptionAlertPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self UISetup];
}

-(void)UISetup {
    //1. dismiss buton setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //2. textview
    self.detailTextView = [[UITextView alloc] init];
    self.detailTextView.text = @"En este momento te encuentras fuera del sistema. Escoge una de las siguientes opciones para reproducir el video.";
    self.detailTextView.textColor = [UIColor whiteColor];
    self.detailTextView.font = [UIFont boldSystemFontOfSize:15];
    self.detailTextView.backgroundColor = [UIColor clearColor];
    self.detailTextView.textAlignment = NSTextAlignmentCenter;
    self.detailTextView.userInteractionEnabled = NO;
    [self.view addSubview:self.detailTextView];
    
    //3. Rent button
    self.rentButton = [[UIButton alloc] init];
    [self.rentButton setTitle:@"Alquilar" forState:UIControlStateNormal];
    [self.rentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rentButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.rentButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.rentButton];
    
    //4. suscribe button
    self.suscribeButton = [[UIButton alloc] init];
    [self.suscribeButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
    [self.suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.suscribeButton addTarget:self action:@selector(goToSuscriptionVC) forControlEvents:UIControlEventTouchUpInside];
    self.suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.suscribeButton];
    
    //5. Redeem button
    self.redeemButton = [[UIButton alloc] init];
    [self.redeemButton setTitle:@"Redimir" forState:UIControlStateNormal];
    [self.redeemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"BotonRedimirPad.png"] forState:UIControlStateNormal];
    self.redeemButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.redeemButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 600.0);
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -30.0, 88.0, 88.0);
    self.detailTextView.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, 200.0, 300.0, 200.0);
    self.rentButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 100.0, 300.0, 200.0, 50.0);
    self.suscribeButton.frame = CGRectOffset(self.rentButton.frame, 0.0, 70.0);
    self.redeemButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 50.0, 450.0, 100.0, 100.0);
}

#pragma mark - Actions 

-(void)goToSuscriptionVC {
    
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
