//
//  VideoPlayerPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 14/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "VideoPlayerPadViewController.h"
#import "OOOoyalaPlayerViewController.h"
#import "OOOoyalaPlayer.h"
#import "OOOoyalaError.h"

@interface VideoPlayerPadViewController () < UIBarPositioningDelegate>
@property (strong, nonatomic) OOOoyalaPlayerViewController *ooyalaPlayerViewController;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UINavigationItem *navBarItem;
@property (strong, nonatomic) NSString *embedCode;
@property (strong, nonatomic) NSString *pcode;
@property (strong, nonatomic) NSString *playerDomain;
@end

@implementation VideoPlayerPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.embedCode = @"xxbjk1YjpHm4-VkWfWfEKBbyEkh358su";
    self.pcode = @"Z5Mm06XeZlcDlfU_1R9v_L2KwYG6";
    self.playerDomain = @"www.ooyala.com";
    
    //Navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"CategoriesNavBarImage.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    [self.view addSubview:self.navigationBar];
    
    self.navBarItem = [[UINavigationItem alloc] initWithTitle:nil];
    self.navigationBar.items = @[self.navBarItem];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás" style:UIBarButtonItemStylePlain target:self action:@selector(dismissVC)];
    self.navBarItem.leftBarButtonItem = backBarButtonItem;
    
    //Create the Ooyala ViewController
    self.ooyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPcode:self.pcode domain:self.playerDomain controlType:OOOoyalaPlayerControlTypeInline];
    
    //Attach the Oooyala view controller to the view
    //self.ooyalaPlayerViewController.view.frame = self.view.frame;
    self.ooyalaPlayerViewController.view.backgroundColor = [UIColor blackColor];
    [self addChildViewController:self.ooyalaPlayerViewController];
    [self.view addSubview:self.ooyalaPlayerViewController.view];
    
    //Load the video
    [self.ooyalaPlayerViewController.player setEmbedCode:self.embedCode];
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"la vista aprecerá");
    [super viewWillAppear:animated];
    //self.tabBarController.tabBar.alpha = 0.0;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"bounds of video: %@", NSStringFromCGRect(self.view.bounds));
    self.ooyalaPlayerViewController.view.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //self.tabBarController.tabBar.alpha = 1.0;
    [self.ooyalaPlayerViewController.player pause];
}

#pragma mark - Actions

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}
@end
