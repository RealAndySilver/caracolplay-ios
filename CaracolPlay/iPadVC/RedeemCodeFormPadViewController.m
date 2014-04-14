//
//  RedeemCodeFormPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 12/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodeFormPadViewController.h"
#import "CheckmarkView.h"
#import "UserInfo.h"
#import "MBHUDView.h"
#import "ServerCommunicator.h"
#import "IAmCoder.h"
#import "FileSaver.h"
#import "RedeemCodeConfirmationPadViewController.h"
#import "RedeemCodePadViewController.h"
#import "TermsAndConditionsPadViewController.h"

@interface RedeemCodeFormPadViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *servicePoliticsButton;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (weak, nonatomic) IBOutlet UITextField *aliasTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *redeemCodeTextfield;
@property (strong, nonatomic) CheckmarkView *checkmarkView1;
@property (strong, nonatomic) CheckmarkView *checkmarkView2;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation RedeemCodeFormPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
}

-(void)setupUI {
    //1. Set background image
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundFormularioPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //2. Dismiss view controller button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //3. Checkboxes
    self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(35.0, 473.0, 25.0, 25.0)];
    [self.view addSubview:self.checkmarkView1];
    
    self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(35.0, 513.0, 25.0, 25.0)];
    [self.view addSubview:self.checkmarkView2];
    
    //4. 'Continuar' button
    [self.nextButton addTarget:self action:@selector(startRedeemCodeProcess) forControlEvents:UIControlEventTouchUpInside];
    
    //'Ingresa aquí' button setup
    [self.enterHereButton addTarget:self action:@selector(enterAndRedeemCode) forControlEvents:UIControlEventTouchUpInside];
    
    //Terms and politics buttons
    [self.termsAndConditionsButton addTarget:self action:@selector(goToTerms) forControlEvents:UIControlEventTouchUpInside];
    [self.servicePoliticsButton addTarget:self action:@selector(goToPolitics) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 597.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 597.0 + 20.0);
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 44.0, 0.0, 44.0, 44.0);
}

#pragma mark - Actions 

-(void)goToTerms {
    TermsAndConditionsPadViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsPad"];
    termsAndConditionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    termsAndConditionsVC.controllerWasPresentedInFormSheet = YES;
    termsAndConditionsVC.showTerms = YES;
    termsAndConditionsVC.mainTitle = @"Términos y Condiciones";
    [self presentViewController:termsAndConditionsVC animated:YES completion:nil];
}

-(void)goToPolitics {
    TermsAndConditionsPadViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsPad"];
    termsAndConditionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    termsAndConditionsVC.controllerWasPresentedInFormSheet = YES;
    termsAndConditionsVC.showPrivacy = YES;
    termsAndConditionsVC.mainTitle = @"Políticas de Privacidad";
    [self presentViewController:termsAndConditionsVC animated:YES completion:nil];
}

-(void)enterAndRedeemCode {
    RedeemCodePadViewController *redeemCodePadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodePad"];
    redeemCodePadVC.modalPresentationStyle = UIModalPresentationFormSheet;
    redeemCodePadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if (self.controllerWasPresentedFromSuscriptionAlertScreen) {
        redeemCodePadVC.controllerWasPresentedFromSuscriptionAlertScreen = YES;
    }
    [self presentViewController:redeemCodePadVC animated:YES completion:nil];
}

-(void)startRedeemCodeProcess {
    if ([self areTermsAndPoliticsConditionsAccepted] && [self textfieldsInfoIsCorrect]) {
        [self validateUser];
    } else {
        //The terms and conditions were not accepted, so show an alert.
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No has completado algunos campos obligatorios. Revisa e inténtalo de nuevo."delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [self showErrorsInTermAndPoliticsConditions];
    }
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Server Stuff

-(void)redeemCodeInServer:(NSString *)code {
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@", @"RedeemCode", code] andParameter:parameter httpMethod:@"POST"];
}

-(void)validateUser {
    [UserInfo sharedInstance].userName = self.aliasTextfield.text;
    [UserInfo sharedInstance].password = self.passwordTextfield.text;
    
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:@"ValidateUser" andParameter:parameter httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
    
    /////////////////////////////////////////////////////////////////////
    //ValidateUser
    if ([methodName isEqualToString:@"ValidateUser"]) {
        if (dictionary) {
            NSLog(@"respuesta del validate: %@", dictionary);
            if ([dictionary[@"response"] boolValue]) {
                NSLog(@"validacion correcta");
                [self redeemCodeInServer:self.redeemCodeTextfield.text];
                
            } else {
                NSLog(@"validacion incorrecta");
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } else {
            //Error en la respuesta
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }

    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"RedeemCode", self.redeemCodeTextfield.text]]) {
        if (dictionary) {
            NSLog(@"Respuesta del redeem code: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"redencion correcta");
                //Save a key localy that indicates that the user is logged in
                FileSaver *fileSaver = [[FileSaver alloc] init];
                [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                           @"UserName" : [UserInfo sharedInstance].userName,
                                           @"Password" : [UserInfo sharedInstance].password,
                                           @"Session" : dictionary[@"session"]
                                           } withKey:@"UserHasLoginDic"];
                [UserInfo sharedInstance].session = dictionary[@"session"];
                [self goToRedeemCodeConfirmation];
                
            } else {
                NSLog(@"redencion incorrecta");
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"response"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } else {
            [UserInfo sharedInstance].userName = nil;
            [UserInfo sharedInstance].password = nil;
            NSLog(@"error en la peticion de redimir: %@", dictionary);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error redimiendo el código. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }

    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Custom Methods

-(void)goToRedeemCodeConfirmation {
    RedeemCodeConfirmationPadViewController *redeemCodeConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodeConfirmationPad"];
    redeemCodeConfirmationVC.modalPresentationStyle = UIModalPresentationFormSheet;
    redeemCodeConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if (self.controllerWasPresentedFromSuscriptionAlertScreen) {
        redeemCodeConfirmationVC.controllerWasPresentedFromSuscriptionAlert = YES;
    }
    [self presentViewController:redeemCodeConfirmationVC animated:YES completion:nil];
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

-(BOOL)textfieldsInfoIsCorrect {
    BOOL namesAreCorrect = NO;
    BOOL emailIsCorrect = NO;
    BOOL passwordsAreCorrect = NO;
    BOOL aliasIsCorrect = NO;
    BOOL redeemCode = NO;
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
    
    if ([self.redeemCodeTextfield.text length] > 0) {
        redeemCode = YES;
    }
    
    if (namesAreCorrect && passwordsAreCorrect && emailIsCorrect && aliasIsCorrect && redeemCode) {
        return YES;
    } else {
        return  NO;
    }
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


@end
