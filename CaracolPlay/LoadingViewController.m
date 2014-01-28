//
//  LoadingViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LoadingViewController.h"
#import "LoginViewController.h"

@interface LoadingViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation LoadingViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self performSelector:@selector(goToLoginViewController) withObject:nil afterDelay:3.0];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
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

-(void)goToLoginViewController {
    //Stop the spinner
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
    
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
