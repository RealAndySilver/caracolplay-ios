//
//  SuscriptionFormViewController.m
//  CaracolPlay
//
//  Created by Developer on 27/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionFormViewController.h"

@interface SuscriptionFormViewController ()
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (strong, nonatomic) CheckmarkView *checkmarkView1;
@property (strong, nonatomic) CheckmarkView *checkmarkView2;
@end

@implementation SuscriptionFormViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameTextfield.delegate = self;
    self.lastNameTextfield.delegate = self;
    self.confirmPasswordTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    self.emailTextfield.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50.0, self.view.frame.size.height - 70.0, 100.0, 30.0)];
    [nextButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [nextButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(50.0, 388.0, 20.0, 20.0)];
    self.checkmarkView1.cornerRadius = 3.0;
    [self.view addSubview:self.checkmarkView1];
    
    self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(50.0, 426.0, 20.0, 20.0)];
    self.checkmarkView2.cornerRadius = 3.0;
    [self.view addSubview:self.checkmarkView2];
}

-(void)goToHomeScreen {
    if ([self areTermsAndPoliticsConditionsAccepted]) {
        MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarVC animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Condiciones no aceptadas" message:@"Debes aceptar los terminos y condiciones y las politicas del servicio para poder ingresar a la aplicación" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(BOOL)areTermsAndPoliticsConditionsAccepted {
    if ([self.checkmarkView1 viewIsChecked] && [self.checkmarkView2 viewIsChecked]) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard {
    [self.nameTextfield resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    [self.confirmPasswordTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    [self.emailTextfield resignFirstResponder];
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
