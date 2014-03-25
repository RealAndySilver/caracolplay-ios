//
//  RedeemCodeViewController.m
//  CaracolPlay
//
//  Created by Developer on 30/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodeViewController.h"
#import "MainTabBarViewController.h"
#import "RedeemCodeAlertViewController.h"

@interface RedeemCodeViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextField *codeTextfield;

@end

@implementation RedeemCodeViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.codeTextfield.delegate = self;
    
    //We want to show the navigation bar
    self.navigationController.navigationBarHidden = NO;
    
    //Add a tap gesture to dismiss the keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self.continueButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    //Create two FXBlurViews to blur the view when an alert is displayed.
    /*self.blurView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
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
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"] forBarMetrics:UIBarMetricsDefault];
}

-(void)goToHomeScreen {
    if ([self.codeTextfield.text length] > 0) {
        //Test purposes only. If the user wrote something in the textfield, pass to the redeem code confirmation.
        RedeemCodeAlertViewController *redeemCodeAlertVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodeAlert"];
        [self.navigationController pushViewController:redeemCodeAlertVC animated:YES];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"El código no existe o no se puede canjear." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)tap {
    [self.codeTextfield resignFirstResponder];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
