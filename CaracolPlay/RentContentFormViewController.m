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
#import "TermsAndConditionsViewController.h"
#import "UserInfo.h"
#import "ServerCommunicator.h"
#import "IAmCoder.h"
#import "IAPProduct.h"

@interface RentContentFormViewController () <CheckmarkViewDelegate, UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UILabel *servicePoliticsLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *aliasTextfield;
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (strong, nonatomic) CheckmarkView *checkmarkView1;
@property (strong, nonatomic) CheckmarkView *checkmarkView2;
@property (strong, nonatomic) UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *politicsButton;

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
    self.confirmPasswordTextfield.secureTextEntry = YES;
    self.passwordTextfield.delegate = self;
    self.passwordTextfield.secureTextEntry = YES;
    self.emailTextfield.delegate = self;
    self.aliasTextfield.delegate = self;
    self.emailTextfield.tag = 3;
    
    //Create a tap gesture recognizer to dismiss the keyboard tapping on the view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //'Continuar' button setup
    self.nextButton = [[UIButton alloc] init];
    [self.nextButton setTitle:@"Continuar" forState:UIControlStateNormal];
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(startRentProcess) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    
    //Create the two checkbox
    self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(40.0, 478.0, 20.0, 20.0)];
    self.checkmarkView1.cornerRadius = 3.0;
    self.checkmarkView1.tag = 1;
    self.checkmarkView1.delegate = self;
    self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(40.0, 517.0, 20.0, 20.0)];
    self.checkmarkView2.cornerRadius = 3.0;
    self.checkmarkView2.tag = 2;
    self.checkmarkView2.delegate = self;
    
    self.scrollView.alwaysBounceVertical = YES;
    [self.scrollView addSubview:self.nextButton];
    [self.scrollView addSubview:self.checkmarkView1];
    [self.scrollView addSubview:self.checkmarkView2];
    
    //'Ingresa aquí' button setup
    [self.enterHereButton addTarget:self action:@selector(goToIngresarVC) forControlEvents:UIControlEventTouchUpInside];
    
    //Other buttons setup
    [self.termsButton addTarget:self action:@selector(goToTermsVC) forControlEvents:UIControlEventTouchUpInside];
    [self.politicsButton addTarget:self action:@selector(goToTermsVC) forControlEvents:UIControlEventTouchUpInside];
    
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

-(void)goToTermsVC {
    TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
    [self.navigationController pushViewController:termsAndConditionsVC animated:YES];
}

-(void)goToIngresarVC {
    RentContentViewController *rentContentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContent"];
    [self.navigationController pushViewController:rentContentVC animated:YES];
}

-(void)startRentProcess {
    //Save info in user info object
    [UserInfo sharedInstance].userName = self.aliasTextfield.text;
    [UserInfo sharedInstance].password = self.passwordTextfield.text;
    
    if ([self areTermsAndPoliticsConditionsAccepted] && [self textfieldsInfoIsCorrect]) {
        [self validateUser];
    } else {
        //The terms and conditions were not accepted, so show an alert.
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No has completado algunos campos obligatorios. Revisa e inténtalo de nuevo."delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [self showErrorsInTermAndPoliticsConditions];
    }
    /*if ([self areTermsAndPoliticsConditionsAccepted] && [self textfieldsInfoIsCorrect]) {
        [self suscribeUserInServer];
        [MBHUDView hudWithBody:@"Conectando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        //Request products from Apple Servers
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            [MBHUDView dismissCurrentHUD];
            if (success) {
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
    }*/
}

#pragma mark - Server Stuff

-(void)rentContent {
    [MBHUDView hudWithBody:@"Comprando" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"product_id=%@&user_info=%@", @"100", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:@"RentContent/1" andParameter:parameters httpMethod:@"POST"];
}

-(void)validateUser {
    [MBHUDView hudWithBody:@"Conectando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:@"ValidateUser" andParameter:parameter httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
    if ([methodName isEqualToString:@"ValidateUser"]) {
        if (dictionary) {
            NSLog(@"respuesta del validate: %@", dictionary);
            if ([dictionary[@"response"] boolValue]) {
                NSLog(@"validacion correcta");
                if ([dictionary[@"region"] intValue] == 0) {
                    [self purchaseProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.rent"];
                } else if ([dictionary[@"region"] intValue] == 1) {
                    [self purchaseProductWithIdentifier:@"net.icck.CaracolPlay.RM.rent"];
                }
                //[self suscribeUserInServerWithTransactionID:@"18"];
            } else {
                NSLog(@"validacion incorrecta");
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } else {
            //Error en la respuesta
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if ([methodName isEqualToString:@"RentContent/1"]) {
        if (dictionary) {
            NSLog(@"Peticion RentCOntent exitosa: %@", dictionary);
            
            //Save a key localy that indicates that the user is logged in
            FileSaver *fileSaver = [[FileSaver alloc] init];
            [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                       @"UserName" : [UserInfo sharedInstance].userName,
                                       @"Password" : [UserInfo sharedInstance].password,
                                       @"Session" : dictionary[@"session"]
                                       } withKey:@"UserHasLoginDic"];
            [UserInfo sharedInstance].session = dictionary[@"session"];
            
            //Go to Suscription confirmation VC
            [self goToRentConfirmationVC];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Custom Methods

-(void)goToRentConfirmationVC {
    RentContentConfirmationViewController *rentContentConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentConfirmation"];
    [self.navigationController pushViewController:rentContentConfirmationVC animated:YES];
}

-(void)purchaseProductWithIdentifier:(NSString *)productID {
    [MBHUDView hudWithBody:@"Comprando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    //Request products from Apple Servers
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        [MBHUDView dismissCurrentHUD];
        if (success) {
            NSLog(@"apareció el mensajito de itunes");
            for (IAPProduct *product in products) {
                if ([product.productIdentifier isEqualToString:productID]) {
                    [[CPIAPHelper sharedInstance] buyProduct:product];
                    break;
                }
            }
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error accediendo a los productos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

-(NSString *)generateEncodedUserInfoString {
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
    NSString *encodedJsonString = [IAmCoder base64EncodeString:jsonString];
    return encodedJsonString;
}

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

#pragma mark - Notification Handlers

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    NSLog(@"Falló la transacción");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:notificationInfo[@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción");
    [self rentContent];
    
    //Test purposes only. If the terms are accepted, validate the suscription.
    //Save a key locally indicating that the user is log in.
    //FileSaver *fileSaver = [[FileSaver alloc] init];
    //[fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
    
    //Go to the rent confirmation view controller.
    //RentContentConfirmationViewController *rentConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentConfirmation"];
    
    //suscriptionConfirmationVC.controllerWasPresentedFromInitialScreen = self.controllerWasPresentFromInitialScreen;
    //[self.navigationController pushViewController:rentConfirmationVC animated:YES];
}


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
    NSLog(@"");
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
