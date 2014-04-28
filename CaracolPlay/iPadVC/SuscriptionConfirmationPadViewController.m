//
//  SuscriptionConfirmationPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionConfirmationPadViewController.h"
#import "MainTabBarPadController.h"

@interface SuscriptionConfirmationPadViewController ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *continueButton;
@end

@implementation SuscriptionConfirmationPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    //Set the background image
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.image = [UIImage imageNamed:@"SuscriptionConfirmationFullScreenBackground.png"];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 2. Textview
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.text = @"Tu pago ha sido realizado de forma satisfactoria. Ahora puedes disfrutar ilimitadamente de nuestro contenido durante una año";
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.font = [UIFont systemFontOfSize:15.0];
    self.textView.userInteractionEnabled = NO;
    self.textView.textColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
    
    //2. Set the enter and suscribe button
    self.continueButton = [[UIButton alloc] init];
    [self.continueButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    if (self.controllerWasPresentedFromInitialScreen) {
        [self.continueButton addTarget:self action:@selector(goToHomeViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.continueButton addTarget:self action:@selector(goToHomeViewController) forControlEvents:UIControlEventTouchUpInside];
    self.continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:self.continueButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    /*self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 617.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320 + 20.0, 617 + 20.0);*/
    self.backgroundImageView.frame = self.view.bounds;
    self.textView.frame = CGRectMake(self.view.bounds.size.width/2.0 - 170.0, 400.0, 340.0, 100.0);
    self.continueButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, 550.0, 300.0, 60.0);
}

#pragma mark - Actions 

-(void)goToHomeViewController {
    MainTabBarPadController *mainTabBarPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    [self presentViewController:mainTabBarPadVC animated:YES completion:nil];
}

@end
