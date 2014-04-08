//
//  RentFromInsideViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 4/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RentFromInsideViewController.h"
#import "CheckmarkView.h"
#import "CPIAPHelper.h"
#import "FileSaver.h"
#import "RentConfirmFromInsideViewController.h"
#import "MBHUDView.h"
#import "IngresarFromInsideViewController.h"

@interface RentFromInsideViewController ()
@property (strong, nonatomic) CheckmarkView *checkBox1;
@property (strong, nonatomic) CheckmarkView *checkBox2;
@property (weak, nonatomic) IBOutlet UIButton *enterHereButton;
@property (strong, nonatomic) UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *rentButton;
@end

@implementation RentFromInsideViewController

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

-(void)setupUI {
    //2. Dismiss view controller button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //3. Checkboxes
    self.checkBox1 = [[CheckmarkView alloc] initWithFrame:CGRectMake(210.0, 462.0, 30.0, 30.0)];
    [self.view addSubview:self.checkBox1];
    
    self.checkBox2 = [[CheckmarkView alloc] initWithFrame:CGRectMake(210.0, 502.0, 30.0, 30.0)];
    [self.view addSubview:self.checkBox2];
    
    //Rent button
    [self.rentButton addTarget:self action:@selector(rentProduction) forControlEvents:UIControlEventTouchUpInside];
    
    //Enter here button
    [self.enterHereButton addTarget:self action:@selector(enterWithExistingUser) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 626.0);
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -30.0, 88.0, 88.0);
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)enterWithExistingUser {
    //Remove as an observer of the userDidSuscribe notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    IngresarFromInsideViewController *ingresarFromInsideVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IngresarFromInside"];
    ingresarFromInsideVC.modalPresentationStyle = UIModalPresentationFormSheet;
    ingresarFromInsideVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    ingresarFromInsideVC.controllerWasPresentedFromRentScreen = YES;
    [self presentViewController:ingresarFromInsideVC animated:YES completion:nil];
}

#pragma mark - Custom Methods

-(void)rentProduction {
    if ([self areTermsAndConditionsAccepted]) {
        [MBHUDView hudWithBody:nil type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
        [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
            [MBHUDView dismissCurrentHUD];
            if (success) {
                IAPProduct *product = [products lastObject];
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

#pragma mark - Notifications Handler

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    NSLog(@"Me llegó la notificación de compraaaa");
    
    //Save a key locally, indicating that the user has logged in.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
    }
    
    //The user can pass to the rent confirmation view controller
    RentConfirmFromInsideViewController *rentConfirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RentConfirmFromInside"];
    rentConfirmVC.modalPresentationStyle = UIModalPresentationFormSheet;
    rentConfirmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rentConfirmVC.controllerWasPresentedFromRentFromInside = YES;
    [self presentViewController:rentConfirmVC animated:YES completion:nil];
}

@end
