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
#import "FileSaver.h"

@interface IngresarViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end

@implementation IngresarViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = NO;
    self.nameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    [self.enterButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tapGesture];
    
    /*self.blurView = [[FXBlurView alloc] init];
    self.blurView.blurRadius = 7.0;
    self.blurView.alpha = 0.0;
    [self.view addSubview:self.blurView];
    
    self.navigationBarBlurView = [[FXBlurView alloc] init];
    self.navigationBarBlurView.blurRadius = 7.0;
    self.navigationBarBlurView.alpha = 0.0;
    [self.navigationController.navigationBar addSubview:self.navigationBarBlurView];
    [self.navigationController.navigationBar bringSubviewToFront:self.navigationBarBlurView];*/
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Custom Methods

-(void)tap {
    [self.nameTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

-(void)goToHomeScreen {
    if (([self.nameTextfield.text length] > 0) && [self.passwordTextfield.text length]) {
        FileSaver *fileSaver = [[FileSaver alloc] init];
        [fileSaver setDictionary:@{@"UserDidSkipKey": @NO} withKey:@"UserDidSkipDic"];
        [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
        
        MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarVC animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Error en la información. Por favor revisa que hayas completado todos los campos correctamente." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
