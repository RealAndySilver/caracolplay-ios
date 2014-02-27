//
//  RedeemCodeAlertViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 19/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "RedeemCodeAlertViewController.h"
#import "IngresarViewController.h"
#import "SuscriptionFormViewController.h"
#import "FileSaver.h"

@interface RedeemCodeAlertViewController ()

@end

@implementation RedeemCodeAlertViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
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
    backgroundImageView.image = [UIImage imageNamed:@"RedeemCodeAlertBackground.png"];
    [self.view addSubview:backgroundImageView];
    
    // 2. Textview
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(30.0, screenFrame.size.height/2 - 30.0, screenFrame.size.width - 60.0, 150.0)];
    textView.backgroundColor = [UIColor clearColor];
    textView.text = @"Tu código ha sido aceptado. Ahora puedes disfrutar del siguiente contenido: \n\nEvento en Vivo: Colombia vs Grecia\nJunio 14, 9:00 AM";
    textView.userInteractionEnabled = NO;
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont systemFontOfSize:15.0];
    textView.textColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    //2. Set the enter and suscribe button
    UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, self.view.frame.size.height/1.45, screenFrame.size.width - 60.0, 50.0)];
    [enterButton setTitle:@"Ingresar" forState:UIControlStateNormal];
    [enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(goToEnterViewController) forControlEvents:UIControlEventTouchUpInside];
    enterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.view addSubview:enterButton];
    
    UIButton *suscribeButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, enterButton.frame.origin.y + enterButton.frame.size.height + 10.0, screenFrame.size.width - 60.0, 50.0)];
    [suscribeButton setTitle:@"Suscríbete" forState:UIControlStateNormal];
    [suscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [suscribeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    suscribeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [suscribeButton addTarget:self action:@selector(goToSuscribeViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suscribeButton];
    
    //4. Set the 'Skip' button
    UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectMake(screenFrame.size.width - 100.0, 22.0, 100.0, 30.0)];
    [skipButton setTitle:@"Saltar ▶︎" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [skipButton addTarget:self action:@selector(skipAndGoToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
}

#pragma mark - Actions

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

-(void)goToEnterViewController {
    IngresarViewController *ingresarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Ingresar"];
    [self.navigationController pushViewController:ingresarViewController animated:YES];
}

-(void)goToSuscribeViewController {
    SuscriptionFormViewController *suscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Suscription"];
    [self.navigationController pushViewController:suscriptionViewController animated:YES];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
