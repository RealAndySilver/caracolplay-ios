//
//  IngresarFromInsideViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarFromInsideViewController.h"
#import "FileSaver.h"
#import "MBHUDView.h"
#import "CPIAPHelper.h"
#import "RentConfirmFromInsideViewController.h"
#import "SuscribeConfirmFromInsideViewController.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "NSDictionary+NullReplacement.h"

@interface IngresarFromInsideViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@end

@implementation IngresarFromInsideViewController

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

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 597.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 597.0 + 20.0);
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -30.0, 88.0, 88.0);
}

-(void)setupUI {
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundFormularioPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //1. dismiss buton setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //Enter button
    if (self.controllerWasPresentedFromRentScreen) {
        [self.enterButton addTarget:self action:@selector(rentProduction) forControlEvents:UIControlEventTouchUpInside];
        [self.enterButton setTitle:@"Alquilar" forState:UIControlStateNormal];
        
    } else if (self.controllerWasPresentFromAlertScreen) {
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
        [self.enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    
    } else if (self.controllerWasPresentedFromSuscriptionScreen) {
        [self.enterButton addTarget:self action:@selector(suscribe) forControlEvents:UIControlEventTouchUpInside];
        [self.enterButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
    }
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)suscribe {
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
}

-(void)rentProduction {
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
}

-(void)enter {
    if (([self.userTextfield.text length] > 0) && [self.passwordTextfield.text length] > 0) {
        [self authenticateUserWithUserName:self.userTextfield.text andPassword:self.passwordTextfield.text];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)returnToProduction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
    [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

/*-(void)enter {
    if ([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0) {
        //[self dismissVC];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        
        //Save a key to indicate that the user is logged in
        //Save a key locally indicating that the user has logged in.
        FileSaver *fileSaver = [[FileSaver alloc] init];
        [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}*/

#pragma mark - Server Stuff

-(void)authenticateUserWithUserName:(NSString *)userName andPassword:(NSString *)password {
    [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [UserInfo sharedInstance].userName = userName;
    [UserInfo sharedInstance].password = password;
    
    [serverCommunicator callServerWithGETMethod:@"AuthenticateUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
    
    //////////////////////////////////////////////////////////////////
    //Authenticate User
    if ([methodName isEqualToString:@"AuthenticateUser"]) {
        if ([dictionary[@"status"] boolValue]) {
            NSLog(@"autenticación exitosa: %@", dictionary);
            
            //Save a key localy that indicates that the user is logged in
            FileSaver *fileSaver = [[FileSaver alloc] init];
            [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                       @"UserName" : [UserInfo sharedInstance].userName,
                                       @"Password" : [UserInfo sharedInstance].password,
                                       @"Session" : dictionary[@"session"]
                                       } withKey:@"UserHasLoginDic"];
            [UserInfo sharedInstance].session = dictionary[@"session"];
            NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
            self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
            if (self.controllerWasPresentFromAlertScreen) {
                [self returnToProduction];
            }
            
        } else {
            NSLog(@"la autenticación no fue exitosa: %@", dictionary);
            [UserInfo sharedInstance].userName = nil;
            [UserInfo sharedInstance].password = nil;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }

    ///////////////////////////////////////////////////////////////////
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handlers

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
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
}

@end
