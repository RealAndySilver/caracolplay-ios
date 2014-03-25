//
//  RentContentFormViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RentContentFormViewController.h"
#import "CheckmarkView.h"
#import "FileSaver.h"
#import "RentContentConfirmationViewController.h"
#import "MBHUDView.h"
#import "CPIAPHelper.h"
#import "RentContentViewController.h"

@interface RentContentFormViewController () <CheckmarkViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *servicePoliticsLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (strong, nonatomic) CheckmarkView *checkmarkView1;
@property (strong, nonatomic) CheckmarkView *checkmarkView2;
@property (strong, nonatomic) UIButton *nextButton;

@end

@implementation RentContentFormViewController

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.nextButton.frame = CGRectMake(self.view.bounds.size.width/2 - 120.0, self.servicePoliticsLabel.frame.origin.y + self.servicePoliticsLabel.frame.size.height + 20.0, 240.0, 40.0);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.nextButton.frame.origin.y + self.nextButton.frame.size.height + 180.0);
    NSLog(@"content size: %f", self.scrollView.contentSize.height);
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    //Register as an observer of the notification -UserDidSuscribe.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transactionFailedNotificationReceived:)
                                                 name:@"TransactionFailedNotification"
                                               object:nil];
    
    //Set textfields delegates
    self.nameTextfield.delegate = self;
    self.lastNameTextfield.delegate = self;
    self.confirmPasswordTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    self.emailTextfield.delegate = self;
    
    //Create a tap gesture recognizer to dismiss the keyboard tapping on the view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //'Continuar' button setup
    self.nextButton = [[UIButton alloc] init];
    [self.nextButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(rentContentAndGoToRentConfirmation) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    
    //Create the two checkbox
    self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(40.0, 438.0, 20.0, 20.0)];
    self.checkmarkView1.cornerRadius = 3.0;
    self.checkmarkView1.tag = 1;
    self.checkmarkView1.delegate = self;
    self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(40.0, 477.0, 20.0, 20.0)];
    self.checkmarkView2.cornerRadius = 3.0;
    self.checkmarkView2.tag = 2;
    self.checkmarkView2.delegate = self;
    
    self.scrollView.alwaysBounceVertical = YES;
    [self.scrollView addSubview:self.nextButton];
    [self.scrollView addSubview:self.checkmarkView1];
    [self.scrollView addSubview:self.checkmarkView2];
    
    //'Ingresa aquí' button setup
    [self.enterHereButton addTarget:self action:@selector(goToIngresarVC) forControlEvents:UIControlEventTouchUpInside];
    
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

#pragma mark - Actions 

-(void)goToIngresarVC {
    RentContentViewController *rentContentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContent"];
    [self.navigationController pushViewController:rentContentVC animated:YES];
}

-(void)rentContentAndGoToRentConfirmation {
    if ([self areTermsAndPoliticsConditionsAccepted]) {
        [MBHUDView hudWithBody:@"Conectando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        //Request products from Apple Servers
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            if (success) {
                [MBHUDView dismissCurrentHUD];
                NSLog(@"apareció el mensajito de itunes");
                //Request succeded - Buy the product
                IAPProduct *product = [products lastObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }];
        
    } else {
        //The terms and conditions were not accepted, so show an alert.
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No has completado algunos campos obligatorios. Revisa e inténtalo de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [self showErrorsInTermAndPoliticsConditions];
    }
}

#pragma mark - Custom Methods

-(void)showErrorsInTermAndPoliticsConditions {
    if (![self.checkmarkView1 viewIsChecked]) {
        NSLog(@"chekmark 1 no chuleado");
        self.checkmarkView1.borderWidth = 3.0;
        self.checkmarkView1.borderColor = [UIColor redColor];
    }
    
    if (![self.checkmarkView2 viewIsChecked]) {
        NSLog(@"checkmark 2 no chuleado");
        self.checkmarkView2.borderWidth = 3.0;
        self.checkmarkView2.borderColor = [UIColor redColor];
    }
}

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

#pragma mark - Notification Handlers

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    NSLog(@"Falló la transacción");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:notificationInfo[@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción");
    
    //Test purposes only. If the terms are accepted, validate the suscription.
    //Save a key locally indicating that the user is log in.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
    
    //Go to the rent confirmation view controller.
    RentContentConfirmationViewController *rentConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentConfirmation"];
    
    //suscriptionConfirmationVC.controllerWasPresentedFromInitialScreen = self.controllerWasPresentFromInitialScreen;
    [self.navigationController pushViewController:rentConfirmationVC animated:YES];
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - CheckmarkViewDelegate

-(void)checkmarkViewWasChecked:(CheckmarkView *)checkmarkView {
    checkmarkView.borderColor = [UIColor whiteColor];
    checkmarkView.borderWidth = 1.0;
}

-(void)checkmarkViewWasUnchecked:(CheckmarkView *)checkmarkView {
    NSLog(@"");
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
