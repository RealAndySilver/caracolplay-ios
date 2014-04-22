//
//  IngresarPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarPadViewController.h"
#import "SuscriptionConfirmationPadViewController.h"
#import "MainTabBarPadController.h"
#import "FileSaver.h"
#import "CPIAPHelper.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "NSDictionary+NullReplacement.h"
#import "IAPProduct.h"
#import "IAmCoder.h"
#import "MBProgressHUD.h"
@import QuartzCore;

@interface IngresarPadViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@property (strong, nonatomic) NSString *transactionID;
@end

@implementation IngresarPadViewController

#pragma mark - View Lifecycle

-(void)UISetup {
    if (self.controllerWasPresentedFromInitialScreen) {
        [self.enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
        
    } else if (self.controllerWasPresentedFromInitialSuscriptionScreen) {
        [self.enterButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //1. Background image setup
    self.backgroundImageView = [[UIImageView alloc] init];
    if (self.controllerWasPresentedFromInitialScreen) {
        self.backgroundImageView.image = [UIImage imageNamed:@"BackgroundIngresarPad.png"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"BackgroundFormularioPad.png"];
    }
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //2. 'Cerrar' button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    self.userTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.controllerWasPresentedFromInitialSuscriptionScreen) {
        //Register as an observer of the notification 'UserDidSuscribe'
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidSuscribeNotificationReceived:)
                                                     name:@"UserDidSuscribe"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailedNotificationReceived:) name:@"TransactionFailedNotification" object:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //Set our superview bounds, in order to present this view with the correct size (320, 386)
    if (self.viewHeight != 0 && self.viewWidth != 0) {
        //320 597
        NSLog(@"entré acá mirá con los datos %f, %f", self.viewWidth, self.viewHeight);
        self.view.superview.bounds = CGRectMake(0.0, 0.0, self.viewWidth, self.viewHeight);
        self.view.frame = CGRectMake(-10, -10, self.viewWidth + 20.0, self.viewHeight + 20);
    } else {
        NSLog(@"entre aca porque no habia altura ni ancho");
        self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 386.0);
        self.view.frame = CGRectMake(-10.0, -10.0, 320.0, 386.0);
    }
    
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;

    //Set Subviews frames
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 58, -25.0, 88.0, 88.0);
    self.backgroundImageView.frame = self.view.bounds;
}

#pragma mark - Actions

-(void)enter {
    if (([self.userTextfield.text length] > 0) && [self.passwordTextfield.text length] > 0) {
        [self authenticateUserWithUserName:self.userTextfield.text andPassword:self.passwordTextfield.text];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

/*-(void)enterSuscribeAndGoToHomeScreen {
    if (([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0)) {
        [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            [MBHUDView dismissCurrentHUD];
            if (success) {
                IAPProduct *product = [products firstObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}*/

-(void)goToHomeScreen {
    MainTabBarPadController *mainTabBarPadController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    [self presentViewController:mainTabBarPadController animated:YES completion:nil];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Methods

-(void)buySubscriptionWithIdentifier:(NSString *)productIdentifier {
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

-(void)goToSubscriptionConfirm {
    NSLog(@"Me llegó la notificación de compraaaa");
    
    //The user can pass to the suscription confirmation view controller
    SuscriptionConfirmationPadViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmationPad"];
    suscriptionConfirmationVC.controllerWasPresentedFromInitialScreen = YES;
    suscriptionConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    suscriptionConfirmationVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:suscriptionConfirmationVC animated:YES completion:nil];
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

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    ///////////////////////////////////////////////////////////////////////
    //Authenticate user
    if ([methodName isEqualToString:@"AuthenticateUser"] && dictionary) {
        if ([dictionary[@"status"] boolValue]) {
            NSLog(@"autenticación exitosa: %@", dictionary);
            
            //Save a key localy that indicates that the user is logged in
            FileSaver *fileSaver = [[FileSaver alloc] init];
            [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                       @"UserName" : [UserInfo sharedInstance].userName,
                                       @"Password" : [UserInfo sharedInstance].password,
                                       @"Session" : dictionary[@"session"],
                                       @"IsSuscription" : @([dictionary[@"user"][@"is_suscription"] boolValue])
                                       } withKey:@"UserHasLoginDic"];
            [UserInfo sharedInstance].userID = dictionary[@"uid"];
            [UserInfo sharedInstance].session = dictionary[@"session"];
            [UserInfo sharedInstance].isSubscription = [dictionary[@"user"][@"is_suscription"] boolValue];
            
            NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
            self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
            
            if (self.controllerWasPresentedFromInitialScreen) {
                [self goToHomeScreen];
                
            } else if (self.controllerWasPresentedFromInitialSuscriptionScreen) {
                if (![dictionary[@"user"][@"is_suscription"] boolValue]) {
                    //Request products from Apple because the user is not suscribe
                    if ([dictionary[@"region"] intValue] == 0) {
                        [self buySubscriptionWithIdentifier:@"net.icck.CaracolPlay.Colombia.subscription"];
                    } else if ([dictionary[@"region"] intValue] == 1) {
                        [self buySubscriptionWithIdentifier:@"net.icck.CaracolPlay.RM.subscription"];
                    }
                } else {
                    //the user is suscribe, don't allow him to buy, pass directly to home screen
                    [self goToHomeScreen];
                    //[[[UIAlertView alloc] initWithTitle:nil message:@"Tu usuario ya posee una suscripción." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
            }
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
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
    
    /////////////////////////////////////////////////////////////////////////
    } else {
        NSLog(@"error en la respuesta: %@", dictionary);
        [UserInfo sharedInstance].userName = nil;
        [UserInfo sharedInstance].password = nil;
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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
    [self suscribeUserInServerWithTransactionID:transactionID];
}

/*-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"Me llegó la notificación de compraaaa");
    //Save a key locally, indicating that the user has logged in.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
    
    //The user can pass to the suscription confirmation view controller
    SuscriptionConfirmationPadViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmationPad"];
    suscriptionConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    suscriptionConfirmationVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:suscriptionConfirmationVC animated:YES completion:nil];
}*/

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
