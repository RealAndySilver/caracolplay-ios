//
//  IngresarViewController.m
//  CaracolPlay
//
//  Created by Developer on 30/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarViewController.h"
#import "MainTabBarViewController.h"
#import "FXBlurView.h"

@interface IngresarViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) FXBlurView *blurView;
@property (strong, nonatomic) FXBlurView *navigationBarBlurView;

@end

@implementation IngresarViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.nameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    [self.enterButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.blurView = [[FXBlurView alloc] init];
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
    self.blurView.frame = self.view.bounds;
    self.navigationBarBlurView.frame = self.navigationController.navigationBar.bounds;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationBarBlurView removeFromSuperview];
}

#pragma mark - UITextfieldDelegate 

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)tap {
    [self.nameTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

-(void)goToHomeScreen {
    if (([self.nameTextfield.text length] > 0) && [self.passwordTextfield.text length]) {
        MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarVC animated:YES completion:nil];
    } else {
        //Blur the background view
        self.blurView.alpha = 1.0;
        self.navigationBarBlurView.alpha = 1.0;
        [ILAlertView showWithTitle:nil message:@"Usuario o contraseña incorrecta. Por favor revisa tus datos."
                  closeButtonTitle:@"Ok"
                 secondButtonTitle:nil
                tappedSecondButton:^(){
                    self.blurView.alpha = 0.0;
                    self.navigationBarBlurView.alpha = 0.0;
                }];
    }
}

@end
