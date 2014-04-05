//
//  TermsAndConditionsViewController.m
//  CaracolPlay
//
//  Created by Developer on 31/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TermsAndConditionsViewController.h"
#import "ServerCommunicator.h"
#import "MBHUDView.h"

@interface TermsAndConditionsViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) NSString *termsAndConditionsString;
@end

@implementation TermsAndConditionsViewController

#pragma mark - View Lifecycle & UISetup

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Términos y Condiciones";
    self.view.backgroundColor = [UIColor blackColor];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TermsAndPrivacy" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    self.termsAndConditionsString = dictionary[@"TermsAndConditions"];
    self.termsAndConditionsString = [self.termsAndConditionsString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSLog(@"%@", self.termsAndConditionsString);
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

-(void)setupUI {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenFrame.size.width, screenFrame.size.height - 110.0)];
    [webView loadHTMLString:self.termsAndConditionsString baseURL:nil];
    [self.view addSubview:webView];
}
#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
