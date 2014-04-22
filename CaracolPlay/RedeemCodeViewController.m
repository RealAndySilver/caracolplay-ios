//
//  RedeemCodeViewController.m
//  CaracolPlay
//
//  Created by Developer on 30/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodeViewController.h"
#import "MainTabBarViewController.h"
#import "RedeemCodeAlertViewController.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "NSDictionary+NullReplacement.h"
#import "IAmCoder.h"
#import "FileSaver.h"
#import "MBProgressHUD.h"

@interface RedeemCodeViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) NSDictionary *userInfoDic;

@end

@implementation RedeemCodeViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.userTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    
    //We want to show the navigation bar
    self.navigationController.navigationBarHidden = NO;
    
    //Add a tap gesture to dismiss the keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self.continueButton addTarget:self action:@selector(startRedeemProcess) forControlEvents:UIControlEventTouchUpInside];
    
    //Create two FXBlurViews to blur the view when an alert is displayed.
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

#pragma mark - Custom Methods

-(void)startRedeemProcess {
    if (([self.userTextfield.text length] > 0) && [self.passwordTextfield.text length] > 0) {
        [self authenticateUserWithUserName:self.userTextfield.text andPassword:self.passwordTextfield.text];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

/*-(void)goToHomeScreen {
    if ([self.codeTextfield.text length] > 0) {
        //Test purposes only. If the user wrote something in the textfield, pass to the redeem code confirmation.
        RedeemCodeAlertViewController *redeemCodeAlertVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodeAlert"];
        [self.navigationController pushViewController:redeemCodeAlertVC animated:YES];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"El código no existe o no se puede canjear." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}*/

-(void)tap {
    [self.userTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
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

-(NSString *)generateEncodedUserInfoString {
    //Create JSON string with user info
    NSDictionary *userInfoDic = @{@"name": self.userInfoDic[@"nombres"],
                                  @"lastname" : self.userInfoDic[@"apellidos"],
                                  @"email" : self.userInfoDic[@"mail"],
                                  @"password" : self.passwordTextfield.text,
                                  @"alias" : self.userInfoDic[@"alias"],
                                  @"genero" : self.userInfoDic[@"genero"],
                                  @"fecha_de_nacimiento" : self.userInfoDic[@"fecha_de_nacimiento"]
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

-(void)goToRedeemCodeConfirmationWithMessage:(NSString *)message {
    RedeemCodeAlertViewController *redeemCodeConfirmation = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodeAlert"];
    redeemCodeConfirmation.redeemedProductions = message;
    if (self.controllerWasPresentedFromProductionScreen) {
        redeemCodeConfirmation.userWasLogout = YES;
    }
    if (self.controllerWasPresentedFromInitialScreen) {
        redeemCodeConfirmation.controllerWasPresentedFromInitialScreen = YES;
    } else if (self.controllerWasPresentedFromProductionScreen) {
        redeemCodeConfirmation.controllerWasPresentedFromProductionScreen = YES;
    }
    [self.navigationController pushViewController:redeemCodeConfirmation animated:YES];
}

#pragma mark - Server stuff

-(void)redeemCodeInServer:(NSString *)code {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Redimiendo...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@", @"RedeemCode", code] andParameter:parameter httpMethod:@"POST"];
}

-(void)authenticateUserWithUserName:(NSString *)userName andPassword:(NSString *)password {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Ingresando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [UserInfo sharedInstance].userName = userName;
    [UserInfo sharedInstance].password = password;
    [serverCommunicator callServerWithGETMethod:@"AuthenticateUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([methodName isEqualToString:@"AuthenticateUser"] && dictionary) {
        if ([dictionary[@"status"] boolValue]) {
            NSLog(@"autenticación exitosa: %@", dictionary);
            NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
            self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
            [self redeemCodeInServer:self.redeemedCode];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Los datos ingresados no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            NSLog(@"la autenticación no fue exitosa");
        }
        
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"RedeemCode", self.redeemedCode]]) {
        if (dictionary) {
            NSLog(@"Respuesta del redeem code: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"redencion correcta");
                //Save a key localy that indicates that the user is logged in
                FileSaver *fileSaver = [[FileSaver alloc] init];
                [UserInfo sharedInstance].session = dictionary[@"session"];
                [UserInfo sharedInstance].userID = dictionary[@"uid"];

                if ([dictionary[@"code"][@"type"] isEqualToString:@"me"]) {
                    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                               @"UserName" : [UserInfo sharedInstance].userName,
                                               @"Password" : [UserInfo sharedInstance].password,
                                               @"UserID" : dictionary[@"uid"],
                                               @"Session" : dictionary[@"session"]
                                               } withKey:@"UserHasLoginDic"];

                    NSString *redeemedProductionsString =
                        [self generateRedeemedProductionsStringUsingArrayWithName:dictionary[@"code"][@"items"]];
                    [self goToRedeemCodeConfirmationWithMessage:redeemedProductionsString];
                    
                } else if ([dictionary[@"code"][@"type"] isEqualToString:@"s"]) {
                    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                               @"UserName" : [UserInfo sharedInstance].userName,
                                               @"Password" : [UserInfo sharedInstance].password,
                                               @"UserID" : dictionary[@"uid"],
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
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"code"][@"msg"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        } else {
            [UserInfo sharedInstance].userName = nil;
            [UserInfo sharedInstance].password = nil;
            NSLog(@"error en la peticion de redimir: %@", dictionary);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error redimiendo el código. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
