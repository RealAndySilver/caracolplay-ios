//
//  ContentNotAvailableForUserPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 13/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ContentNotAvailableForUserPadViewController.h"
#import "ServerCommunicator.h"
#import "NSDictionary+NullReplacement.h"
#import "IAPProduct.h"
#import "FileSaver.h"
#import "UserInfo.h"
#import "CPIAPHelper.h"
#import "IAmCoder.h"
#import "RentConfirmFromInsideViewController.h"
#import "SuscribeConfirmFromInsideViewController.h"
#import "ValidateCodePadViewController.h"
#import "MBProgressHUD.h"
#import "UserDefaultsSaver.h"

@interface ContentNotAvailableForUserPadViewController () <ServerCommunicatorDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UITextView *detailTextView;
@property (strong, nonatomic) UIButton *rentButton;
@property (strong, nonatomic) UIButton *suscribeButton;
@property (strong, nonatomic) UIButton *redeemCodeButton;
@property (strong, nonatomic) NSString *transactionID;
@property (assign, nonatomic) BOOL userSelectedRentOption;
@property (assign, nonatomic) BOOL userSelectedSubscribeOption;
@property (assign, nonatomic) BOOL userSelectedRedeemOption;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@property (assign, nonatomic) BOOL rentPurchaseSuccededInItunes;
@property (assign, nonatomic) BOOL subscriptionPurchaseSuccededInItunes;
@end

@implementation ContentNotAvailableForUserPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.rentPurchaseSuccededInItunes = NO;
    self.subscriptionPurchaseSuccededInItunes = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    //Reigster as an observer to the user suscribe notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transactionFailedNotificationReceived:)
                                                 name:@"TransactionFailedNotification"
                                               object:nil];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [super viewWillLayoutSubviews];
    /*self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 617.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 617.0 + 20.0);*/
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -10.0, 88.0, 88.0);
    self.detailTextView.frame = CGRectMake(self.view.bounds.size.width/2.0 - 170.0, self.view.bounds.size.height/2 - 40.0, 340.0, 100.0);
    self.redeemCodeButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 55.0, 600.0, 110.0, 110.0);
    
    if (self.viewType == 1 || self.viewType == 3) {
        self.rentButton.frame = CGRectMake(self.view.bounds.size.width/2 - 150.0, self.view.bounds.size.height/1.65, 300.0, 45.0);
    }
    
    if (self.viewType == 2 || self.viewType == 3) {
        self.suscribeButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height/1.44, 300.0, 44.0);
    }
}

-(void)UISetup {
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SuscriptionAlertFullScreenBackground.png"]];
    [self.view addSubview:self.backgroundImageView];
    
    //1. dismiss buton setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    // 2. textview setup
    self.detailTextView = [[UITextView alloc] init];
    self.detailTextView.text = @"No tienes disponible este contenido. Elige una de las siguientes opciones para poder reproducir el video.";
    self.detailTextView.textColor = [UIColor whiteColor];
    self.detailTextView.font = [UIFont systemFontOfSize:15.0];
    self.detailTextView.userInteractionEnabled = NO;
    self.detailTextView.textAlignment = NSTextAlignmentCenter;
    self.detailTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.detailTextView];
    
    //'Alquilar' button setup
    self.rentButton = [[UIButton alloc] init];
    [self.rentButton setTitle:@"Alquilar" forState:UIControlStateNormal];
    [self.rentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rentButton addTarget:self action:@selector(startRentProcess) forControlEvents:UIControlEventTouchUpInside];
    self.rentButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.rentButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.rentButton];
    
    // 'Suscribete' button setup
    self.suscribeButton = [[UIButton alloc] init];
    [self.suscribeButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
    [self.suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.suscribeButton addTarget:self action:@selector(startSubscriptionProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.suscribeButton];
    
    // 'Redimir código' button setup
    self.redeemCodeButton = [[UIButton alloc] init];
    [self.redeemCodeButton setTitle:@"Redimir\nCódigo" forState:UIControlStateNormal];
    [self.redeemCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.redeemCodeButton setBackgroundImage:[UIImage imageNamed:@"BotonRedimirPad.png"] forState:UIControlStateNormal];
    self.redeemCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.redeemCodeButton addTarget:self action:@selector(goToRedeemCodeFromContentNotAvailable) forControlEvents:UIControlEventTouchUpInside];
    self.redeemCodeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.redeemCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[self.view addSubview:self.redeemCodeButton];
}

