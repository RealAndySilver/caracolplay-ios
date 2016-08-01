//
//  SuscriptionAlertViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 19/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionAlertViewController.h"
#import "RedeemCodeViewController.h"
#import "IngresarViewController.h"
#import "SuscriptionFormViewController.h"
#import "RentContentViewController.h"
#import "RentContentFormViewController.h"
#import "RedeemCodeFormViewController.h"
#import "ValidateCodeViewController.h"

@interface SuscriptionAlertViewController ()

@end

@implementation SuscriptionAlertViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.tabBarController) {
        NSLog(@"EXISTE EL TAB EN LA PANTALLA DE ALERTA DE SUSCRIPCIÓN");
    } else {
        NSLog(@"NO EXISTE EL TAB EN LA PANTALLA DE ALERTA DE SUSCRIPCION");
    }
    
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
    backgroundImageView.image = [UIImage imageNamed:@"NewBackgroundNoLogo"];
    backgroundImageView.clipsToBounds = YES;
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundImageView];
    
    UIImageView *whiteTextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, 60.0, self.view.bounds.size.width - 60.0, 50.0)];
    whiteTextImageView.image = [UIImage imageNamed:@"CaracolPlayWhiteText"];
    whiteTextImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:whiteTextImageView];
    
    UIImageView *warningImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50.0, whiteTextImageView.frame.origin.y + whiteTextImageView.frame.size.height + 20.0, self.view.bounds.size.width - 100.0, 80.0)];
    warningImageView.contentMode = UIViewContentModeScaleAspectFit;
    warningImageView.image = [UIImage imageNamed:@"WarningButton"];
    [self.view addSubview:warningImageView];
    
    // 2. textview setup
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, screenFrame.size.height/2 - 40.0, screenFrame.size.width - 40.0, 100.0)];
    detailTextView.text = @"En este momento te encuentras fuera del sistema. Escoge una de las siguientes opciones para reproducir el video.";
    detailTextView.textColor = [UIColor whiteColor];
    detailTextView.font = [UIFont systemFontOfSize:15.0];
    detailTextView.userInteractionEnabled = NO;
    detailTextView.textAlignment = NSTextAlignmentCenter;
    detailTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:detailTextView];
    
    //'Ingresar' button setup
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width/2 - 80.0, screenFrame.size.height/1.65, 160.0, 40.0)];
    [enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(goToEnterViewController) forControlEvents:UIControlEventTouchUpInside];
    enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    enterButton.layer.borderWidth = 1.0;
    enterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //[enterButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.view addSubview:enterButton];
    
    //'Alquilar' button setup
    if (self.viewType == 1 || self.viewType == 3) {
        CGRect rentButtonFrame;
        if (self.viewType != 3) {
            rentButtonFrame = CGRectMake(screenFrame.size.width/2 - 80.0, screenFrame.size.height/1.44, 160.0, 40.0);
        } else {
            rentButtonFrame = CGRectMake(20.0, screenFrame.size.height/1.44, screenFrame.size.width/2.0 - 25.0, 40.0);
        }
        UIButton *rentButton = [[UIButton alloc] initWithFrame:rentButtonFrame];
        [rentButton setTitle:@"Alquilar" forState:UIControlStateNormal];
        [rentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rentButton addTarget:self action:@selector(goToRentViewController) forControlEvents:UIControlEventTouchUpInside];
        rentButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        rentButton.layer.borderWidth = 1.0;
        rentButton.layer.borderColor = [UIColor whiteColor].CGColor;
        //[rentButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
        [self.view addSubview:rentButton];
    }
    
    if (self.viewType == 2 || self.viewType == 3) {
        // 'Suscribete' button setup
        CGRect suscribeButtonFrame;
        if (self.viewType != 3) {
            suscribeButtonFrame = CGRectMake(screenFrame.size.width/2 - 80.0, screenFrame.size.height/1.44, 160.0, 40.0);
        } else {
            suscribeButtonFrame = CGRectMake(screenFrame.size.width/2 + 5.0, screenFrame.size.height/1.44, screenFrame.size.width/2.0 - 25.0, 40.0);
        }
        UIButton *suscribeButton = [[UIButton alloc] initWithFrame:suscribeButtonFrame];
        [suscribeButton setTitle:@"Suscribirse" forState:UIControlStateNormal];
        [suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [suscribeButton addTarget:self action:@selector(goToSuscribeViewController) forControlEvents:UIControlEventTouchUpInside];
        suscribeButton.layer.borderWidth = 1.0;
        suscribeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        //[suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
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
    [redeemCodeButton addTarget:self action:@selector(goToRedeemCodeFormViewController) forControlEvents:UIControlEventTouchUpInside];
    redeemCodeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    redeemCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[self.view addSubview:redeemCodeButton];
}

#pragma mark - Actions

-(void)goToRedeemCodeFormViewController {
    ValidateCodeViewController *validateCode = [self.storyboard instantiateViewControllerWithIdentifier:@"ValidateCode"];
    validateCode.controllerWasPresentedFromProductionScreen = YES;
    [self.navigationController pushViewController:validateCode animated:YES];
}

-(void)goToEnterViewController {
    IngresarViewController *ingresarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Ingresar"];
    ingresarViewController.controllerWasPresentedFromProductionScreen = YES;
    [self.navigationController pushViewController:ingresarViewController animated:YES];
}

-(void)goToRentViewController {
    RentContentFormViewController *rentContentFormVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentContentForm"];
    rentContentFormVC.productID = self.productID;
    rentContentFormVC.rentedProductName = self.productName;
    rentContentFormVC.productType = self.productType;
    [self.navigationController pushViewController:rentContentFormVC animated:YES];
}

-(void)goToSuscribeViewController {
    SuscriptionFormViewController *suscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Suscription"];
    suscriptionViewController.controllerWasPresentedFromProductionScreen = YES;
    [self.navigationController pushViewController:suscriptionViewController animated:YES];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
