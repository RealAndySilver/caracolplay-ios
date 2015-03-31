//
//  SuscribeViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscribePadViewController.h"
#import "TermsAndConditionsPadViewController.h"
#import "CheckmarkView.h"
#import "SuscriptionConfirmationPadViewController.h"
#import "FileSaver.h"
#import "CPIAPHelper.h"
#import "IngresarPadViewController.h"
#import "UserInfo.h"
#import "ServerCommunicator.h"
#import "IAmCoder.h"
#import "IAPProduct.h"
#import "MBProgressHUD.h"
@import QuartzCore;

@interface SuscribePadViewController () <ServerCommunicatorDelegate, CheckmarkViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *wrongBirthdayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongNameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongLastNameImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongEmailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongAliasImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongGenreImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongPasswordImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongConfirmPassImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextfield;
@property (weak, nonatomic) IBOutlet UITextField *genreTextfield;
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (weak, nonatomic) IBOutlet UIImageView *wrongTermsImageView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIImageView *wrongPoliticsImageView;
@property (weak, nonatomic) IBOutlet UIButton *servicePoliticsButton;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet UITextField *aliasTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) CheckmarkView *checkBox1;
@property (strong, nonatomic) CheckmarkView *checkBox2;
@property (strong, nonatomic) NSString *transactionID;
@property (nonatomic) NSTimeInterval birthdayTimeStamp;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (assign, nonatomic) BOOL purchaseSuccededInItunes;
@end

@implementation SuscribePadViewController

-(void)UISetup {
    //Set the wrong image views invinsible
    [self setAllWrongImageViewsInvisible];
    
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTextfields)];
    [self.view addGestureRecognizer:tapGesture];
    
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
    self.checkBox1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(36.0, 421.0, 22.0, 22.0)];
    self.checkBox1.delegate = self;
    [self.scrollView addSubview:self.checkBox1];
    
    self.checkBox2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(36.0, 452.0, 22.0, 22.0)];
    self.checkBox2.delegate = self;
    [self.scrollView addSubview:self.checkBox2];
    
    //4. 'Continuar' button
    [self.continueButton addTarget:self action:@selector(startSubscriptionProcess) forControlEvents:UIControlEventTouchUpInside];
    
    //'Ingresa aquí' button setup
    [self.enterHereButton addTarget:self action:@selector(goToIngresarVC) forControlEvents:UIControlEventTouchUpInside];
    
    //Terms and politics buttons
    [self.termsAndConditionsButton addTarget:self action:@selector(goToTerms) forControlEvents:UIControlEventTouchUpInside];
    [self.servicePoliticsButton addTarget:self action:@selector(goToPolitics) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.purchaseSuccededInItunes = NO;
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    //Register as an observer of the notification 'UserDidSuscribe'
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailedNotificationReceived:) name:@"TransactionFailedNotification" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"Desapareceré");
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"bound: %@", NSStringFromCGRect(self.view.bounds));
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 617.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 617.0 + 20.0);
    
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 44.0, 3.0, 44.0, 44.0);
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.continueButton.frame.origin.y + self.continueButton.frame.size.height + 290.0);
}

#pragma mark - Actions 

-(void)dismissTextfields {
    NSLog(@"me tocaron");
    [self.genreTextfield resignFirstResponder];
    [self.birthdayTextfield resignFirstResponder];
}

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

-(void)startSubscriptionProcess {
    [self setAllWrongImageViewsInvisible];
    
    //Save info in user info object
    [UserInfo sharedInstance].userName = self.aliasTextfield.text;
    [UserInfo sharedInstance].password = self.passwordTextfield.text;
    
    BOOL termsAreAccepted = [self areTermsAndConditionsAccepted];
    BOOL textfieldInfoIsCorrect = [self textfieldsInfoIsCorrect];
    if (termsAreAccepted && textfieldInfoIsCorrect) {
        [self validateUser];
    } else {
        //The terms and conditions were not accepted, so show an alert.
        if (![self.passwordTextfield.text isEqualToString:self.confirmPasswordTextfield.text]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Las contraseñas no coinciden" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No has completado algunos campos obligatorios. Revisa e inténtalo de nuevo."delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [self showErrorsInTermAndPoliticsConditions];
        }
    }
}

