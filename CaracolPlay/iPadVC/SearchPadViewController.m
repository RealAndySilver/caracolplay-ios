//
//  SearchPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SearchPadViewController.h"

@interface SearchPadViewController () < UIBarPositioningDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation SearchPadViewController

-(void)UISetup {
    //1. Navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 20.0, 1024.0, 44.0)];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"CategoriesNavBarImage.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    [self.view addSubview:self.navigationBar];
    
    //2. SearchBar setup
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10.0, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height + 10.0, 1024 - 10.0, 30.0)];
    self.searchBar.backgroundImage = [UIImage imageNamed:@"SearchBarPad.png"];
    [self.view addSubview:self.searchBar];
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