#pragma mark - Actions 

-(void)startRentProcess {
    self.userSelectedRentOption = YES;
    self.userSelectedRedeemOption = NO;
    self.userSelectedSubscribeOption = NO;
    [self authenticateUser];
}

-(void)startSubscriptionProcess {
    self.userSelectedRedeemOption = NO;
    self.userSelectedSubscribeOption = YES;
    self.userSelectedRentOption = NO;
    [self authenticateUser];
}

-(void)goToRedeemCodeFromContentNotAvailable {
    ValidateCodePadViewController *validateCodeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ValidateCodePad"];
    validateCodeVC.modalPresentationStyle = UIModalPresentationPageSheet;
    validateCodeVC.controllerWasPresentedFromContentNotAvailable = YES;
    [self presentViewController:validateCodeVC animated:YES completion:nil];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Server Stuff

-(void)subscribeUserInServer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Comprando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString * encodedUserInfo = [self generateEncodedUserInfoString];
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", encodedUserInfo];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", self.transactionID] andParameter:parameter httpMethod:@"POST"];
}

-(void)rentProductInServer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Comprando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", self.transactionID, self.productID] andParameter:parameters httpMethod:@"POST"];
}

-(void)authenticateUser {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"AuthenticateUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    /////////////////////////////////////////////////////////////////////
    //AuthenticateUser
    if ([methodName isEqualToString:@"AuthenticateUser"] && dictionary) {
        if ([dictionary[@"status"] boolValue]) {
            NSLog(@"autenticación exitosa: %@", dictionary);
            NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
            self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
            
            if ([dictionary[@"region"] intValue] == 0) {
                //Colombia
                if (self.userSelectedRentOption) {
                    if ([self.productType isEqualToString:@"Eventos en vivo"] || [self.productType isEqualToString:@"Películas"]) {
                        [self buyProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.event1"];
                    } else {
                        [self buyProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.rent1"];
                    }
                } else if (self.userSelectedSubscribeOption) {
                    [self buyProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.subscription"];
                }
                
            } else if ([dictionary[@"region"] intValue] == 1) {
                //Rest of the world
                if (self.userSelectedRentOption) {
                    if ([self.productType isEqualToString:@"Eventos en vivo"] || [self.productType isEqualToString:@"Películas"]) {
                        [self buyProductWithIdentifier:@"net.icck.CaracolPlay.RM.event1"];
                    } else {
                        [self buyProductWithIdentifier:@"net.icck.CaracolPlay.RM.rent1"];
                    }
                } else if (self.userSelectedSubscribeOption) {
                    [self buyProductWithIdentifier:@"net.icck.CaracolPlay.RM.subscription"];
                }
            }
        } else {
            NSLog(@"La autenticación no fue exitosa");
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error intentanto comprar con tu usuario. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
        /////////////////////////////////////////////////////////////////////////
        //RentContent
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", self.transactionID, self.productID]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                self.rentPurchaseSuccededInItunes = NO;
                [UserDefaultsSaver deletePurchaseDics];
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
                [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"rent" transactionId:self.transactionID productId:self.productID];
                NSLog(@"error en la respuesta del RentContent: %@", dictionary);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al alquilar la producción en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
                alert.tag = 2;
                [alert show];
            }
            
        } else {
            [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"rent" transactionId:self.transactionID productId:self.productID];
            NSLog(@"error en la respuesta del RentContent: %@", dictionary);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al alquilar la producción en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
            alert.tag = 2;
            [alert show];
        }
        
        //////////////////////////////////////////////////////////////////////////
        //SubscribeUser
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", self.transactionID]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                self.subscriptionPurchaseSuccededInItunes = NO;
                [UserDefaultsSaver deletePurchaseDics];
                NSLog(@"Peticion SuscribeUser exitosa: %@", dictionary);
                
                //Save a key localy that indicates that the user is logged in
                FileSaver *fileSaver = [[FileSaver alloc] init];
                [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                           @"UserName" : [UserInfo sharedInstance].userName,
                                           @"Password" : [UserInfo sharedInstance].password,
                                           @"Session" : dictionary[@"session"]
                                           } withKey:@"UserHasLoginDic"];
                [UserInfo sharedInstance].session = dictionary[@"session"];
                
                //Go to Suscription confirmation VC
                [self goToSubscriptionConfirm];
            } else {
                [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"subscription" transactionId:self.transactionID productId:@""];
                NSLog(@"error en la respuesta del SubscribeUser: %@", dictionary);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al suscribirse en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
            }
        
        } else {
            [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"subscription" transactionId:self.transactionID productId:@""];
            NSLog(@"error en la respuesta del SubscribeUser: %@", dictionary);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al suscribirse en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
        }
        
        ///////////////////////////////////////////////////////////////////////////
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.rentPurchaseSuccededInItunes) {
        [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"rent" transactionId:self.transactionID productId:self.productID];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al alquilar la producción en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
        
    } else if (self.subscriptionPurchaseSuccededInItunes) {
        [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"subscription" transactionId:self.transactionID productId:@""];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al suscribirse en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
        
    } else {
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Custom Methods

-(void)goToRentConfirmationVC {
    RentConfirmFromInsideViewController *rentConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentConfirmFromInside"];
    rentConfirmVC.controllerWasPresentedFromContentNotAvailable = YES;
    rentConfirmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rentConfirmVC.rentedProductionName = self.productName;
    rentConfirmVC.userIsLoggedIn = YES;
    [self presentViewController:rentConfirmVC animated:YES completion:nil];
}

-(void)goToSubscriptionConfirm {
    SuscribeConfirmFromInsideViewController *suscribeConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscribeConfirmFromInside"];
    suscribeConfirmVC.controllerWasPresenteFromContentNotAvailable = YES;
    suscribeConfirmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    suscribeConfirmVC.userIsLoggedIn = YES;
    [self presentViewController:suscribeConfirmVC animated:YES completion:nil];
}

-(void)buyProductWithIdentifier:(NSString *)productIdentifier {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Comprando...";
    
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
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error accediendo al producto. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

-(NSString *)generateEncodedUserInfoString {
    //Create JSON string with user info
    NSDictionary *userInfoDic = @{@"name": self.userInfoDic[@"nombres"],
                                  @"lastname" : self.userInfoDic[@"apellidos"],
                                  @"email" : self.userInfoDic[@"mail"],
                                  @"password" : [UserInfo sharedInstance].password,
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

#pragma mark - Notification Handler

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Falló la notificación");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:notificationInfo[@"Message"]
                               delegate:self cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"recibí la notificación");
    NSDictionary *productInfo = [notification userInfo];
    NSString *transactionID = productInfo[@"TransactionID"];
    self.transactionID = transactionID;
    if (self.userSelectedRentOption) {
        self.rentPurchaseSuccededInItunes = YES;
        [self rentProductInServer];
    } else if (self.userSelectedSubscribeOption) {
        [self subscribeUserInServer];
        self.subscriptionPurchaseSuccededInItunes = YES;
    }
}

#pragma mark - UIalertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self subscribeUserInServer];
    } else if (alertView.tag == 2) {
        [self rentProductInServer];
    }
}

@end
