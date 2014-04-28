//
//  RedeemCodePadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodePadViewController.h"
#import "RedeemCodeConfirmationPadViewController.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "NSDictionary+NullReplacement.h"
#import "IAmCoder.h"
#import "FileSaver.h"
#import "MBProgressHUD.h"

@interface RedeemCodePadViewController () <UITextFieldDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *wrongUserImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongPassImageView;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@property (strong, nonatomic) UIButton *dismissButton;
@end

@implementation RedeemCodePadViewController

-(void)UISetup {
    [self clearAllWrongImageViews];
    
    self.userTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    
    //1. Background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundFormularioPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //2. Dismiss button setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //3. 'Continuar' button
    [self.continueButton addTarget:self action:@selector(startRedeemProcess) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 617.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 617.0 + 20.0);
    
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 44.0, 0.0, 44.0, 44.0);
}

#pragma mark - Actions

-(void)startRedeemProcess {
    [self clearAllWrongImageViews];
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
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor llena todos los campos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Methods

-(void)clearAllWrongImageViews {
    self.wrongPassImageView.alpha = 0.0;
    self.wrongUserImageView.alpha = 0.0;
}

-(void)goToRedeemCodeConfirmationWithMessage:(NSString *)message {
    RedeemCodeConfirmationPadViewController *redeemCodeConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RedeemCodeConfirmationPad"];
    redeemCodeConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    redeemCodeConfirmationVC.message = message;
    if (self.controllerWasPresentedFromSuscriptionAlertScreen) {
        redeemCodeConfirmationVC.controllerWasPresentedFromInsideRedeemWithExistingUser = YES;
    }
    [self presentViewController:redeemCodeConfirmationVC animated:YES completion:nil];
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
                                  @"fecha_de_nacimiento" : self.userInfoDic[@"fecha_de_nacimiento"]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Json String: %@", jsonString);
    NSString *encodedJsonString = [IAmCoder base64EncodeString:jsonString];
    return encodedJsonString;
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

-(void)redeemCodeInServer:(NSString *)code {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Redimiendo...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", [self generateEncodedUserInfoString]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@", @"RedeemCode", code] andParameter:parameter httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    ///////////////////////////////////////////////////////////////////////////////
    //AuthenticateUser
    if ([methodName isEqualToString:@"AuthenticateUser"]) {
        if ([dictionary[@"status"] boolValue]) {
            NSLog(@"autenticación exitosa: %@", dictionary);
            NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
            self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
            [self redeemCodeInServer:self.redeemedCode];
        } else {
            self.wrongPassImageView.alpha = 1.0;
            self.wrongUserImageView.alpha = 1.0;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Los datos ingresados no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            NSLog(@"la autenticación no fue exitosa");
        }
    
    ///////////////////////////////////////////////////////////////////////////////
    //RedeemCode
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

                    NSString *redeemedProductionsString = [self generateRedeemedProductionsStringUsingArrayWithName:dictionary[@"code"][@"items"]];
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
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"El código es invalido." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            }
        }

    } else {
        [UserInfo sharedInstance].userName = nil;
        [UserInfo sharedInstance].password = nil;
        NSLog(@"error en la peticion de redimir: %@", dictionary);
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UITextfieldDelegate 

/*-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"empezé a editarme");
    self.continueButton.userInteractionEnabled = NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.continueButton.userInteractionEnabled = YES;
    NSLog(@"terminé de editarme");
}*/

@end
