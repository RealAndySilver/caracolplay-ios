//
//  TermsAndConditionsPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 20/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TermsAndConditionsPadViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"

@interface TermsAndConditionsPadViewController () <UIBarPositioningDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) NSString *termsAndConditionsString;
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation TermsAndConditionsPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //Access the terms and conditions string saved in our plist
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TermsAndPrivacy" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (self.showTerms) {
        [self getTerms];
    } else if (self.showPrivacy) {
        self.termsAndConditionsString = dictionary[@"PrivacyPolicy"];
        self.termsAndConditionsString = [self.termsAndConditionsString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [self UISetup];
    }
  
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.webView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0 - 50);
    if (self.controllerWasPresentedInFormSheet) {
        [self createDismissButton];
    }
}

-(void)UISetup {
    //Navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarDetail.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    self.webView = [[UIWebView alloc] init];
    [self.webView loadHTMLString:self.termsAndConditionsString baseURL:nil];
    [self.view addSubview:self.webView];
}

#pragma mark - Custom Methods

-(void)createDismissButton {
    NSLog(@"entré aca");
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    self.navigationBar.items = @[navigationItem];
    
    UIBarButtonItem *dismissBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissVC)];
    navigationItem.rightBarButtonItem = dismissBarButtonItem;
}


-(void)getTerms {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetTerms" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"GetTerms"]) {
        if (dictionary) {
            self.termsAndConditionsString = dictionary[@"text"];
            [self UISetup];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error accediendo a los términos y condiciones. Por favor intenta nuevamente" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en unos momentos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
