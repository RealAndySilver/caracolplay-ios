//
//  LoadingViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "MyNavigationController.h"
#import "MainTabBarViewController.h"
#import "FileSaver.h"
#import "UserInfo.h"

@interface LoadingViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation LoadingViewController

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = YES;
    [self performSelector:@selector(goToLoginViewController) withObject:nil afterDelay:1.5];
    
    //1. Set the background image of the view
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"Loading.png"];
  
    [self.view addSubview:backgroundImageView];
    
    //2. Create a spinner to show the user that some activity is going on.
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.frame = CGRectMake(self.view.bounds.size.width/2 - 20.0, self.view.bounds.size.height/2 + 30.0, 40.0, 40.0);
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
}

#pragma mark - Custom Methods

-(void)goToLoginViewController {
    //Stop the spinner
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSDictionary *userDic = [fileSaver getDictionary:@"UserHasLoginDic"];
    if ([userDic[@"UserHasLoginKey"] boolValue]) {
        [UserInfo sharedInstance].userName = userDic[@"UserName"];
        [UserInfo sharedInstance].password = userDic[@"Password"];
        [UserInfo sharedInstance].session = userDic[@"Session"];
        [UserInfo sharedInstance].userID = userDic[@"UserID"];
        [UserInfo sharedInstance].isSubscription = [userDic[@"IsSuscription"] boolValue];
        
        //The user is login, so go to the home screen directly
        MainTabBarViewController *mainTabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [self presentViewController:mainTabBarVC animated:YES completion:nil];
        
    } else {
        //The user isn't login, so go to the login screen.
        LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        MyNavigationController *navigationController = [[MyNavigationController alloc] initWithRootViewController:loginVC];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
