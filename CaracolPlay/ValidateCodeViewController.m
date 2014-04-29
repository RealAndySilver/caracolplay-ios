//
//  ValidateCodeViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 15/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ValidateCodeViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "VideoPlayerViewController.h"
#import "RedeemCodeFormViewController.h"
#import "RedeemCodeAlertViewController.h"
#import "UserInfo.h"
#import "NSDictionary+NullReplacement.h"
#import "FileSaver.h"

@interface ValidateCodeViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *wrongCodeImageView;
@property (weak, nonatomic) IBOutlet UITextField *codeTextfield;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@end

@implementation ValidateCodeViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    self.wrongCodeImageView.alpha = 0.0;
    self.codeTextfield.delegate = self;
    [self.continueButton addTarget:self action:@selector(validateCode) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Actions 

-(void)startRedeemProcess {
    [self authenticateUserWithUserName:[UserInfo sharedInstance].userName andPassword:[UserInfo sharedInstance].password];
}

-(void)goToRedeemCodeConfirmationWithMessage:(NSString *)message {
    RedeemCodeAlertViewController *redeemCodeConfirmation = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodeAlert"];
    redeemCodeConfirmation.userWasLogout = NO;
    redeemCodeConfirmation.redeemedProductions = message;
    redeemCodeConfirmation.controllerWasPresentedFromProductionScreen = YES;
    [self.navigationController pushViewController:redeemCodeConfirmation animated:YES];
}

-(void)goToRedeemCodeFormVC {
    RedeemCodeFormViewController *redeemCodeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemForm"];
    if (self.controllerWasPresenteFromInitiaScreen) {
        redeemCodeVC.controllerWasPresentedFromInitialScreen = YES;
    } else if (self.controllerWasPresentedFromProductionScreen) {
        redeemCodeVC.controllerWasPresentedFromProductionScreen = YES;
    }
    redeemCodeVC.redeemCode = self.codeTextfield.text;
    [self.navigationController pushViewController:redeemCodeVC animated:YES];
}

-(void)goToVideoWithEmbedCode:(NSString *)embedCode {
    VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
    videoPlayerVC.embedCode = embedCode;
    [self.navigationController pushViewController:videoPlayerVC animated:YES];
}

-(void)validateCode {
    self.wrongCodeImageView.alpha = 0.0;
    
    if ([self.codeTextfield.text length] > 0) {
        [self validateCodeInServer];
    } else {
        self.wrongCodeImageView.alpha = 1.0;
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor escribe un código" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
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
                                  @"password" : [UserInfo sharedInstance].password,
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
    //NSString *encodedJsonString = [IAmCoder base64EncodeString:jsonString];
    NSString *encodedJsonString = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    return encodedJsonString;
}

#pragma mark - Server Communicator 

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
    [serverCommunicator callServerWithGETMethod:@"AuthenticateUser" andParameter:@""];
}

-(void)validateCodeInServer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"ValidateCode" andParameter:self.codeTextfield.text];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"ValidateCode"]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                if ([self.codeTextfield.text hasPrefix:@"ev"]) {
                    NSLog(@"era un código ev valido con embed code: %@", dictionary[@"info_code"][@"video"]);
                    [self goToVideoWithEmbedCode:dictionary[@"info_code"][@"video"]];
                } else {
                    if (self.controllerWasPresentedFromContentNotAvailable) {
                        [self startRedeemProcess];
                        //[self goToRedeemCodeConfirmation];
                    } else {
                        [self goToRedeemCodeFormVC];
                    }
                    NSLog(@"El código es válido, es de los normalitos");
                }
            } else {
                NSLog(@"%@", dictionary);
                self.wrongCodeImageView.alpha = 1.0;
                [[[UIAlertView alloc] initWithTitle:@"Error" message:dictionary[@"response"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error validando el código. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    
    } else if ([methodName isEqualToString:@"AuthenticateUser"] && dictionary) {
        if ([dictionary[@"status"] boolValue]) {
            NSLog(@"autenticación exitosa: %@", dictionary);
            NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
            self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
            [self redeemCodeInServer:self.codeTextfield.text];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Los datos ingresados no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            NSLog(@"la autenticación no fue exitosa");
        }
    
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"RedeemCode", self.codeTextfield.text]]) {
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
            //[UserInfo sharedInstance].userName = nil;
            //[UserInfo sharedInstance].password = nil;
            NSLog(@"error en la peticion de redimir: %@", dictionary);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error redimiendo el código. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UITextfFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
