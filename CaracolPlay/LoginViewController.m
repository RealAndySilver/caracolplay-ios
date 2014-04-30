//
//  LoginViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LoginViewController.h"
#import "SuscriptionFormViewController.h"
#import "FXBlurView.h"
#import "IngresarViewController.h"
#import "MainTabBarViewController.h"
#import "FileSaver.h"
#import "ServerCommunicator.h"
#import "ValidateCodeViewController.h"

@interface LoginViewController () <ServerCommunicatorDelegate>
@end

@implementation LoginViewController

-(void)UISetup {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    //1. Set the background image of the view
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:screenFrame];
    backgroundImageView.image = [UIImage imageNamed:@"Inicio.png"];
    [self.view addSubview:backgroundImageView];
    
    //2. Set the enter and suscribe button
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2 - 120.0, screenFrame.size.height/1.8, 240.0, 45.0)];
    [enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(goToEnterViewController) forControlEvents:UIControlEventTouchUpInside];
    enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:enterButton];
    
    //Suscribe
    UIButton *suscribeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2 - 120.0, screenFrame.size.height/1.52, 240.0, 45.0)];
    [suscribeButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
    [suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [suscribeButton addTarget:self action:@selector(goToSuscribeViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suscribeButton];
    
    //Tigo Button
    UIButton *tigoButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2 - 120, screenFrame.size.height/1.32, 240.0, 35.0)];
    [tigoButton setBackgroundImage:[UIImage imageNamed:@"BotonTigo.png"] forState:UIControlStateNormal];
    [tigoButton addTarget:self action:@selector(goToTigo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tigoButton];
    
    //3. Set the 'redeem code' button
    UIButton *redeemCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2 - 50.0, screenFrame.size.height - 70.0, 100.0, 70.0)];
    [redeemCodeButton setTitle:@"Redimir\nCódigo" forState:UIControlStateNormal];
    [redeemCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [redeemCodeButton addTarget:self action:@selector(goToRedeemCodeViewController) forControlEvents:UIControlEventTouchUpInside];
    [redeemCodeButton setBackgroundImage:[UIImage imageNamed:@"BotonRedimir.png"] forState:UIControlStateNormal];
    redeemCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    redeemCodeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    redeemCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:redeemCodeButton];
    
    //4. Set the 'Skip' button
    UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0, 15.0, 80.0, 44.0)];
    [skipButton setTitle:@"Saltar ▶︎" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [skipButton addTarget:self action:@selector(skipAndGoToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    
    /*//6. Add a blurview to be displayed when a low connection alert has been displayed.
    self.blurView = [[FXBlurView alloc] init];
    self.blurView.blurRadius = 7.0;
    self.blurView.dynamic = NO;
    self.blurView.alpha = 0.0;
    //[self.view addSubview:self.blurView];*/
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Volver" style:UIBarButtonItemStylePlain target:self action:nil];
    [self UISetup];
    //[self authenticateUser];
}

-(void)authenticateUser {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"AuthenticateUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    if ([methodName isEqualToString:@"AuthenticateUser"]) {
        NSLog(@"respuesta de la autenticacion: %@", dictionary);
    }
}

-(void)serverError:(NSError *)error {
    NSLog(@"error en el server");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Button Actions 

-(void)goToTigo {
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.caracolplay.com?partner=tigo"]]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No fue posible abrir la URL en este momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)goToRedeemCodeViewController {
    ValidateCodeViewController *validateCode = [self.storyboard instantiateViewControllerWithIdentifier:@"ValidateCode"];
    validateCode.controllerWasPresenteFromInitiaScreen = YES;
    [self.navigationController pushViewController:validateCode animated:YES];
}

-(void)goToEnterViewController {
    IngresarViewController *ingresarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Ingresar"];
    ingresarViewController.controllerWasPresentedFromInitialScreen = YES;
    [self.navigationController pushViewController:ingresarViewController animated:YES];
}

-(void)goToSuscribeViewController {
    SuscriptionFormViewController *suscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Suscription"];
    suscriptionViewController.controllerWasPresentFromInitialScreen = YES;
    [self.navigationController pushViewController:suscriptionViewController animated:YES];
}

-(void)skipAndGoToHomeScreen {
    //Save a file that indicates that the user skip the login process.
    //we need to know this to present the suscription alert view controller
    //when the user tries to watch a production.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserHasLoginKey": @NO} withKey:@"UserHasLoginDic"];
    
    if ([fileSaver getDictionary:@"UserHasLoginDic"]) {
        NSLog(@"si se guardó el diccionario");
    }
    
    MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    mainTabBarVC.userDidSkipRegisterProcess = YES;
    [self presentViewController:mainTabBarVC animated:YES completion:nil];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
