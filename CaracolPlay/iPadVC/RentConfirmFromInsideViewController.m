//
//  RentConfirmFromInsideViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 4/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RentConfirmFromInsideViewController.h"
#import "FileSaver.h"

@interface RentConfirmFromInsideViewController ()
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UITextView *productionNameTextview;
@property (strong, nonatomic) UIButton *continueButton;
@end

@implementation RentConfirmFromInsideViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self setupUI];
}

-(void)setupUI {
    //2. detail textview
    self.textView = [[UITextView alloc] init];
    self.textView.text = @"El pago se ha realizado de forma satisfactoria. Ahora puedes disfrutar del siguiente contenido";
    self.textView.textColor = [UIColor whiteColor];
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:self.textView];
    
    //3. other textview
    self.productionNameTextview = [[UITextView alloc] init];
    self.productionNameTextview.text = @"Mentiras Perfectas Mentiras Perfectas Mentiras Perfectas";
    self.productionNameTextview.textAlignment = NSTextAlignmentCenter;
    self.productionNameTextview.backgroundColor = [UIColor clearColor];
    self.productionNameTextview.font = [UIFont systemFontOfSize:15.0];
    self.productionNameTextview.textColor = [UIColor whiteColor];
    [self.view addSubview:self.productionNameTextview];
    
    //Continue button
    self.continueButton = [[UIButton alloc] init];
    [self.continueButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton addTarget:self action:@selector(goToProductionDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.continueButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:self.continueButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 626.0);
    self.textView.frame = CGRectMake(50.0, 250.0, self.view.bounds.size.width - 100.0, 80.0);
    self.productionNameTextview.frame = CGRectMake(50.0, 340.0, self.view.bounds.size.width - 100.0, 60.0);
    self.continueButton.frame = CGRectMake(50.0, self.productionNameTextview.frame.origin.y + self.productionNameTextview.frame.size.height + 20.0, self.view.bounds.size.width - 100.0, 50.0);
}

#pragma mark - Actions 

-(void)goToProductionDetail {
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
    
    if (self.controllerWasPresentedFromRentFromInside) {
        [[[[self presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:NO completion:^(){
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        }];
    } else if (self.controllerWasPresentedFromIngresarFromInside) {
        [[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController]dismissViewControllerAnimated:NO completion:^(){
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        }];
    }
}

@end
