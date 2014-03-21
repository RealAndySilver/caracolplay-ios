//
//  RentContentViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 17/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RentContentViewController.h"
#import "FileSaver.h"
#import "CPIAPHelper.h"
#import "RentContentConfirmationViewController.h"
#import "MBHUDView.h"

@interface RentContentViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (weak, nonatomic) IBOutlet UIButton *rentButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@end

@implementation RentContentViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Register as an observer of the notification -UserDidSuscribe.
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];*/

    
    self.userTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    [self.rentButton addTarget:self action:@selector(rentProduction) forControlEvents:UIControlEventTouchUpInside];
    
    //Create a tap gesture to dismiss the keyboard that appears when the
    //user touches a textfield
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Actions

-(void)rentProduction {
    if ([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0) {
        [MBHUDView hudWithBody:@"Conectando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        
        //Testing purposes only. If the user has entered information in both textfields,
        //make a succesful login and save a key to know that the user is login.
        FileSaver *fileSaver = [[FileSaver alloc] init];
        [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
        
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            if (success) {
                [MBHUDView dismissCurrentHUD];
                IAPProduct *product = [products lastObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }];

    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor revisa que hayas completado todos los campos correctamente." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)dismissKeyboard {
    [self.userTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

#pragma mark - Notification Handlers

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"Recibí la notificación");
    RentContentConfirmationViewController *rentContentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentConfirmation"];
    [self.navigationController pushViewController:rentContentVC animated:YES];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
