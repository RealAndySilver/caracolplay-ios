//
//  SuscriptionWelcomeViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 4/08/16.
//  Copyright © 2016 iAmStudio. All rights reserved.
//

#import "SuscriptionWelcomeViewController.h"
#import "TTTAttributedLabel.h"

@interface SuscriptionWelcomeViewController () <TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *mainLabel;
@end

@implementation SuscriptionWelcomeViewController

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

@end
