//
//  SuscriptionFormViewController.m
//  CaracolPlay
//
//  Created by Developer on 27/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionFormViewController.h"
#import "FXBlurView.h"

@interface SuscriptionFormViewController ()
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (strong, nonatomic) CheckmarkView *checkmarkView1;
@property (strong, nonatomic) CheckmarkView *checkmarkView2;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) FXBlurView *blurView;
@end

@implementation SuscriptionFormViewController

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.nextButton.frame = CGRectMake(self.view.bounds.size.width/2 - 120.0, self.view.bounds.size.height - 70.0, 240.0, 40.0);
    } else {
        self.nextButton.frame = CGRectMake(self.view.bounds.size.width / 2 - 120.0, self.view.bounds.size.height - 100.0, 240.0, 40.0);
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
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(50.0, 357.0, 20.0, 20.0)];
        self.checkmarkView1.cornerRadius = 3.0;
        self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(50.0, 396.0, 20.0, 20.0)];
        self.checkmarkView2.cornerRadius = 3.0;
    } else {
        self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(350.0, 465.0, 40.0, 40.0)];
        self.checkmarkView1.cornerRadius = 6.0;
        self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(350.0, 525.0, 40.0, 40.0)];
        self.checkmarkView2.cornerRadius = 6.0;
    }
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.checkmarkView1];
    [self.view addSubview:self.checkmarkView2];
    
    self.blurView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
    self.blurView.blurRadius = 7.0;
    self.blurView.alpha = 0.0;
    [self.view addSubview:self.blurView];
}

-(void)goToHomeScreen {
    if ([self areTermsAndPoliticsConditionsAccepted]) {
        MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarVC animated:YES completion:nil];
    } else {
        /*[[[UIAlertView alloc] initWithTitle:@"Condiciones no aceptadas" message:@"Debes aceptar los terminos y condiciones y las politicas del servicio para poder ingresar a la aplicación" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];*/
        self.blurView.alpha = 1.0;
        [ILAlertView showWithTitle:nil message:@"Error en los datos. Por favor verifícalos." closeButtonTitle:@"Ok" secondButtonTitle:nil tappedSecondButton:^(){
            self.blurView.alpha = 0.0;
        }];
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
