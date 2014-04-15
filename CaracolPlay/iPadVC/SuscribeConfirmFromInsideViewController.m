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
@property (strong, nonatomic) UIImageView *backgroundImageView;
@end

@implementation SuscribeConfirmFromInsideViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self setupUI];
}

-(void)setupUI {
    //Set the background image
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.image = [UIImage imageNamed:@"SuscriptionConfirmationBackground.png"];
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
    [self.continueButton addTarget:self action:@selector(goToProductionDetail) forControlEvents:UIControlEventTouchUpInside];
    self.continueButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:self.continueButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 597.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 597.0 + 20.0);
    self.textView.frame = CGRectMake(30.0, 300.0, self.view.bounds.size.width - 60.0, 100.0);
    self.continueButton.frame = CGRectMake(30.0, 450.0, self.view.bounds.size.width - 60.0, 60.0);
    self.backgroundImageView.frame = self.view.bounds;
}

#pragma mark - Actions 

-(void)goToProductionDetail {
    if (self.controllerWasPresentedFromSuscribeFormScreen) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        [[[[self presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:^(){
            if (!self.userIsLoggedIn) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
            }
        }];
    
    } else if (self.controllerWasPresentedFromIngresarScreen) {
        NSLog(@"me dismiseareeeeee");
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        [[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController]dismissViewControllerAnimated:YES completion:^(){
            if (!self.userIsLoggedIn) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
            }
        }];
    
    } else if (self.controllerWasPresenteFromContentNotAvailable) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:^(){
            if (!self.userIsLoggedIn) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
            }
        }];
    }
}

@end
