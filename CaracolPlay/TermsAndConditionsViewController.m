//
//  TermsAndConditionsViewController.m
//  CaracolPlay
//
//  Created by Developer on 31/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TermsAndConditionsViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"

@interface TermsAndConditionsViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) NSString *termsAndConditionsString;
@end

@implementation TermsAndConditionsViewController

#pragma mark - View Lifecycle & UISetup

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.mainTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //[self getTerms];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TermsAndPrivacy" ofType:@"plist"];
    NSString *privacyPath = [[NSBundle mainBundle] pathForResource:@"privacy" ofType:@"html"];
    //NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (self.showTerms) {
        [self getTerms];
        //self.termsAndConditionsString = dictionary[@"TermsAndConditions"];
    } else if (self.showPrivacy) {
        //self.termsAndConditionsString = dictionary[@"PrivacyPolicy"];
        self.termsAndConditionsString = [NSString stringWithContentsOfFile:privacyPath encoding:NSUTF8StringEncoding error:nil];
        self.termsAndConditionsString = [self.termsAndConditionsString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [self setupUI];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

-(void)setupUI {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenFrame.size.width, screenFrame.size.height - 110.0)];
    webView.opaque=NO;
    [webView setBackgroundColor:[UIColor clearColor]];
    NSString *formattedHtml=[NSString stringWithFormat:@"<div style=\"background:white;color:black !important;font-family:helvetica;font-size:12;\">%@</div>",self.termsAndConditionsString];
    [webView loadHTMLString:formattedHtml baseURL:nil];
    [self.view addSubview:webView];
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
            [self setupUI];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error accediendo a los términos y condiciones. Por favor intenta nuevamente" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en unos momentos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
