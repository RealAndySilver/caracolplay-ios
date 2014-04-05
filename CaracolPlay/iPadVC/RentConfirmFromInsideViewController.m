//
//  RentConfirmFromInsideViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 4/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RentConfirmFromInsideViewController.h"

@interface RentConfirmFromInsideViewController ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UITextView *productionNameTextview;
@property (strong, nonatomic) UIButton *continueButton;
@end

@implementation RentConfirmFromInsideViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
}

-(void)setupUI {
    /*//2. detail textview
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 250.0, self.view.bounds.size.width - 40.0, 80.0)];
    self.textView.text = @"El pago se ha realizado de forma satisfactoria. Ahora puedes disfrutar del siguiente contenido";
    self.textView.textColor = [UIColor whiteColor];
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:self.textView];
    
    //3. other textview
    self.productionNameTextview = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 340.0, self.view.bounds.size.width - 40.0, 60.0)];
    self.productionNameTextview.text = @"Mentiras Perfectas Mentiras Perfectas Mentiras Perfectas";
    self.productionNameTextview.textAlignment = NSTextAlignmentCenter;
    self.productionNameTextview.backgroundColor = [UIColor clearColor];
    self.productionNameTextview.font = [UIFont systemFontOfSize:15.0];
    self.productionNameTextview.textColor = [UIColor whiteColor];
    [self.view addSubview:self.productionNameTextview];
    
    //Continue button
    self.continueButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, self.productionNameTextview.frame.origin.y + self.productionNameTextview.frame.size.height + 20.0, self.view.bounds.size.width - 60.0, 50.0)];
    [self.continueButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.continueButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:self.continueButton];*/
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 626.0);
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
