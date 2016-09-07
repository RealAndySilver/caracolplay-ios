//
//  SuscriptionWelcomePadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 23/08/16.
//  Copyright © 2016 iAmStudio. All rights reserved.
//

#import "SuscriptionWelcomePadViewController.h"
#import "TTTAttributedLabel.h"

@interface SuscriptionWelcomePadViewController () <TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *mainLabel;
@end

@implementation SuscriptionWelcomePadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.mainLabel.delegate = self;
    
    NSRange range = [self.mainLabel.text rangeOfString:@"www.caracolplay.com"];
    [self.mainLabel addLinkToURL:[NSURL URLWithString:@"http://www.caracolplay.com"] withRange:range];
    
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSLog(@"Link: %@", url.description);
    [[UIApplication sharedApplication] openURL:url];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 400.0);
    //self.view.layer.cornerRadius = 10.0;
    //self.view.layer.masksToBounds = YES;
    self.view.frame = CGRectMake(0.0, 0.0, 320.0, 400.0);
}

- (IBAction)dismissVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