-(void)goToIngresarVC {
    [self resignAllTextfieldsAsFirstResponders];
    
    //Remove as an observer of the notification -userDidSuscribe
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserDidSuscribe" object:nil];
    
    IngresarPadViewController *ingresarPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IngresarPad"];
    ingresarPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    ingresarPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
    ingresarPadVC.viewWidth = 320.0;
    ingresarPadVC.viewHeight = 617.0;
    ingresarPadVC.controllerWasPresentedFromInitialSuscriptionScreen = YES;
    [self presentViewController:ingresarPadVC animated:YES completion:nil];
}

-(void)resignAllTextfieldsAsFirstResponders {
    [self.nameTextfield resignFirstResponder];
    [self.aliasTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    [self.confirmPasswordTextfield resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    [self.emailTextfield resignFirstResponder];
}

#pragma mark - Server Stuff

-(void)validateUser {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:@"ValidateUser" andParameter:parameter httpMethod:@"POST"];
}

-(void)suscribeUserInServerWithTransactionID:(NSString *)transactionID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Comprando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString * encodedUserInfo = [self generateEncodedUserInfoString];
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", encodedUserInfo];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", transactionID] andParameter:parameter
                                      httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([methodName isEqualToString:@"ValidateUser"]) {
        if (dictionary) {
            NSLog(@"respuesta del validate: %@", dictionary);
            if ([dictionary[@"response"] boolValue]) {
                NSLog(@"validacion correcta");
                if ([dictionary[@"region"] intValue] == 0) {
                    [self purchaseProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.subscription"];
                } else if ([dictionary[@"region"] intValue] == 1) {
                    [self purchaseProductWithIdentifier:@"net.icck.CaracolPlay.RM.subscription"];
                }
            } else {
                NSLog(@"validacion incorrecta");
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } else {
            //Error en la respuesta
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", self.transactionID]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                self.purchaseSuccededInItunes = NO;
                NSLog(@"Peticion SuscribeUser exitosa: %@", dictionary);
                
                //Save a key localy that indicates that the user is logged in
                FileSaver *fileSaver = [[FileSaver alloc] init];
                [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                           @"UserName" : [UserInfo sharedInstance].userName,
                                           @"Password" : [UserInfo sharedInstance].password,
                                           @"Session" : dictionary[@"session"],
                                           @"IsSuscription" : @YES
                                           } withKey:@"UserHasLoginDic"];
                [UserInfo sharedInstance].session = dictionary[@"session"];
                [UserInfo sharedInstance].userID = dictionary[@"uid"];
                [UserInfo sharedInstance].isSubscription = YES;
                //Go to Suscription confirmation VC
                [self goToSubscriptionConfirm];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al suscribirse en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al suscribirse en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.purchaseSuccededInItunes) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al suscribirse en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
        
    } else {
         [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en unos momentos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Custom Methods

-(void)setAllWrongImageViewsInvisible {
    self.wrongNameImageView.alpha = 0.0;
    self.wrongLastNameImageView.alpha = 0.0;
    self.wrongAliasImageView.alpha = 0.0;
    self.wrongEmailImageView.alpha = 0.0;
    self.wrongGenreImageView.alpha = 0.0;
    self.wrongBirthdayImageView.alpha = 0.0;
    self.wrongPasswordImageView.alpha = 0.0;
    self.wrongConfirmPassImageView.alpha = 0.0;
    self.wrongPoliticsImageView.alpha = 0.0;
    self.wrongTermsImageView.alpha = 0.0;
}

-(void)goToSubscriptionConfirm {
    NSLog(@"Me llegó la notificación de compraaaa");
    
    //The user can pass to the suscription confirmation view controller
    SuscriptionConfirmationPadViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmationPad"];
    suscriptionConfirmationVC.controllerWasPresentedFromInitialScreen = YES;
    suscriptionConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    suscriptionConfirmationVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:suscriptionConfirmationVC animated:YES completion:nil];
}

-(void)purchaseProductWithIdentifier:(NSString *)productID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Comprando...";
    
    //Request products from Apple Servers
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
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
    if (![self.checkBox1 viewIsChecked]) {
        NSLog(@"chekmark 1 no chuleado");
        self.wrongTermsImageView.alpha = 1.0;
        self.checkBox1.borderWidth = 3.0;
        self.checkBox1.borderColor = [UIColor redColor];
    }
    
    if (![self.checkBox2 viewIsChecked]) {
        NSLog(@"checkmark 2 no chuleado");
        self.wrongPoliticsImageView.alpha = 1.0;
        self.checkBox2.borderWidth = 3.0;
        self.checkBox2.borderColor = [UIColor redColor];
    }
}

-(BOOL)areTermsAndPoliticsConditionsAccepted {
    if ([self.checkBox1 viewIsChecked] && [self.checkBox2 viewIsChecked]) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)textfieldsInfoIsCorrect {
    BOOL nameIsCorrect = NO;
    BOOL lastNameIsCorrect = NO;
    BOOL emailIsCorrect = NO;
    BOOL passwordIsCorrect = NO;
    BOOL confirmPasswordIsCorrect = NO;
    BOOL bothPasswordsAreCorrect = NO;
    BOOL genreIsCorrect = NO;
    BOOL birthdayIsCorrect = NO;
    BOOL aliasIsCorrect = NO;
    
    if ([self.nameTextfield.text length] > 0) {
        nameIsCorrect = YES;
    } else {
        self.wrongNameImageView.alpha = 1.0;
    }
    
    if ([self.lastNameTextfield.text length] > 0) {
        lastNameIsCorrect = YES;
    } else {
        self.wrongLastNameImageView.alpha = 1.0;
    }
    
    if ([self.aliasTextfield.text length] > 0) {
        aliasIsCorrect = YES;
    } else {
        self.wrongAliasImageView.alpha = 1.0;
    }
    
    if ([self NSStringIsValidEmail:self.emailTextfield.text]) {
        emailIsCorrect = YES;
        self.emailTextfield.textColor = [UIColor whiteColor];
    } else {
        self.wrongEmailImageView.alpha = 1.0;
        self.emailTextfield.textColor = [UIColor redColor];
    }
    
    if ([self.genreTextfield.text length] > 0) {
        genreIsCorrect = YES;
    } else {
        self.wrongGenreImageView.alpha = 1.0;
    }
    
    if ([self.birthdayTextfield.text length] > 0) {
        birthdayIsCorrect = YES;
    } else {
        self.wrongBirthdayImageView.alpha = 1.0;
    }
    
    if ([self.passwordTextfield.text length] > 0) {
        passwordIsCorrect = YES;
    } else {
        self.wrongPasswordImageView.alpha = 1.0;
    }
    
    if ([self.confirmPasswordTextfield.text length] > 0) {
        confirmPasswordIsCorrect = YES;
    } else {
        self.wrongConfirmPassImageView.alpha = 1.0;
    }
    
    if ([self.passwordTextfield.text isEqualToString:self.confirmPasswordTextfield.text]) {
        bothPasswordsAreCorrect = YES;
    } else {
        self.wrongPasswordImageView.alpha = 1.0;
        self.wrongConfirmPassImageView.alpha = 1.0;
    }
    
    if (nameIsCorrect && lastNameIsCorrect && aliasIsCorrect && emailIsCorrect && genreIsCorrect && birthdayIsCorrect && passwordIsCorrect && confirmPasswordIsCorrect && bothPasswordsAreCorrect) {
        return YES;
    } else {
        return  NO;
    }
}

/*-(void)suscribe {
    if ([self areTermsAndConditionsAccepted]) {
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            if (success) {
                IAPProduct *product = [products firstObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }];
    } else {
        //The user can't pass.
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No has completado algunos campos obligatorios. Revisa e inténtalo de nuevo. " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}*/

-(BOOL)areTermsAndConditionsAccepted {
    if ([self.checkBox1 viewIsChecked] && [self.checkBox2 viewIsChecked]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Notification Handlers

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Me llegó la notificacion de que falló la transaccion");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:notificationInfo[@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.purchaseSuccededInItunes = YES;
    NSDictionary *userInfo = [notification userInfo];
    NSString *transactionID = userInfo[@"TransactionID"];
    self.transactionID = transactionID;
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción, con el transacion id: %@", transactionID);
    [self suscribeUserInServerWithTransactionID:transactionID];
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

#pragma mark - CheckmarkViewDelegate

-(void)checkmarkViewWasChecked:(CheckmarkView *)checkmarkView {
    checkmarkView.borderColor = [UIColor whiteColor];
    checkmarkView.borderWidth = 1.0;
}

-(void)checkmarkViewWasUnchecked:(CheckmarkView *)checkmarkView {
    
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

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self suscribeUserInServerWithTransactionID:self.transactionID];
    }
}

@end
