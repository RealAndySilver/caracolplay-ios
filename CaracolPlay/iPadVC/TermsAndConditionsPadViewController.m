//
//  TermsAndConditionsPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 20/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TermsAndConditionsPadViewController.h"

@interface TermsAndConditionsPadViewController () <UIBarPositioningDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) NSString *termsAndConditionsString;
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation TermsAndConditionsPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    
    //Access the terms and conditions string saved in our plist
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TermsAndPrivacy" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    self.termsAndConditionsString = dictionary[@"TermsAndConditions"];
    self.termsAndConditionsString = [self.termsAndConditionsString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSLog(@"%@", self.termsAndConditionsString);

    [self UISetup];
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

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
