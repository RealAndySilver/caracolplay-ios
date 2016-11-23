//
//  VideoWebViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 13/06/16.
//  Copyright © 2016 iAmStudio. All rights reserved.
//

#import "VideoWebViewController.h"

@interface VideoWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation VideoWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString: self.videoUrlString]]];
    NSLog(@"ViewWebViewController: Opening: %@", self.videoUrlString);
    //[self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://www.caracolplay.com"]]];
}

- (IBAction)dismissVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
