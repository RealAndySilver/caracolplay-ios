//
//  RedeemCodePadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodePadViewController.h"
#import "RedeemCodeConfirmationPadViewController.h"

@interface RedeemCodePadViewController ()
@property (weak, nonatomic) IBOutlet UITextField *codeTextfield;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) UIButton *dismissButton;
@end

@implementation RedeemCodePadViewController

-(void)UISetup {
    
    //1. Background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundIngresarPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //2. Dismiss button setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //3. 'Continuar' button
    [self.continueButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 386.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 386.0 + 20.0);
    
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame =CGRectMake(self.view.bounds.size.width - 44.0, 0.0, 44.0, 44.0);
}

#pragma mark - Actions

-(void)goToHomeScreen {
    if (![self.codeTextfield.text length] > 0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Código inválido." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        RedeemCodeConfirmationPadViewController *redeemCodeConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodeConfirmation"];
        redeemCodeConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        redeemCodeConfirmationVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:redeemCodeConfirmationVC animated:YES completion:nil];
    }
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
