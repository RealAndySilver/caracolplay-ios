//
//  RedeemCodeViewController.m
//  CaracolPlay
//
//  Created by Developer on 30/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodeViewController.h"
#import "MainTabBarViewController.h"

@interface RedeemCodeViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextField *codeTextfield;
@property (strong, nonatomic) FXBlurView *blurView;
@property (strong, nonatomic) FXBlurView *navigationBarBlurView;

@end

@implementation RedeemCodeViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self.continueButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    //Create two FXBlurViews to blur the view when an alert is displayed.
    self.blurView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
    self.blurView.blurRadius = 7.0;
    self.blurView.alpha = 0.0;
    [self.view addSubview:self.blurView];
    
    self.navigationBarBlurView = [[FXBlurView alloc] init];
    self.navigationBarBlurView.blurRadius = 7.0;
    self.navigationBarBlurView.alpha = 0.0;
    [self.navigationController.navigationBar addSubview:self.navigationBarBlurView];
    [self.navigationController.navigationBar bringSubviewToFront:self.navigationBarBlurView];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.navigationBarBlurView.frame = self.navigationController.navigationBar.bounds;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationBarBlurView removeFromSuperview];
    [self.blurView removeFromSuperview];
}

-(void)goToHomeScreen {
    if ([self.codeTextfield.text length] > 0) {
        MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarVC animated:YES completion:nil];
    } else {
        self.blurView.alpha = 1.0;
        self.navigationBarBlurView.alpha = 1.0;
        [ILAlertView showWithTitle:nil message:@"El código que ingresaste es erróneo. Por favor compruébalo." closeButtonTitle:@"Ok" secondButtonTitle:nil tappedSecondButton:^(){
            self.blurView.alpha = 0.0;
            self.navigationBarBlurView.alpha = 0.0;
        }];
    }
}

-(void)tap {
    [self.codeTextfield resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
