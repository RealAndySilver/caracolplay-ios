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

#pragma mark - Setters & Getters 

-(void)setTermsAndConditionsString:(NSString *)termsAndConditionsString {
    _termsAndConditionsString = termsAndConditionsString;
    [self setupUI];
}

#pragma mark - View Lifecycle & UISetup

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Términos y Condiciones";
    self.view.backgroundColor = [UIColor blackColor];
    [self getTermsAndConditionsFromServer];
    [self setupUI];
}

-(void)setupUI {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenFrame.size.width, screenFrame.size.height - 110.0)];
    [webView loadHTMLString:self.termsAndConditionsString baseURL:nil];
    [self.view addSubview:webView];
}

#pragma mark - Server Stuff

-(void)getTermsAndConditionsFromServer {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Cargando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [serverCommunicator callServerWithGETMethod:@"GetTerms" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
    NSLog(@"Recibí info del server");
    if ([methodName isEqualToString:@"GetTerms"] && [responseDictionary[@"status"] boolValue]) {
        NSLog(@"La petición fue exitosa");
        self.termsAndConditionsString = responseDictionary[@"text"];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
    NSLog(@"server error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor ntenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
