//
//  MyAccountViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyAccountViewController.h"

@interface MyAccountViewController ()

@end

@implementation MyAccountViewController

-(void)UISetup {
    //create a button to close the user's session
    UIButton *logOutButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 80.0, self.view.frame.size.height - 100.0, 160.0, 30.0)];
    [logOutButton setTitle:@"Cerrar Sesión" forState:UIControlStateNormal];
    [logOutButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    logOutButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [self.view addSubview:logOutButton];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Mi Cuenta";
    [self UISetup];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
