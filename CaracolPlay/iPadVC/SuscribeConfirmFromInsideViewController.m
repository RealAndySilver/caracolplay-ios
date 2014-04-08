//
//  SuscribeConfirmFromInsideViewController.m
//  CaracolPlay
//
//  Created by Developer on 7/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscribeConfirmFromInsideViewController.h"

@interface SuscribeConfirmFromInsideViewController ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *continueButton;
@end

@implementation SuscribeConfirmFromInsideViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self setupUI];
}

-(void)setupUI {
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
    [self.continueButton addTarget:self action:@selector(goToProductionDetail) forControlEvents:UIControlEventTouchUpInside];
    self.continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:self.continueButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670., 626.0);
    self.textView.frame = CGRectMake(80.0, 300.0, self.view.bounds.size.width - 160.0, 100.0);
    self.continueButton.frame = CGRectMake(80.0, 450.0, self.view.bounds.size.width - 160.0, 60.0);
}

#pragma mark - Actions 

-(void)goToProductionDetail {
    if (self.controllerWasPresentedFromSuscribeFormScreen) {
        [[[[self presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    
    } else if (self.controllerWasPresentedFromIngresarScreen) {
        [[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController]dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
