//
//  RentContentViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 17/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RentContentViewController.h"
#import "FileSaver.h"
#import "CPIAPHelper.h"
#import "RentContentConfirmationViewController.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "IAPProduct.h"
#import "NSDictionary+NullReplacement.h"
#import "IAmCoder.h"
#import "MBProgressHUD.h"

@interface RentContentViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *wrongPassImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongUserImageView;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (weak, nonatomic) IBOutlet UIButton *rentButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) NSString *transactionID;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@end

@implementation RentContentViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Register as an observer of the notification -UserDidSuscribe.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailedNotificationReceived:) name:@"TransactionFailedNotification" object:nil];

    
    //Hide the red image views
    self.wrongUserImageView.alpha = 0.0;
    self.wrongPassImageView.alpha = 0.0;
    
    self.userTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    [self.rentButton addTarget:self action:@selector(startRentProcess) forControlEvents:UIControlEventTouchUpInside];
    
    //Create a tap gesture to dismiss the keyboard that appears when the
    //user touches a textfield
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Actions

-(void)startRentProcess {
    self.wrongPassImageView.alpha = 0.0;
    self.wrongUserImageView.alpha = 0.0;
    
    BOOL userIsCorrect = NO;
    BOOL passIsCorrect = NO;
    
    if ([self.userTextfield.text length] > 0) {
        userIsCorrect = YES;
    } else {
        self.wrongUserImageView.alpha = 1.0;
    }
    
    if ([self.passwordTextfield.text length] > 0) {
        passIsCorrect = YES;
    } else {
        self.wrongPassImageView.alpha = 1.0;
    }
    
    if (userIsCorrect && passIsCorrect) {
        [self authenticateUserWithUserName:self.userTextfield.text andPassword:self.passwordTextfield.text];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor completa todos los campos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)dismissKeyboard {
    [self.userTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

#pragma mark - CUstom Methods

-(NSString *)generateEncodedUserInfoString {
    //Create JSON string with user info
    NSDictionary *userInfoDic = @{@"name": self.userInfoDic[@"nombres"],
                                  @"lastname" : self.userInfoDic[@"apellidos"],
                                  @"email" : self.userInfoDic[@"mail"],
                                  @"password" : self.passwordTextfield.text,
                                  @"alias" : self.userInfoDic[@"alias"]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Json String: %@", jsonString);
    NSString *encodedJsonString = [IAmCoder base64EncodeString:jsonString];
    return encodedJsonString;
}

-(void)rentProductWithIdentifier:(NSString *)productIdentifier {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando...";
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (products) {
                for (IAPProduct *product in products) {
                    if ([product.productIdentifier isEqualToString:productIdentifier]) {
                        [[CPIAPHelper sharedInstance] buyProduct:product];
                        break;
                    }
                }
            }
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Imposible conectarse con iTunes Store" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

-(void)goToRentConfirmationVC {
    RentContentConfirmationViewController *rentContentConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentConfirmation"];
    rentContentConfirmationVC.rentedProductionName = self.productName;
    [self.navigationController pushViewController:rentContentConfirmationVC animated:YES];
}

#pragma mark - Server Stuff

-(void)rentContent {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Comprando...";
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", self.transactionID, self.productID] andParameter:parameters httpMethod:@"POST"];
}

-(void)authenticateUserWithUserName:(NSString *)userName andPassword:(NSString *)password {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Ingresando...";
    
    [UserInfo sharedInstance].userName = userName;
    [UserInfo sharedInstance].password = password;
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"AuthenticateUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([methodName isEqualToString:@"AuthenticateUser"]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                //Autenticacion correcta
                NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
                self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
                
                if ([dictionary[@"region"] intValue] == 0) {
                    if ([self.productType isEqualToString:@"Eventos en vivo"] || [self.productType isEqualToString:@"Películas"]) {
                        [self rentProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.event1"];
                    } else {
                        [self rentProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.rent1"];
                    }
                } else if ([dictionary[@"region"] intValue] == 1) {
                    if ([self.productType isEqualToString:@"Eventos en vivo"] || [self.productType isEqualToString:@"Películas"]) {
                        [self rentProductWithIdentifier:@"net.icck.CaracolPlay.RM.event1"];
                    } else {
                        [self rentProductWithIdentifier:@"net.icck.CaracolPlay.RM.rent1"];
                    }
                }
                
            } else {
                self.wrongPassImageView.alpha = 1.0;
                self.wrongUserImageView.alpha = 1.0;
                
                NSLog(@"la autenticación no fue exitosa: %@", dictionary);
                [UserInfo sharedInstance].userName = nil;
                [UserInfo sharedInstance].password = nil;
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        }
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", self.transactionID, self.productID] ]) {
        if (dictionary) {
            NSLog(@"Peticion SuscribeUser exitosa: %@", dictionary);
            
            //Save a key localy that indicates that the user is logged in
            FileSaver *fileSaver = [[FileSaver alloc] init];
            [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                       @"UserName" : [UserInfo sharedInstance].userName,
                                       @"Password" : [UserInfo sharedInstance].password,
                                       @"UserID" : dictionary[@"uid"],
                                       @"Session" : dictionary[@"session"]
                                       } withKey:@"UserHasLoginDic"];
            
            [UserInfo sharedInstance].userID = dictionary[@"uid"];
            [UserInfo sharedInstance].session = dictionary[@"session"];
            
            //Go to Suscription confirmation VC
            [self goToRentConfirmationVC];
        } else {
            NSLog(@"error en la respuesta del SubscribeUser: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handlers

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"recibí la notificación de compra");
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *transactionID = userInfo[@"TransactionID"];
    self.transactionID = transactionID;
    
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción, con el transacion id: %@", transactionID);
    [self rentContent];
}

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Me llegó la notificacion de que falló la transaccion");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:notificationInfo[@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
