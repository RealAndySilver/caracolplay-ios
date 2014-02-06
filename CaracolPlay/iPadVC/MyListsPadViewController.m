//
//  MyListsPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 6/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsPadViewController.h"

@interface MyListsPadViewController () < UIBarPositioningDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@end

@implementation MyListsPadViewController

-(void)UISetup {
    //1. navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 20.0, 1024, 44.0)];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"CategoriesNavBarImage.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
