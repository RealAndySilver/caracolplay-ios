//
//  IngresarViewController.m
//  CaracolPlay
//
//  Created by Developer on 30/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarViewController.h"
#import "MainTabBarViewController.h"
#import "FXBlurView.h"
#import "FileSaver.h"
#import "RentContentConfirmationViewController.h"
#import "SuscriptionConfirmationViewController.h"
#import "CPIAPHelper.h"
#import "ServerCommunicator.h"
#import "UserInfo.h"
#import "IAPProduct.h"
#import "NSDictionary+NullReplacement.h"
#import "IAmCoder.h"
#import "MBProgressHUD.h"
#import "UserDefaultsSaver.h"


@interface IngresarViewController () <UITextFieldDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *wrongPassImageView;
@property (weak, nonatomic) IBOutlet UIImageView *wrongUserImageView;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) NSString *transactionID;
@property (strong, nonatomic) NSDictionary *userInfoDic;
@property (assign, nonatomic) BOOL purchaseSuccededInItunes;
@end

@implementation IngresarViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.purchaseSuccededInItunes = NO;
    if (self.tabBarController) {
        NSLog(@"EXISTE EL TAB EN LA PANTALLA DE INGRESO");
    } else {
        NSLog(@"NO EXISTE EL TAB EN LA PANTALLA DE INGRESO");
    }
    
    [self clearAllWrongImageViews];
    
    self.nameTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    
    if (self.controllerWasPresentedFromInitialScreen) {
        [self.enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
        
    } else if (self.controllerWasPresentedFromInitialSuscriptionScreen) {
        [self.enterButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    
    } else if (self.controllerWasPresentedFromProductionScreen) {
        [self.enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    
    } else if (self.controllerWasPresentedFromProductionSuscriptionScreen) {
        [self.enterButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
        [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    
    //Create a tap gesture to dismiss the keyboard when the user taps
    //outside of it.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tapGesture];
    
    /*self.blurView = [[FXBlurView alloc] init];
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    //Register as an observer of the notification -UserDidSuscribe.
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

#pragma mark - UITextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Custom Methods

-(void)clearAllWrongImageViews {
    self.wrongPassImageView.alpha = 0.0;
    self.wrongUserImageView.alpha = 0.0;
}

-(void)tap {
    //Used to dismiss the keyboard when the user taps outside of it.
    [self.nameTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

-(void)enter {
    [self clearAllWrongImageViews];
    
    BOOL userIsCorrect = NO;
    BOOL passIsCorrect = NO;
    
    if ([self.nameTextfield.text length] > 0) {
        userIsCorrect = YES;
    } else {
        self.wrongUserImageView.alpha = 1.0;
    }
    
    if ([self.passwordTextfield.text length] > 0 ){
        passIsCorrect = YES;
    } else {
        self.wrongPassImageView.alpha = 1.0;
    }
    
    if (userIsCorrect && passIsCorrect) {
        [self authenticateUserWithUserName:self.nameTextfield.text andPassword:self.passwordTextfield.text];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Por favor completa todos los campos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)goToHomeScreen {
    MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    [self presentViewController:mainTabBarVC animated:YES completion:nil];
}

-(void)returnToProduction {
    [self createAditionalTabsInTabBarController];
    NSArray *viewControllers = [self.navigationController viewControllers];
    for (int i = [viewControllers count] - 1; i >= 0; i--){
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[TelenovelSeriesDetailViewController class]] ||
            [obj isKindOfClass:[MoviesEventsDetailsViewController class]]) {
            [self.navigationController popToViewController:obj animated:YES];
            //Post a notification to tell the production view controller that it needs to display the video inmediatly
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoShouldBeDisplayed" object:nil userInfo:nil];
            break;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLastSeenCategory" object:nil userInfo:nil];
}

-(void)buySubscriptionWithIdentifier:(NSString *)productIdentifier {
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

-(void)createAditionalTabsInTabBarController {
    NSLog(@"Entré a crear los tabs");
    //This method create the two aditional tab bars in the tab bar. this is neccesary because
    //when the user is logout, we activate just three tabs, but when the user is log in, we activate
    //the five tabs.
    
    //4. Fourth view of the TabBar - MyLists
    MyListsViewController *myListsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyLists"];
    MyNavigationController *myListsNavigationController = [[MyNavigationController alloc] initWithRootViewController:myListsViewController];
    myListsNavigationController.tabBarItem.title = @"Mis Listas";
    myListsNavigationController.tabBarItem.image = [UIImage imageNamed:@"MyListsTabBarIcon.png"];
    myListsNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"MyListsTabBarIconSelected.png"];
    
    //5. Fifth view of the TabBar - My Account
    ConfigurationViewController *myAccountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Configuration"];
    MyNavigationController*myAccountNavigationController = [[MyNavigationController alloc] initWithRootViewController:myAccountViewController];
    myAccountNavigationController.tabBarItem.title = @"Más";
    myAccountNavigationController.tabBarItem.image = [UIImage imageNamed:@"MoreTabBarIcon.png"];
    myAccountNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"MoreTabBarIconSelected.png"];
    
    if (self.tabBarController) {
        NSLog(@"Si existe el tab bar *************");
    } else {
        NSLog(@"No existe el tab bar *************");
    }
    
    NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
    NSLog(@"NUMERO DE CONTROLADORES: %lu", (unsigned long)[viewControllersArray count]);
    [viewControllersArray addObject:myListsNavigationController];
    [viewControllersArray addObject:myAccountNavigationController];
    [self.tabBarController setViewControllers:viewControllersArray animated:NO];
    NSLog(@"NUMEROD E CONTROLADORES ACTUALIZADOS: %lu", (unsigned long)[self.tabBarController.viewControllers count]);
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
    //NSString *encodedJsonString = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    return encodedJsonString;
}

-(void)goToSubscriptionConfirm {
    SuscriptionConfirmationViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmation"];
    
    if (self.controllerWasPresentedFromInitialSuscriptionScreen) {
        suscriptionConfirmationVC.controllerWasPresentedFromInitialScreen = YES;
        suscriptionConfirmationVC.userWasAlreadyLoggedin = NO;
        
    } else if (self.controllerWasPresentedFromProductionScreen) {
        suscriptionConfirmationVC.controllerWasPresentedFromProductionScreen = YES;
    }
    [self.navigationController pushViewController:suscriptionConfirmationVC animated:YES];
}

#pragma mark - Server Stuff

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

-(void)authenticateUserWithUserName:(NSString *)userName andPassword:(NSString *)password {
    [UserInfo sharedInstance].userName = userName;
    [UserInfo sharedInstance].password = password;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando...";
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"AuthenticateUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([methodName isEqualToString:@"AuthenticateUser"] && dictionary) {
        if ([dictionary[@"status"] boolValue]) {
            NSLog(@"autenticación exitosa: %@", dictionary);
            
            NSArray *myListsArray = dictionary[@"user"][@"my_list"];
            NSMutableArray *myListIds = [[NSMutableArray alloc] init];
            for (NSDictionary *myListDict in myListsArray) {
                [myListIds addObject:myListDict[@"id"]];
            }
            [UserInfo sharedInstance].myListIds = myListIds;
            NSLog(@"IngresarViewController: UserInfo MyListsIDs: %@", myListIds);
            //Save a key localy that indicates that the user is logged in
            FileSaver *fileSaver = [[FileSaver alloc] init];
            [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                       @"UserName" : [UserInfo sharedInstance].userName,
                                       @"Password" : [UserInfo sharedInstance].password,
                                       @"MyLists": [UserInfo sharedInstance].myListIds,
                                       @"Session" : dictionary[@"session"],
                                       @"UserID" : dictionary[@"uid"],
                                       @"IsSuscription" : @([dictionary[@"user"][@"is_suscription"] boolValue])
                                       } withKey:@"UserHasLoginDic"];
            
            [UserInfo sharedInstance].userID = dictionary[@"uid"];
            [UserInfo sharedInstance].session = dictionary[@"session"];
            //[UserInfo sharedInstance].isSubscription = [dictionary[@"user"][@"is_suscription"] boolValue];
            [UserInfo sharedInstance].isSubscription = @YES;
            NSLog(@"is_suscription: %hhd", [UserInfo sharedInstance].isSubscription);
            
            NSDictionary *userInfoDicWithNulls = dictionary[@"user"][@"data"];
            self.userInfoDic = [userInfoDicWithNulls dictionaryByReplacingNullWithBlanks];
            
            if (self.controllerWasPresentedFromInitialScreen) {
                //Go to home screen directly
                [self goToHomeScreen];
                
                
            } else if (self.controllerWasPresentedFromProductionScreen) {
                //Return to production
                [self returnToProduction];
            
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
              
                
            } else if (self.controllerWasPresentedFromProductionSuscriptionScreen) {
                if (![dictionary[@"user"][@"is_suscription"] boolValue]) {
                    //Request products from Apple because the user is not suscribe
                    if ([dictionary[@"region"] intValue] == 0) {
                        [self buySubscriptionWithIdentifier:@"net.icck.CaracolPlay.Colombia.subscription"];
                    } else if ([dictionary[@"region"] intValue] == 1) {
                        [self buySubscriptionWithIdentifier:@"net.icck.CaracolPlay.RM.subscription"];
                    }
                } else {
                    //the user is suscribe, don't allow him to buy, pass directly to home screen
                    [self returnToProduction];
                    //[[[UIAlertView alloc] initWithTitle:nil message:@"Tu usuario ya posee una suscripción." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
            }
            
        } else {
            NSLog(@"la autenticación no fue exitosa: %@", dictionary);
            self.wrongPassImageView.alpha = 1.0;
            self.wrongUserImageView.alpha = 1.0;
            [UserInfo sharedInstance].userName = nil;
            [UserInfo sharedInstance].password = nil;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", self.transactionID]]) {
        if (dictionary) {
            NSLog(@"Peticion SuscribeUser exitosa: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                self.purchaseSuccededInItunes = NO;
                [UserDefaultsSaver deletePurchaseDics];
                
                //Save a key localy that indicates that the user is logged in
                FileSaver *fileSaver = [[FileSaver alloc] init];
                [fileSaver setDictionary:@{@"UserHasLoginKey": @YES,
                                           @"UserName" : [UserInfo sharedInstance].userName,
                                           @"Password" : [UserInfo sharedInstance].password,
                                           @"Session" : dictionary[@"session"],
                                           @"UserID" : dictionary[@"uid"],
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
            }
            
        } else {
            [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"subscription" transactionId:self.transactionID productId:@""];
            NSLog(@"error en la respuesta del SubscribeUser: %@", dictionary);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
        }
        
    } else {
        NSLog(@"error en la respuesta: %@", dictionary);
        [UserInfo sharedInstance].userName = nil;
        [UserInfo sharedInstance].password = nil;
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.purchaseSuccededInItunes) {
        [UserDefaultsSaver savePurchaseInfoWithUserInfo:[self generateEncodedUserInfoString] purchaseType:@"subscription" transactionId:self.transactionID productId:@""];
        //There was a network error after the user make the purchase in itunes...call caracol server againa to complete the subscription
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
    } else {
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
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
    NSLog(@"recibí la notificación de compra");
    self.purchaseSuccededInItunes = YES;
    //FileSaver *fileSaver = [[FileSaver alloc] init];
    //[fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *transactionID = userInfo[@"TransactionID"];
    self.transactionID = transactionID;
    
    //Save
    
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción, con el transacion id: %@", transactionID);
    [self suscribeUserInServerWithTransactionID:transactionID];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self suscribeUserInServerWithTransactionID:self.transactionID];
    }
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
