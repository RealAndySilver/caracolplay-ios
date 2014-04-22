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
#import "ServerCommunicator.h"
#import "IAmCoder.h"
#import "FileSaver.h"
#import "RedeemCodeConfirmationPadViewController.h"
#import "RedeemCodePadViewController.h"
#import "TermsAndConditionsPadViewController.h"
#import "MBProgressHUD.h"

@interface RedeemCodeFormPadViewController () <ServerCommunicatorDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *servicePoliticsButton;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextfield;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet UITextField *genreTextfield;
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (weak, nonatomic) IBOutlet UITextField *aliasTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (strong, nonatomic) CheckmarkView *checkmarkView1;
@property (strong, nonatomic) CheckmarkView *checkmarkView2;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (nonatomic) NSTimeInterval birthdayTimeStamp;
@end

@implementation RedeemCodeFormPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
}

-(void)setupUI {
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.nameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    self.aliasTextfield.delegate = self;
    self.lastNameTextfield.delegate = self;
    self.confirmPasswordTextfield.delegate = self;
    self.emailTextfield.delegate = self;
    self.genreTextfield.delegate  =self;
    self.birthdayTextfield.delegate = self;
    
    //Genre picker view
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 50.0, 100.0, 50.0)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.tag = 1;
    self.genreTextfield.inputView = self.pickerView;
    
    //Date picker view
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 50.0, 100.0, 50.0)];
    self.datePickerView.tag = 2;
    self.datePickerView.datePickerMode = UIDatePickerModeDate;
    [self.datePickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    self.birthdayTextfield.inputView = self.datePickerView;

    
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
    self.checkmarkView1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(9.0, 421.0, 22.0, 22.0)];
    [self.scrollView addSubview:self.checkmarkView1];
    
    self.checkmarkView2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(9.0, 451.0, 22.0, 22.0)];
    [self.scrollView addSubview:self.checkmarkView2];
    
    //4. 'Continuar' button
    [self.nextButton addTarget:self action:@selector(startRedeemCodeProcess) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.frame = CGRectOffset(self.nextButton.frame, 0.0, 10.0);
    
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

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.nextButton.frame.origin.y + self.nextButton.frame.size.height + 270.0);
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
    [self resignAllTextfieldsAsFirstResponders];
    
    RedeemCodePadViewController *redeemCodePadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodePad"];
    redeemCodePadVC.modalPresentationStyle = UIModalPresentationPageSheet;
    redeemCodePadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    redeemCodePadVC.redeemedCode = self.redeemedCode;
    if (self.controllerWasPresentedFromSuscriptionAlertScreen) {
        redeemCodePadVC.controllerWasPresentedFromSuscriptionAlertScreen = YES;
    }
    [self presentViewController:redeemCodePadVC animated:YES completion:nil];
}

