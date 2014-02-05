//
//  MovieDetailsViewController.m
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MovieDetailsPadViewController.h"

@interface MovieDetailsPadViewController ()
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *opaqueView;
@property (strong, nonatomic) UIImageView *smallProductionImageView;
@end

@implementation MovieDetailsPadViewController

-(void)UISetup {
    //1. Dismiss button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //2. Background image view
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MentirasPerfectas2.jpg"]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //3. add a UIView to opaque the background view
    self.opaqueView = [[UIView alloc] init];
    self.opaqueView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.backgroundImageView addSubview:self.opaqueView];
    
    //3. small production image view
    self.smallProductionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MentirasPerfectas.jpg"]];
    self.smallProductionImageView.clipsToBounds = YES;
    self.smallProductionImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.smallProductionImageView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 700.0, 500.0);
    
    //Set subviews frame
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 25.0, 0.0, 25.0, 25.0);
    self.backgroundImageView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height/2 + 100.0);
    self.opaqueView.frame = self.backgroundImageView.frame;
    self.smallProductionImageView.frame = CGRectMake(20.0, 20.0, 100.0, 150.0);
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
