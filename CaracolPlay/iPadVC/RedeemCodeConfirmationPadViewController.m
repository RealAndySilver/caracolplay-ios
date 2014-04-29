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
    self.backgroundImageView.image = [UIImage imageNamed:@"RedeemCodeConfirmFullScreenBackground.png"];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 2. Textview
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.text = [@"Tu código ha sido aceptado. Ahora puedes disfrutar del siguiente contenido: \n\n" stringByAppendingString:self.message];
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
    if (self.controllerWasPresentedFromSuscriptionAlert || self.controllerWasPresentedFromContentNotAvailable || self.controllerWasPresentedFromInsideRedeemWithExistingUser) {
        [self.enterButton addTarget:self action:@selector(returnToProduction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.enterButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    }
    self.enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:self.enterButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    /*self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 617.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 617.0 + 20.0);*/
    
    self.backgroundImageView.frame = self.view.bounds;
    self.textView.frame = CGRectMake(self.view.bounds.size.width/2.0 - 170.0, 400.0, 340.0, 150.0);
    self.enterButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, 600.0, 300.0, 50.0);
    //self.suscribeButton.frame = CGRectMake(30.0, self.view.bounds.size.height/2 + 220.0, self.view.bounds.size.width - 60.0, 50.0);
    //self.skipButton.frame = CGRectMake(self.view.bounds.size.width - 100.0, 22.0, 100.0, 30.0);
}

#pragma mark - Actions 

-(void)returnToProduction {
    if (self.controllerWasPresentedFromSuscriptionAlert) {
        [[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController]dismissViewControllerAnimated:YES completion:^(){
            if (!self.controllerWasPresentedFromContentNotAvailable) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
            }
        }];
    } else if (self.controllerWasPresentedFromInsideRedeemWithExistingUser) {
        [[[[[[self presentingViewController] presentingViewController] presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        }];
    
    } else if (self.controllerWasPresentedFromContentNotAvailable) {
        [[[[self presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        }];
    }
}

-(void)goToHomeScreen {
    MainTabBarPadController *mainTabBarPadController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    [self presentViewController:mainTabBarPadController animated:YES completion:nil];
}

@end
