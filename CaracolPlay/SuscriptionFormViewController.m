//
//  SuscriptionFormViewController.m
//  CaracolPlay
//
//  Created by Developer on 27/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionFormViewController.h"
#import "FXBlurView.h"
#import "FileSaver.h"
#import "SuscriptionConfirmationViewController.h"
#import "CPIAPHelper.h"
#import "IAPProduct.h"
#import "MBHUDView.h"
#import "IngresarViewController.h"
#import "TermsAndConditionsViewController.h"

@interface SuscriptionFormViewController ()
@property (weak, nonatomic) IBOutlet UIButton *servicePoliticsButton;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (weak, nonatomic) IBOutlet UITextField *aliasTextfield;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *servicePoliticsLabel;
@property (strong, nonatomic) CheckmarkView *checkmarkView1;
@property (strong, nonatomic) CheckmarkView *checkmarkView2;
@property (strong, nonatomic) UIButton *nextButton;

@end

@implementation SuscriptionFormViewController

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.nextButton.frame = CGRectMake(self.view.bounds.size.width/2 - 120.0, self.servicePoliticsLabel.frame.origin.y + self.servicePoliticsLabel.frame.size.height + 20.0, 240.0, 40.0);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.nextButton.frame.origin.y + self.nextButton.frame.size.height + 180.0);
    NSLog(@"content size: %f", self.scrollView.contentSize.height);
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    [self setupUI];
    
    //Register as an observer of the notification -UserDidSuscribe.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailedNotificationReceived:) name:@"TransactionFailedNotification" object:nil];
}

-(void)setupUI {
    //Set textfields properties
    self.nameTextfield.delegate = self;
    self.lastNameTextfield.delegate = self;
    self.confirmPasswordTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    self.emailTextfield.delegate = self;
    self.nameTextfield.tag = 1;
    self.lastNameTextfield.tag = 2;
    self.emailTextfield.tag = 3;
    
    //Create a tap gesture recognizer to dismiss the keyboard tapping on the view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //'Continuar' button setup
    self.nextButton = [[UIButton alloc] init];
    [self.nextButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(goToSuscriptionConfirmationVC) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    
    //Create the two checkbox
    self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(40.0, 440.0, 20.0, 20.0)];
    self.checkmarkView1.cornerRadius = 3.0;
    self.checkmarkView1.tag = 1;
    self.checkmarkView1.delegate = self;
    self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(40.0, 480.0, 20.0, 20.0)];
    self.checkmarkView2.cornerRadius = 3.0;
    self.checkmarkView2.tag = 2;
    self.checkmarkView2.delegate = self;
    
    self.scrollView.alwaysBounceVertical = YES;
    [self.scrollView addSubview:self.nextButton];
    [self.scrollView addSubview:self.checkmarkView1];
    [self.scrollView addSubview:self.checkmarkView2];
    
    //'Ingresa aquí' button setup
    [self.enterHereButton addTarget:self action:@selector(goToIngresarVC) forControlEvents:UIControlEventTouchUpInside];
    
    //Terms and politics buttons
    [self.termsAndConditionsButton addTarget:self action:@selector(goToTerms) forControlEvents:UIControlEventTouchUpInside];
    [self.servicePoliticsButton addTarget:self action:@selector(goToPolitics) forControlEvents:UIControlEventTouchUpInside];
    
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

-(void)goToSuscriptionConfirmationVC {
    if ([self areTermsAndPoliticsConditionsAccepted] && [self textfieldsInfoIsCorrect]) {
        [self suscribeUserInServer];
        [MBHUDView hudWithBody:@"Conectando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        //Request products from Apple Servers
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            [MBHUDView dismissCurrentHUD];
            if (success) {
                NSLog(@"apareció el mensajito de itunes");
                for (IAPProduct *product in products) {
                    if ([product.productIdentifier isEqualToString:@"net.icck.CaracolPlay.Colombia.subscription"]) {
                        [[CPIAPHelper sharedInstance] buyProduct:product];
                        break;
                    }
                }
                //Request succeded - Buy the product
                //IAPProduct *product = [products firstObject];
                //[[CPIAPHelper sharedInstance] buyProduct:product];
            
            }
        }];
        
    } else {
        //The terms and conditions were not accepted, so show an alert.
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No has completado algunos campos obligatorios. Revisa e inténtalo de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [self showErrorsInTermAndPoliticsConditions];
    }
}

