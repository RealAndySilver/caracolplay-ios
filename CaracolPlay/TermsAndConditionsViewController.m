//
//  TermsAndConditionsViewController.m
//  CaracolPlay
//
//  Created by Developer on 31/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TermsAndConditionsViewController.h"
#import "ServerCommunicator.h"

@interface TermsAndConditionsViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) NSString *termsAndConditionsString;
@end

@implementation TermsAndConditionsViewController

#pragma mark - View Lifecycle & UISetup

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.mainTitle;
    self.view.backgroundColor = [UIColor blackColor];
    
    
    //[self getTerms];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TermsAndPrivacy" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (self.showTerms) {
        self.termsAndConditionsString = dictionary[@"TermsAndConditions"];
    } else if (self.showPrivacy) {
        self.termsAndConditionsString = dictionary[@"PrivacyPolicy"];
    }
    self.termsAndConditionsString = [self.termsAndConditionsString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    //NSLog(@"%@", self.termsAndConditionsString);
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

/*-(void)getTerms {
    [MBHUDView hudWithBody:@"Cargando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetTerms" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    if ([methodName isEqualToString:@"GetTerms"]) {
        if (dictionary) {
            
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en unos momentos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
}*/

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
