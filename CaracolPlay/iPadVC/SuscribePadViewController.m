//
//  SuscribeViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscribePadViewController.h"
#import "CheckmarkView.h"
#import "SuscriptionConfirmationPadViewController.h"
#import "FileSaver.h"
#import "CPIAPHelper.h"
#import "IngresarPadViewController.h"
@import QuartzCore;

@interface SuscribePadViewController ()
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) CheckmarkView *checkBox1;
@property (strong, nonatomic) CheckmarkView *checkBox2;
@end

@implementation SuscribePadViewController

-(void)UISetup {
    
    //1. Set background image
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundFormularioPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];

    //2. Dismiss view controller button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //3. Checkboxes
    self.checkBox1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(35.0, 458.0, 30.0, 30.0)];
    [self.view addSubview:self.checkBox1];
    
    self.checkBox2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(35.0, 498.0, 30.0, 30.0)];
    [self.view addSubview:self.checkBox2];
    
    //4. 'Continuar' button
    [self.continueButton addTarget:self action:@selector(suscribe) forControlEvents:UIControlEventTouchUpInside];
    
    //'Ingresa aquí' button setup
    [self.enterHereButton addTarget:self action:@selector(goToIngresarVC) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    //Register as an observer of the notification 'UserDidSuscribe'
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"Desapareceré");
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"bound: %@", NSStringFromCGRect(self.view.bounds));
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 597.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 597.0 + 20.0);
    
    self.backgroundImageView.frame = self.view.bounds;
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 44.0, 0.0, 44.0, 44.0);
}

#pragma mark - Actions 

-(void)goToIngresarVC {
    //Remove as an observer of the notification -userDidSuscribe
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserDidSuscribe" object:nil];
    
    IngresarPadViewController *ingresarPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IngresarPad"];
    ingresarPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    ingresarPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
    ingresarPadVC.viewWidth = 320.0;
    ingresarPadVC.viewHeight = 597.0;
    ingresarPadVC.controllerWasPresentedFromInitialSuscriptionScreen = YES;
    [self presentViewController:ingresarPadVC animated:YES completion:nil];
}

#pragma mark - Notifications Handler 

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"Me llegó la notificación de compraaaa");
    //Save a key locally, indicating that the user has logged in.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
     
    //The user can pass to the suscription confirmation view controller
    SuscriptionConfirmationPadViewController *suscriptionConfirmationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionConfirmationPad"];
    suscriptionConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    suscriptionConfirmationVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:suscriptionConfirmationVC animated:YES completion:nil];
}

#pragma mark - Custom Methods

-(void)suscribe {
    if ([self areTermsAndConditionsAccepted]) {
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            if (success) {
                IAPProduct *product = [products firstObject];
                [[CPIAPHelper sharedInstance] buyProduct:product];
            }
        }];
    } else {
        //The user can't pass.
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No has completado algunos campos obligatorios. Revisa e inténtalo de nuevo. " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(BOOL)areTermsAndConditionsAccepted {
    if ([self.checkBox1 viewIsChecked] && [self.checkBox2 viewIsChecked]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Actions

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
