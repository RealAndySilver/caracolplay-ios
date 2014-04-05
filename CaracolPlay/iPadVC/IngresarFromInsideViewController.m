//
//  IngresarFromInsideViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IngresarFromInsideViewController.h"
#import "FileSaver.h"

@interface IngresarFromInsideViewController ()
@property (strong, nonatomic) UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@end

@implementation IngresarFromInsideViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 626.0);
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -30.0, 88.0, 88.0);
}

-(void)setupUI {
    //1. dismiss buton setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //Enter button
    [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)enter {
    if ([self.userTextfield.text length] > 0 && [self.passwordTextfield.text length] > 0) {
        //[self dismissVC];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateAditionalTabsNotification" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:nil userInfo:nil];
        [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        
        //Save a key to indicate that the user is logged in
        //Save a key locally indicating that the user has logged in.
        FileSaver *fileSaver = [[FileSaver alloc] init];
        [fileSaver setDictionary:@{@"UserHasLoginKey": @YES} withKey:@"UserHasLoginDic"];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu usuario o contraseña no son válidos. Por favor intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

@end
