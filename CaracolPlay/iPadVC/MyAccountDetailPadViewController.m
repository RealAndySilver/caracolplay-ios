//
//  MyAccountDetailViewController.m
//  CaracolPlay
//
//  Created by Developer on 20/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyAccountDetailPadViewController.h"

@interface MyAccountDetailPadViewController () <UIBarPositioningDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@end

@implementation MyAccountDetailPadViewController

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    //Set subviews frame
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
}

-(void)UISetup {
    // Navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarDetail.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
