//
//  SuscriptionAlertPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SuscriptionAlertPadViewController.h"

@interface SuscriptionAlertPadViewController ()

@end

@implementation SuscriptionAlertPadViewController

-(void)viewDidLoad {
    self.view.backgroundColor = [UIColor redColor];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 320.0, 597.0);
    self.view.layer.cornerRadius = 10.0;
    self.view.frame = CGRectMake(-10.0, -10.0, 320.0 + 20.0, 597.0 + 20.0);
}

@end