#pragma mark - Notification Handlers

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    NSLog(@"Me llegó la notificacion de que falló la transaccion");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:notificationInfo[@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción");
    
    //Test purposes only. If the terms are accepted, validate the suscription.
    //Save a key locally indicating that the user is log in.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
     
    //Go to the suscription confirmation view controller.
    SuscriptionConfirmationViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmation"];
    
    if (self.controllerWasPresentFromInitialScreen) {
        suscriptionConfirmationVC.controllerWasPresentedFromInitialScreen = YES;
        suscriptionConfirmationVC.userWasAlreadyLoggedin = NO;
    } else if (self.controllerWasPresentedFromProductionScreen) {
        suscriptionConfirmationVC.controllerWasPresentedFromProductionScreen = YES;
    }
    [self.navigationController pushViewController:suscriptionConfirmationVC animated:YES];
    //[self suscribeUserInServer];
}

#pragma mark - Server Stuff

-(void)suscribeUserInServer {
    //Create JSON string with user info
    NSDictionary *userInfoDic = @{@"name": self.nameTextfield.text,
                                  @"lastname" : self.lastNameTextfield.text,
                                  @"email" : self.emailTextfield.text,
                                  @"password" : self.passwordTextfield.text,
                                  @"alias" : self.aliasTextfield.text};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Json String: %@", jsonString);
}

#pragma mark - Actions 

-(void)goToIngresarVC {
    IngresarViewController *ingresarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Ingresar"];
    if (self.controllerWasPresentFromInitialScreen) {
        ingresarVC.controllerWasPresentedFromInitialSuscriptionScreen = YES;
    } else if (self.controllerWasPresentedFromProductionScreen) {
        ingresarVC.controllerWasPresentedFromProductionSuscriptionScreen = YES;
    }
    [self.navigationController pushViewController:ingresarVC animated:YES];
}

-(void)goToTerms {
    TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
    [self.navigationController pushViewController:termsAndConditionsVC animated:YES];
}

-(void)goToPolitics {
    TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
    [self.navigationController pushViewController:termsAndConditionsVC animated:YES];
}

#pragma mark - Custom Methods

-(BOOL)textfieldsInfoIsCorrect {
    BOOL namesAreCorrect = NO;
    BOOL emailIsCorrect = NO;
    BOOL passwordsAreCorrect = NO;
    BOOL aliasIsCorrect = NO;
    if ([self.nameTextfield.text length] > 0 && [self.lastNameTextfield.text length] > 0) {
        namesAreCorrect = YES;
    }
    
    if ([self.passwordTextfield.text isEqualToString:self.confirmPasswordTextfield.text]) {
        passwordsAreCorrect = YES;
    }
    
    if ([self NSStringIsValidEmail:self.emailTextfield.text]) {
        emailIsCorrect = YES;
    }
    
    if ([self.aliasTextfield.text length] > 0) {
        aliasIsCorrect = YES;
    }
    
    if (namesAreCorrect && passwordsAreCorrect && emailIsCorrect && aliasIsCorrect) {
        return YES;
    } else {
        return  NO;
    }
}

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
    [self.aliasTextfield resignFirstResponder];
}

-(BOOL)areTermsAndPoliticsConditionsAccepted {
    if ([self.checkmarkView1 viewIsChecked] && [self.checkmarkView2 viewIsChecked]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Regex Stuff

-(BOOL)NSStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

/*-(BOOL)validateNameAndLastNameWithString:(NSString *)checkString {
    NSString *nameRegexString = @"/^[A-Za-z]+$/";
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegexString];
    return [namePredicate evaluateWithObject:checkString];
}*/

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /*if (textField.tag == 1) {
        //Validate name textfield
        if (![self validateNameAndLastNameWithString:textField.text]) {
            NSLog(@"El nombre no es válido");
            textField.textColor = [UIColor redColor];
        } else {
            NSLog(@"el nombre si es válido");
            textField.textColor = [UIColor whiteColor];
        }
    }*/
    if (textField.tag == 3) {
        //Validate email textfield
        if (![self NSStringIsValidEmail:textField.text]) {
            NSLog(@"el email no es válido");
            textField.textColor = [UIColor redColor];
        } else {
            NSLog(@"el email es válido");
            textField.textColor = [UIColor whiteColor];
        }
    }
    return YES;
}
#pragma mark - CheckmarkViewDelegate 

-(void)checkmarkViewWasChecked:(CheckmarkView *)checkmarkView {
    checkmarkView.borderColor = [UIColor whiteColor];
    checkmarkView.borderWidth = 1.0;
}

-(void)checkmarkViewWasUnchecked:(CheckmarkView *)checkmarkView {
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
        return UIInterfaceOrientationMaskPortrait;
}

@end