-(void)resignAllTextfieldsAsFirstResponders {
    [self.nameTextfield resignFirstResponder];
    [self.aliasTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    [self.confirmPasswordTextfield resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    [self.emailTextfield resignFirstResponder];
}

-(NSString *)generateRedeemedProductionsStringUsingArrayWithName:(NSArray *)namesArray {
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i = 0; i < [namesArray count]; i++) {
        [string appendString:namesArray[i]];
        [string appendString:@", "];
    }
    NSLog(@"%@", string);
    return string;
}

-(void)startRedeemCodeProcess {
    if ([self areTermsAndPoliticsConditionsAccepted] && [self textfieldsInfoIsCorrect]) {
        [self validateUser];
    } else {
        //The terms and conditions were not accepted, so show an alert.
        if (![self.passwordTextfield.text isEqualToString:self.confirmPasswordTextfield.text]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Las contraseñas no coinciden" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No has completado algunos campos obligatorios. Revisa e inténtalo de nuevo."delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        [self showErrorsInTermAndPoliticsConditions];
    }
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Server Stuff

-(void)redeemCodeInServer:(NSString *)code {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Redimiendo...";
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@", @"RedeemCode", code] andParameter:parameter httpMethod:@"POST"];
}

-(void)validateUser {
    [UserInfo sharedInstance].userName = self.aliasTextfield.text;
    [UserInfo sharedInstance].password = self.passwordTextfield.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:@"ValidateUser" andParameter:parameter httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    /////////////////////////////////////////////////////////////////////
    //ValidateUser
    if ([methodName isEqualToString:@"ValidateUser"]) {
        if (dictionary) {
            NSLog(@"respuesta del validate: %@", dictionary);
            if ([dictionary[@"response"] boolValue]) {
                NSLog(@"validacion correcta");
                [self redeemCodeInServer:self.redeemedCode];
                
            } else {
                NSLog(@"validacion incorrecta");
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } else {
            //Error en la respuesta
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }

    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"RedeemCode", self.redeemedCode]]) {
        if (dictionary) {
            NSLog(@"Respuesta del redeem code: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"redencion correcta");
                //Save a key localy that indicates that the user is logged in
                FileSaver *fileSaver = [[FileSaver alloc] init];
                [UserInfo sharedInstance].session = dictionary[@"session"];
                
                if ([dictionary[@"code"][@"type"] isEqualToString:@"me"]) {
                    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                               @"UserName" : [UserInfo sharedInstance].userName,
                                               @"Password" : [UserInfo sharedInstance].password,
                                               @"Session" : dictionary[@"session"]
                                               } withKey:@"UserHasLoginDic"];
                    NSString *redeemedProductionsString =
                        [self generateRedeemedProductionsStringUsingArrayWithName:dictionary[@"code"][@"items"]];
                    [self goToRedeemCodeConfirmationWithMessage:redeemedProductionsString];
                    
                } else if ([dictionary[@"code"][@"type"] isEqualToString:@"s"]) {
                    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                               @"UserName" : [UserInfo sharedInstance].userName,
                                               @"Password" : [UserInfo sharedInstance].password,
                                               @"Session" : dictionary[@"session"],
                                               @"IsSuscription" : @YES
                                               } withKey:@"UserHasLoginDic"];
                    [UserInfo sharedInstance].isSubscription = YES;
                    NSString *messageString = [@"Suscripción Anual\n" stringByAppendingString:dictionary[@"code"][@"msg"]];
                    [self goToRedeemCodeConfirmationWithMessage:messageString];
                } else {
                    [self goToRedeemCodeConfirmationWithMessage:nil];
                }
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Custom Methods

-(void)dateChanged:(UIDatePicker *)datePicker {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDate *date = datePicker.date;
    self.birthdayTimeStamp = [date timeIntervalSince1970];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    NSLog(@"fecha: %@", formattedDateString);
    self.birthdayTextfield.text = formattedDateString;
}

-(void)goToRedeemCodeConfirmationWithMessage:(NSString *)message {
    RedeemCodeConfirmationPadViewController *redeemCodeConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodeConfirmationPad"];
    redeemCodeConfirmationVC.message = message;
    redeemCodeConfirmationVC.modalPresentationStyle = UIModalPresentationPageSheet;
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
                                  @"alias" : self.aliasTextfield.text,
                                  @"genero" : self.genreTextfield.text,
                                  @"fecha_de_nacimiento" : @(self.birthdayTimeStamp)
                                  };
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
    if ([self.nameTextfield.text length] > 0 && [self.lastNameTextfield.text length] > 0 && [self.genreTextfield.text length] > 0 && [self.birthdayTextfield.text length] > 0) {
        namesAreCorrect = YES;
    }
    
    if ([self.passwordTextfield.text isEqualToString:self.confirmPasswordTextfield.text]) {
        passwordsAreCorrect = YES;
    }
    
    if ([self NSStringIsValidEmail:self.emailTextfield.text]) {
        emailIsCorrect = YES;
        self.emailTextfield.textColor = [UIColor whiteColor];
    } else {
        self.emailTextfield.textColor = [UIColor redColor];
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

-(BOOL)areTermsAndPoliticsConditionsAccepted {
    if ([self.checkmarkView1 viewIsChecked] && [self.checkmarkView2 viewIsChecked]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView.tag == 1) {
        return 1;
    } else {
        return 0;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        return 2;
    } else {
        return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        if (row == 0) {
            return @"Masculino";
        } else {
            return @"Femenino";
        }
    } else {
        return nil;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        if (row == 0) {
            self.genreTextfield.text = @"Masculino";
        } else {
            self.genreTextfield.text = @"Femenino";
        }
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

/*-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"empezé a editarme");
    self.enterHereButton.userInteractionEnabled = NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.enterHereButton.userInteractionEnabled = YES;
    NSLog(@"terminé de editarme");
}*/

@end
