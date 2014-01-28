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
@property (strong, nonatomic) UIButton *nextButton;
@end

@implementation SuscriptionFormViewController

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.nextButton.frame = CGRectMake(self.view.bounds.size.width/2 - 50.0, self.view.bounds.size.height - 70.0, 100.0, 30.0);
    } else {
        self.nextButton.frame = CGRectMake(self.view.bounds.size.width / 2 - 50.0, self.view.bounds.size.height - 100.0, 100.0, 40.0);
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBarHidden = NO;
    
    //Set textfields delegates
    self.nameTextfield.delegate = self;
    self.lastNameTextfield.delegate = self;
    self.confirmPasswordTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    self.emailTextfield.delegate = self;
    
    //Create a tap gesture recognizer to dismiss the keyboard tapping on the view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //Create a button to skip the subscription process and go directly to home screen.
    self.nextButton = [[UIButton alloc] init];
    [self.nextButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(50.0, 385.0, 20.0, 20.0)];
        self.checkmarkView1.cornerRadius = 3.0;
        self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(50.0, 426.0, 20.0, 20.0)];
        self.checkmarkView2.cornerRadius = 3.0;
    } else {
        self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(350.0, 485.0, 40.0, 40.0)];
        self.checkmarkView1.cornerRadius = 6.0;
        self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(350.0, 545.0, 40.0, 40.0)];
        self.checkmarkView2.cornerRadius = 6.0;
    }
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.checkmarkView1];
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

#pragma mark - Custom Methods

-(void)dismissKeyboard {
    [self.nameTextfield resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    [self.confirmPasswordTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    [self.emailTextfield resignFirstResponder];
}

-(BOOL)areTermsAndPoliticsConditionsAccepted {
    if ([self.checkmarkView1 viewIsChecked] && [self.checkmarkView2 viewIsChecked]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

@end
