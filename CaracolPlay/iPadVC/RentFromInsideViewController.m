//
//  RentFromInsideViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 4/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RentFromInsideViewController.h"
#import "CheckmarkView.h"
#import "CPIAPHelper.h"
#import "FileSaver.h"
#import "RentConfirmFromInsideViewController.h"
#import "MBHUDView.h"
#import "IngresarFromInsideViewController.h"
#import "UserInfo.h"
#import "ServerCommunicator.h"
#import "IAmCoder.h"
#import "NSDictionary+NullReplacement.h"
#import "IAPProduct.h"

@interface RentFromInsideViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) CheckmarkView *checkBox1;
@property (strong, nonatomic) CheckmarkView *checkBox2;
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (strong, nonatomic) UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *rentButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *servicePoliticsButton;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet UITextField *aliasTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (strong, nonatomic) NSString *transactionID;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@end

@implementation RentFromInsideViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Register as an observer of the notification 'UserDidSuscribe'
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailedNotificationReceived:) name:@"TransactionFailedNotification" object:nil];
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
    self.checkBox1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(30.0, 467.0, 25.0, 25.0)];
    [self.view addSubview:self.checkBox1];
    
    self.checkBox2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(30.0, 507.0, 25.0, 25.0)];
    [self.view addSubview:self.checkBox2];
    
    //Rent button
    [self.rentButton addTarget:self action:@selector(startRentProcess) forControlEvents:UIControlEventTouchUpInside];
    
    //Enter here button
    [self.enterHereButton addTarget:self action:@selector(enterWithExistingUser) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 597.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 597.0 + 20.0);
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -30.0, 88.0, 88.0);
    self.backgroundImageView.frame = self.view.bounds;
}

#pragma mark - Actions 

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
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)enterWithExistingUser {
    //Remove as an observer of the userDidSuscribe notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    IngresarFromInsideViewController *ingresarFromInsideVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IngresarFromInside"];
    ingresarFromInsideVC.modalPresentationStyle = UIModalPresentationFormSheet;
    ingresarFromInsideVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    ingresarFromInsideVC.controllerWasPresentedFromRentScreen = YES;
    ingresarFromInsideVC.productName = self.productName;
    ingresarFromInsideVC.productType = self.productType;
    ingresarFromInsideVC.productID = self.productID;
    [self presentViewController:ingresarFromInsideVC animated:YES completion:nil];
}

-(void)goToRentConfirmationVC {
    RentConfirmFromInsideViewController *rentConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentConfirmFromInside"];
    rentConfirmVC.controllerWasPresentedFromRentFromInside = YES;
    rentConfirmVC.modalPresentationStyle = UIModalPresentationFormSheet;
    rentConfirmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rentConfirmVC.rentedProductionName = self.productName;
    rentConfirmVC.userIsLoggedIn = NO;
    [self presentViewController:rentConfirmVC animated:YES completion:nil];
}

#pragma mark - Server Stuff

-(void)validateUser {
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:@"ValidateUser" andParameter:parameter httpMethod:@"POST"];
}

-(void)rentContent {
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", self.transactionID, self.productID] andParameter:parameters httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
    if ([methodName isEqualToString:@"ValidateUser"]) {
        if (dictionary) {
            NSLog(@"respuesta del validate: %@", dictionary);
            if ([dictionary[@"response"] boolValue]) {
                NSLog(@"validacion correcta");
                if ([dictionary[@"region"] intValue] == 0) {
                    if ([self.productType isEqualToString:@"Eventos en vivo"]) {
                        [self purchaseProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.event1"];
                    } else {
                        [self purchaseProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.rent1"];
                    }
                } else if ([dictionary[@"region"] intValue] == 1) {
                    if ([self.productType isEqualToString:@"Eventos en vivo"]) {
                        [self purchaseProductWithIdentifier:@"net.icck.CaracolPlay.RM.event1"];
                    } else {
                        [self purchaseProductWithIdentifier:@"net.icck.CaracolPlay.RM.rent1"];
                    }
                }
            } else {
                NSLog(@"validacion incorrecta");
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } else {
            //Error en la respuesta
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", self.transactionID, self.productID] ]) {
        if (dictionary) {
            NSLog(@"Peticion RentContent exitosa: %@", dictionary);
            
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
        } else {
            NSLog(@"error en la respuesta del RentContent: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento. " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Custom Methods

-(void)purchaseProductWithIdentifier:(NSString *)productID {
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    //Request products from Appiiikle Servers
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

-(void)showErrorsInTermAndPoliticsConditions {
    if (![self.checkBox1 viewIsChecked]) {
        NSLog(@"chekmark 1 no chuleado");
        self.checkBox1.borderWidth = 3.0;
        self.checkBox1.borderColor = [UIColor redColor];
    }
    
    if (![self.checkBox2 viewIsChecked]) {
        NSLog(@"checkmark 2 no chuleado");
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

#pragma mark - Regex Stuff

-(BOOL)NSStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - Notifications Handler

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"recibí la notificación de compra");
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *transactionID = userInfo[@"TransactionID"];
    self.transactionID = transactionID;
    
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción, con el transacion id: %@", transactionID);
    [self rentContent];
}

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    NSLog(@"Falló la transacción");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:notificationInfo[@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
