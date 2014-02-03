//
//  LoadingiPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LoadingiPadViewController.h"
#import "LoginPadViewController.h"

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
    [self.spinner startAnimating];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
    [self performSelector:@selector(goToLoginViewController) withObject:nil afterDelay:3.0];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"Frame After Layout: %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"Bounds After Layout: %@", NSStringFromCGRect(self.view.bounds));
    
    //Set the subviews frame
    self.backgroundImageView.frame = self.view.bounds;
    self.spinner.frame = CGRectMake(self.view.bounds.size.width/2 - 20.0, self.view.bounds.size.height/2 + 50.0, 40.0, 40.0);
}

#pragma mark - Custom Methods

-(void)goToLoginViewController {
    //Stop the spinner
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
    
    LoginPadViewController *loginPadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginPad"];
    loginPadViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:loginPadViewController animated:YES completion:nil];
}


@end
