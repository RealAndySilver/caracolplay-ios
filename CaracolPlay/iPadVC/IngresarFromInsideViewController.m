//
//  IngresarFromInsideViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarFromInsideViewController.h"
#import "FileSaver.h"
#import "CPIAPHelper.h"
#import "RentConfirmFromInsideViewController.h"
#import "SuscribeConfirmFromInsideViewController.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "NSDictionary+NullReplacement.h"
#import "IAPProduct.h"
#import "IAmCoder.h"
#import "MBProgressHUD.h"
#import "UserDefaultsSaver.h"

@interface IngresarFromInsideViewController () <ServerCommunicatorDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *wrongUserImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongPassImageView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@property (strong, nonatomic) NSString *transactionID;
@property (assign, nonatomic) BOOL rentPurchaseSuccededInItunes;
@property (assign, nonatomic) BOOL subscribePurchaseSuccededInItunes;
@end

@implementation IngresarFromInsideViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.rentPurchaseSuccededInItunes = NO;
    self.subscribePurchaseSuccededInItunes = NO;
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

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 400.0);
    //self.view.layer.cornerRadius = 10.0;
    //self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(0.0, 0.0, 320.0, 400.0);
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
}

-(void)setupUI {
    [self clearAllWrongImageViews];
    
    self.userTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    
    /*self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundFormularioPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];*/
    
    //1. dismiss buton setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"BackArrow"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //Enter button
    if (self.controllerWasPresentedFromRentScreen) {
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
        [self.enterButton setTitle:@"Alquilar" forState:UIControlStateNormal];
        
    } else if (self.controllerWasPresentFromAlertScreen) {
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
        [self.enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    
    } else if (self.controllerWasPresentedFromSuscriptionScreen) {
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
        [self.enterButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
    }
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*-(void)suscribe {
    if ([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0) {
        [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            [MBHUDView dismissCurrentHUD];
            if (success) {
                IAPProduct *product = [products firstObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}*/

/*-(void)rentProduction {
    if ([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0) {
        [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            [MBHUDView dismissCurrentHUD];
            if (success) {
                IAPProduct *product = [products lastObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }];

    } else {
         [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}*/

-(void)enter {
    [self clearAllWrongImageViews];
    
    BOOL userIsCorrect = NO;
    BOOL passwordIsCorrect = NO;
    if ([self.userTextfield.text length] > 0) {
        userIsCorrect = YES;
    } else {
        self.wrongUserImageView.alpha = 1.0;
    }
    
    if ([self.passwordTextfield.text length] > 0) {
        passwordIsCorrect = YES;
    } else {
        self.wrongPassImageView.alpha = 1.0;
    }
    
    if (userIsCorrect && passwordIsCorrect) {
        [self authenticateUserWithUserName:self.userTextfield.text andPassword:self.passwordTextfield.text];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)returnToProduction {
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
    if (self.controllerWasPresentFromAlertScreen) {
        [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        }];
    } else if (self.controllerWasPresentedFromSuscriptionScreen || self.controllerWasPresentedFromRentScreen) {
        [[[[self presentingViewController] presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        }];
    }
}

-(void)goToSubscriptionConfirm {
    SuscribeConfirmFromInsideViewController *suscribeConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscribeConfirmFromInside"];
    suscribeConfirmVC.controllerWasPresentedFromIngresarScreen = YES;
    suscribeConfirmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    suscribeConfirmVC.userIsLoggedIn = NO;
    [self presentViewController:suscribeConfirmVC animated:YES completion:nil];
}

-(void)goToRentConfirmationVC {
    RentConfirmFromInsideViewController *rentConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentConfirmFromInside"];
    rentConfirmVC.controllerWasPresentedFromIngresarFromInside = YES;
    rentConfirmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rentConfirmVC.rentedProductionName = self.productName;
    rentConfirmVC.userIsLoggedIn = NO;
    [self presentViewController:rentConfirmVC animated:YES completion:nil];
}

#pragma mark - Server Stuff

-(void)authenticateUserWithUserName:(NSString *)userName andPassword:(NSString *)password {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [UserInfo sharedInstance].userName = userName;
    [UserInfo sharedInstance].password = password;
    
    [serverCommunicator callServerWithGETMethod:@"AuthenticateUser" andParameter:@""];
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

-(void)rentContentInServerWithTransactionID:(NSString *)transactionID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Comprando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", transactionID, self.productID] andParameter:parameters httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //////////////////////////////////////////////////////////////////
    //Authenticate User
    if ([methodName isEqualToString:@"AuthenticateUser"]) {
        if ([dictionary[@"status"] boolValue]) {
            NSLog(@"autenticación exitosa: %@", dictionary);
            
            
            NSArray *myListsArray = dictionary[@"user"][@"my_list"];
            NSMutableArray *myListIds = [[NSMutableArray alloc] init];
            for (NSDictionary *myListDict in myListsArray) {
                [myListIds addObject:myListDict[@"id"]];
            }
            [UserInfo sharedInstance].myListIds = myListIds;
            
            //Save a key localy that indicates that the user is logged in
            FileSaver *fileSaver = [[FileSaver alloc] init];
            [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                       @"UserName" : [UserInfo sharedInstance].userName,
                                       @"Password" : [UserInfo sharedInstance].password,
                                       @"MyLists": [UserInfo sharedInstance].myListIds,
                                       @"Session" : dictionary[@"session"],
                                       @"UserID" : dictionary[@"uid"],
                                       @"IsSuscription" : @([dictionary[@"user"][@"is_suscription"] boolValue]),
                                       @"Session_Key" : dictionary[@"session_key"],
                                       @"Session_Expires" : dictionary[@"session_expires"]
                                       } withKey:@"UserHasLoginDic"];

            [UserInfo sharedInstance].userID = dictionary[@"uid"];
            [UserInfo sharedInstance].session = dictionary[@"session"];
            [UserInfo sharedInstance].isSubscription = [dictionary[@"user"][@"is_suscription"] boolValue];
            [UserInfo sharedInstance].sessionKey = dictionary[@"session_key"];
            int expiresTimestamp = [dictionary[@"session_expires"] intValue];
            [UserInfo sharedInstance].session_expires = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:expiresTimestamp];
            [[UserInfo sharedInstance] setAuthCookieForWebView];
            [[UserInfo sharedInstance] persistUserLists];
         
            
            NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
            self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
            if (self.controllerWasPresentFromAlertScreen) {
                [self returnToProduction];
                
            } else if (self.controllerWasPresentedFromSuscriptionScreen) {
                if (![dictionary[@"user"][@"is_suscription"] boolValue]) {
                    //Request products from Apple because the user is not suscribe
                    if ([dictionary[@"region"] intValue] == 0) {
                        [self buyProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.subscription"];
                    } else if ([dictionary[@"region"] intValue] == 1) {
                        [self buyProductWithIdentifier:@"net.icck.CaracolPlay.RM.subscription"];
                    }
                } else {
                    //the user is suscribe, don't allow him to buy, pass directly to home screen
                    [self returnToProduction];
                    //[[[UIAlertView alloc] initWithTitle:nil message:@"Tu usuario ya posee una suscripción." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
                
            } else if (self.controllerWasPresentedFromRentScreen) {
                if (![dictionary[@"user"][@"is_suscription"] boolValue]) {
                    //Request products from Apple because the user is not suscribe
                    if ([dictionary[@"region"] intValue] == 0) {
                        if ([self.productType isEqualToString:@"Eventos en vivo"] || [self.productType isEqualToString:@"Películas"] || [self.productType isEqualToString:@"Documentales"]) {
                            [self buyProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.event1"];
                        } else {
                            [self buyProductWithIdentifier:@"net.icck.CaracolPlay.Colombia.rent1"];
                        }
                    } else if ([dictionary[@"region"] intValue] == 1) {
                        if ([self.productType isEqualToString:@"Eventos en vivo"] || [self.productType isEqualToString:@"Películas"] || [self.productType isEqualToString:@"Documentales"]) {
                            [self buyProductWithIdentifier:@"net.icck.CaracolPlay.RM.event1"];
                        } else {
                            [self buyProductWithIdentifier:@"net.icck.CaracolPlay.RM.rent1"];
                        }
                    }
                } else {
                    //the user is suscribe, don't allow him to buy, pass directly to home screen
                    [self returnToProduction];
                    //[[[UIAlertView alloc] initWithTitle:nil message:@"Tu usuario ya posee una suscripción." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
            }
            
        } else {
            self.wrongUserImageView.alpha = 1.0;
            self.wrongPassImageView.alpha = 1.0;
            
            NSLog(@"la autenticación no fue exitosa: %@", dictionary);
            [UserInfo sharedInstance].userName = nil;
            [UserInfo sharedInstance].password = nil;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }

    ///////////////////////////////////////////////////////////////////
    //SubscribeUser
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", self.transactionID]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]){
                self.subscribePurchaseSuccededInItunes = NO;
                [UserDefaultsSaver deletePurchaseDics];
                NSLog(@"Peticion SuscribeUser exitosa: %@", dictionary);
                
                //Save a key localy that indicates that the user is logged in
                FileSaver *fileSaver = [[FileSaver alloc] init];
                [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                           @"UserName" : [UserInfo sharedInstance].userName,
                                           @"Password" : [UserInfo sharedInstance].password,
                                           @"Session" : dictionary[@"session"],
                                           @"IsSuscription" : @YES
                                           } withKey:@"UserHasLoginDic"];
                [UserInfo sharedInstance].userID = dictionary[@"uid"];
                [UserInfo sharedInstance].session = dictionary[@"session"];
                [UserInfo sharedInstance].isSubscription = YES;
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
     
    ///////////////////////////////////////////////////////////////////////
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al alquilar la producción en  CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
                alert.tag = 2;
                [alert show];
            }
            
        } else {
            [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"rent" transactionId:self.transactionID productId:self.productID];
            NSLog(@"error en la respuesta del RentContent: %@", dictionary);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al alquilar la producción en  CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
            alert.tag = 2;
            [alert show];
        }

    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.subscribePurchaseSuccededInItunes) {
        [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"subscription" transactionId:self.transactionID productId:@""];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al suscribirse en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
        
    } else if (self.rentPurchaseSuccededInItunes) {
        [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"rent" transactionId:self.transactionID productId:self.productID];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al alquilar la producción en  CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
        
    } else {
           [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Custom Methods

-(void)clearAllWrongImageViews {
    self.wrongUserImageView.alpha = 0.0;
    self.wrongPassImageView.alpha = 0.0;
}

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
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Imposible conectarse con iTunes Store" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
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
    NSDictionary *userInfo = [notification userInfo];
    NSString *transactionID = userInfo[@"TransactionID"];
    self.transactionID = transactionID;
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción, con el transacion id: %@", transactionID);
    if (self.controllerWasPresentedFromSuscriptionScreen) {
        [self suscribeUserInServerWithTransactionID:transactionID];
        self.subscribePurchaseSuccededInItunes = YES;
    } else if (self.controllerWasPresentedFromRentScreen) {
        [self rentContentInServerWithTransactionID:transactionID];
        self.rentPurchaseSuccededInItunes = YES;
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self suscribeUserInServerWithTransactionID:self.transactionID];
    } else if (alertView.tag == 2) {
        [self rentContentInServerWithTransactionID:self.transactionID];
    }
}

/*-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"Me llegó la notificación de compraaaa");
    
    
    //Save a key locally, indicating that the user has logged in.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
    }
    
    if (self.controllerWasPresentedFromRentScreen) {
        //The user can pass to the rent confirmation view controller
        RentConfirmFromInsideViewController *rentConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentConfirmFromInside"];
        rentConfirmVC.modalPresentationStyle = UIModalPresentationFormSheet;
        rentConfirmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        rentConfirmVC.controllerWasPresentedFromIngresarFromInside = YES;
        [self presentViewController:rentConfirmVC animated:YES completion:nil];
    
    } else if (self.controllerWasPresentedFromSuscriptionScreen) {
        SuscribeConfirmFromInsideViewController *suscribeConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscribeConfirmFromInside"];
        suscribeConfirmVC.modalPresentationStyle = UIModalPresentationFormSheet;
        suscribeConfirmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        suscribeConfirmVC.controllerWasPresentedFromIngresarScreen = YES;
        [self presentViewController:suscribeConfirmVC animated:YES completion:nil];
    }
}*/

/*-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"empezé a editarme");
    self.enterButton.userInteractionEnabled = NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.enterButton.userInteractionEnabled = YES;
    NSLog(@"terminé de editarme");
}*/

@end
