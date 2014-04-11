//
//  ContentNotAvailableForUserViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ContentNotAvailableForUserViewController.h"
#import "CPIAPHelper.h"
#import "MBHUDView.h"
#import "RentContentConfirmationViewController.h"
#import "SuscriptionConfirmationViewController.h"
#import "ServerCommunicator.h"

@interface ContentNotAvailableForUserViewController ()

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
                                                 name:@"TransacationFailedNotification"
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
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
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
    UIButton *rentButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2.0 - 100.0, screenFrame.size.height/1.7, 200.0, 44.0)];
    [rentButton setTitle:@"Alquilar" forState:UIControlStateNormal];
    [rentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rentButton addTarget:self action:@selector(rentProduct) forControlEvents:UIControlEventTouchUpInside];
    rentButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rentButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.view addSubview:rentButton];
    
    // 'Suscribete' button setup
    UIButton *suscribeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2.0 - 100.0, screenFrame.size.height/1.44, 200.0, 44.0)];
    [suscribeButton setTitle:@"Suscríbete" forState:UIControlStateNormal];
    [suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [suscribeButton addTarget:self action:@selector(suscribe) forControlEvents:UIControlEventTouchUpInside];
    [suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:suscribeButton];
    
    // 'Redimir código' button setup
    CGFloat buttonHeight = screenFrame.size.height/8.11;
    UIButton *redeemCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2 - 50.0, self.view.frame.size.height - 44.0 - buttonHeight, 100.0, buttonHeight)];
    [redeemCodeButton setTitle:@"Redimir\nCódigo" forState:UIControlStateNormal];
    [redeemCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [redeemCodeButton setBackgroundImage:[UIImage imageNamed:@"BotonRedimir.png"] forState:UIControlStateNormal];
    redeemCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    //[redeemCodeButton addTarget:self action:@selector(goToRedeemCodeViewController) forControlEvents:UIControlEventTouchUpInside];
    redeemCodeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    redeemCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:redeemCodeButton];
}

#pragma mark - Actions 

-(void)rentProduct {
    [MBHUDView hudWithBody:@"Conectando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        [MBHUDView dismissCurrentHUD];
        if (success) {
            if (products) {
                IAPProduct *product = [products lastObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }
    }];
}

-(void)suscribe {
    [MBHUDView hudWithBody:@"Conectando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        [MBHUDView dismissCurrentHUD];
        if (success) {
            if (products) {
                IAPProduct *product = [products firstObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }
    }];
}

#pragma mark - Notification Handler 

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    NSLog(@"Falló la notificación");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:notificationInfo[@"Message"]
                               delegate:self cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"recibí la notificación");
    NSDictionary *productInfo = [notification userInfo];
    NSString *typeOfProduct = productInfo[@"TypeOfProduct"];
    if ([typeOfProduct isEqualToString:@"suscripcion"]) {
        //Go to suscription confirmation view controller
        SuscriptionConfirmationViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmation"];
        
        //The user was already logged in, so the suscription confirmation VC doesn't
        //need to create the aditional tabs
        suscriptionConfirmationVC.userWasAlreadyLoggedin = YES;
        
        suscriptionConfirmationVC.controllerWasPresentedFromProductionScreen = YES;
        [self.navigationController pushViewController:suscriptionConfirmationVC animated:YES];
        
    } else if ([typeOfProduct isEqualToString:@"alquiler"]) {
        //Go to rent confirmation VC
        RentContentConfirmationViewController *rentContentConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentConfirmation"];
        
        //The user was already logged in, so the rentContentConfirmationVC doesn't
        //need to create the aditional tabs
        rentContentConfirmationVC.userWasAlreadyLoggedin = YES;
        [self.navigationController pushViewController:rentContentConfirmationVC animated:YES];
    }
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
