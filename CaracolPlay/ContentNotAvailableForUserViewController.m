//
//  ContentNotAvailableForUserViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ContentNotAvailableForUserViewController.h"
#import "CPIAPHelper.h"
#import "RentContentConfirmationViewController.h"
#import "SuscriptionConfirmationViewController.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "IAPProduct.h"
#import "NSDictionary+NullReplacement.h"
#import "IAmCoder.h"
#import "FileSaver.h"
#import "RedeemCodeFromContentNotAvailbaleViewController.h"
#import "MBProgressHUD.h"
#import "ValidateCodeViewController.h"

@interface ContentNotAvailableForUserViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) NSString *transactionID;
@property (assign, nonatomic) BOOL userSelectedRentOption;
@property (assign, nonatomic) BOOL userSelectedSubscribeOption;
@property (assign, nonatomic) BOOL userSelectedRedeemOption;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@end

@implementation ContentNotAvailableForUserViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Make the navigation bar totally translucent
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
}

-(void)UISetup {
    // 1. Background image
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:screenFrame];
    backgroundImageView.image = [UIImage imageNamed:@"SuscriptionAlertBackground.png"];
    backgroundImageView.clipsToBounds = YES;
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundImageView];
    
    // 2. textview setup
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, screenFrame.size.height/2 - 40.0, screenFrame.size.width - 40.0, 100.0)];
    detailTextView.text = @"No tienes disponible este contenido. Elige una de las siguientes opciones para poder reproducir el video.";
    detailTextView.textColor = [UIColor whiteColor];
    detailTextView.font = [UIFont systemFontOfSize:15.0];
    detailTextView.userInteractionEnabled = NO;
    detailTextView.textAlignment = NSTextAlignmentCenter;
    detailTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:detailTextView];
    
    //'Alquilar' button setup
    if (self.viewType == 1 || self.viewType == 3) {
        UIButton *rentButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2.0 - 100.0, screenFrame.size.height/1.73, 200.0, 44.0)];
        [rentButton setTitle:@"Alquilar" forState:UIControlStateNormal];
        [rentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rentButton addTarget:self action:@selector(startRentProcess) forControlEvents:UIControlEventTouchUpInside];
        rentButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [rentButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
        [self.view addSubview:rentButton];
    }
    
    if (self.viewType == 2 || self.viewType == 3) {
        // 'Suscribete' button setup
        UIButton *suscribeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2.0 - 100.0, screenFrame.size.height/1.47, 200.0, 44.0)];
        [suscribeButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
        [suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [suscribeButton addTarget:self action:@selector(startSubscriptionProcess) forControlEvents:UIControlEventTouchUpInside];
        [suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
        suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.view addSubview:suscribeButton];
    }
    
    // 'Redimir código' button setup
    CGFloat buttonHeight = screenFrame.size.height/8.11;
    UIButton *redeemCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2 - 50.0, self.view.frame.size.height - 44.0 - buttonHeight, 100.0, buttonHeight)];
    [redeemCodeButton setTitle:@"Redimir\nCódigo" forState:UIControlStateNormal];
    [redeemCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [redeemCodeButton setBackgroundImage:[UIImage imageNamed:@"BotonRedimir.png"] forState:UIControlStateNormal];
    redeemCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [redeemCodeButton addTarget:self action:@selector(goToRedeemCodeFromContentNotAvailable) forControlEvents:UIControlEventTouchUpInside];
    redeemCodeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    redeemCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:redeemCodeButton];
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
    ValidateCodeViewController *validateCode = [self.storyboard instantiateViewControllerWithIdentifier:@"ValidateCode"];
    validateCode.controllerWasPresentedFromContentNotAvailable = YES;
    [self.navigationController pushViewController:validateCode animated:YES];
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

-(void)suscribe {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando";
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (products) {
                IAPProduct *product = [products firstObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }
    }];
}

#pragma mark - Custom Methods

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

-(void)goToRentConfirmationVC {
    RentContentConfirmationViewController *rentContentConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentConfirmation"];
    rentContentConfirmationVC.rentedProductionName = self.productName;
    rentContentConfirmationVC.userWasAlreadyLoggedin = YES;
    [self.navigationController pushViewController:rentContentConfirmationVC animated:YES];
}

-(void)goToSubscriptionConfirm {
    SuscriptionConfirmationViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmation"];
    suscriptionConfirmationVC.userWasAlreadyLoggedin = YES;
    suscriptionConfirmationVC.controllerWasPresentedFromProductionScreen = YES;
    [self.navigationController pushViewController:suscriptionConfirmationVC animated:YES];
}

#pragma mark - Server Stuff

-(void)subscribeUserInServer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Comprando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString * encodedUserInfo = [self generateEncodedUserInfoString];
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", encodedUserInfo];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", self.transactionID] andParameter:parameter
                                      httpMethod:@"POST"];
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
    hud.labelText = @"Cargando...";
    
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
    
    //////////////////////////////////////////////////////////////////////////
    //SubscribeUser
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", self.transactionID]]) {
        if (dictionary) {
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
            NSLog(@"error en la respuesta del SubscribeUser: %@", dictionary);
        }

    ///////////////////////////////////////////////////////////////////////////
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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
        [self rentProductInServer];
    } else if (self.userSelectedSubscribeOption) {
        [self subscribeUserInServer];
    }
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
