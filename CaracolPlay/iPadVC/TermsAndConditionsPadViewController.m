//
//  TermsAndConditionsPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 20/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TermsAndConditionsPadViewController.h"

@interface TermsAndConditionsPadViewController () <UIBarPositioningDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UITextView *textView;
@end

@implementation TermsAndConditionsPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.textView.frame = CGRectMake(50.0, 120.0, self.view.bounds.size.width - 100.0, self.view.bounds.size.height - 120.0);
}

-(void)UISetup {
    //Navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarDetail.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    //Textview setup
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:20.0];
    self.textView.textAlignment = NSTextAlignmentJustified;
    self.textView.userInteractionEnabled = NO;
    self.textView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel neque interdum quam auctor ultricies. Donec eget scelerisque leo, sed commodo nibh. Suspendisse potenti. Morbi vitae est ac ipsum mollis vulputate eget commodo elit. Donec magna justo, semper sit amet libero eget, tempus condimentum ipsum. Aenean lobortis eget justo sed mattis. Suspendisse eget libero eget est imperdiet dignissim vel quis erat. Mauris suscipit accumsan porttitor. Maecenas rhoncus nec diam et cursus. Pellentesque lacinia erat ullamcorper, vulputate risus sit amet, mollis ante. Mauris aliquet posuere nunc. Sed in pharetra odio. Suspendisse tempor sed nisl vitae ultrices. Phasellus ac risus lorem. Nullam rutrum molestie dictum. Vestibulum sed lectus at nisi bibendum eleifend. Fusce in lectus id dolor cursus venenatis vel nec leo. Ut a augue nec turpis semper commodo. Ut sit amet mi in sapien dapibus sodales interdum eget magna. Maecenas eget metus non quam sodales posuere. Donec non magna a est gravida gravida. Maecenas eleifend sodales risus, id dictum odio vehicula pulvinar. Nullam pellentesque euismod porta.";
    self.textView.textColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
