//
//  LoadingiPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LoadingiPadViewController.h"
#import "LoginPadViewController.h"
#import "FileSaver.h"
#import "MainTabBarPadController.h"
#import "UserInfo.h"

@interface LoadingiPadViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@end

@implementation LoadingiPadViewController

-(void)UISetup {
    
    //1. background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoadingiPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    
    //2. spinner setup
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:self.spinner];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
    [self performSelector:@selector(goToLoginViewController) withObject:nil afterDelay:1.5];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"Frame After Layout: %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"Bounds After Layout: %@", NSStringFromCGRect(self.view.bounds));
    
    //Set the subviews frame
    self.backgroundImageView.frame = self.view.bounds;
    self.spinner.frame = CGRectMake(self.view.bounds.size.width/2 - 20.0, self.view.bounds.size.height/2 + 50.0, 40.0, 40.0);
    [self.spinner startAnimating];
}

#pragma mark - Custom Methods

-(void)goToLoginViewController {
    //Stop the spinner
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSDictionary *userDic = [fileSaver getDictionary:@"UserHasLoginDic"];
    if ([userDic[@"UserHasLoginKey"] boolValue]) {
        [UserInfo sharedInstance].userName = userDic[@"UserName"];
        [UserInfo sharedInstance].password = userDic[@"Password"];
        [UserInfo sharedInstance].session = userDic[@"Session"];
        [UserInfo sharedInstance].sessionKey = userDic[@"Session_Key"];
        int sessionExpires = [userDic[@"Session_Expires"] intValue];
        [UserInfo sharedInstance].session_expires = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:sessionExpires];
        [UserInfo sharedInstance].userID = userDic[@"UserID"];
        [UserInfo sharedInstance].isSubscription = [userDic[@"IsSuscription"] boolValue];
        [UserInfo sharedInstance].myListIds = [[NSMutableArray alloc] initWithArray:userDic[@"MyLists"]];
        [[UserInfo sharedInstance] setAuthCookieForWebView];
        MainTabBarPadController *mainTabBarPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarPadVC animated:YES completion:nil];
    
    } else {
        //If the user hasn't logged in, go to the login view controller.
        LoginPadViewController *loginPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginPad"];
        loginPadViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:loginPadViewController animated:YES completion:nil];
    }
}


@end
