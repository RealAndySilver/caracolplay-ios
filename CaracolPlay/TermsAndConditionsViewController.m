//
//  TermsAndConditionsViewController.m
//  CaracolPlay
//
//  Created by Developer on 31/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "TermsAndConditionsViewController.h"

@interface TermsAndConditionsViewController ()
@property (strong, nonatomic) UITextView *textView;
@end

@implementation TermsAndConditionsViewController

-(void)viewDidLoad {
    self.view.backgroundColor = [UIColor blackColor];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 20.0, self.view.frame.size.width - 20.0, self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0) - 44.0)];
    self.textView.backgroundColor = [UIColor blackColor];
    self.textView.font = [UIFont systemFontOfSize:15.0];
    self.textView.textColor = [UIColor whiteColor];
    self.textView.textAlignment = NSTextAlignmentJustified;
    self.textView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel neque interdum quam auctor ultricies. Donec eget scelerisque leo, sed commodo nibh. Suspendisse potenti. Morbi vitae est ac ipsum mollis vulputate eget commodo elit. Donec magna justo, semper sit amet libero eget, tempus condimentum ipsum. Aenean lobortis eget justo sed mattis. Suspendisse eget libero eget est imperdiet dignissim vel quis erat. Mauris suscipit accumsan porttitor. Maecenas rhoncus nec diam et cursus. Pellentesque lacinia erat ullamcorper, vulputate risus sit amet, mollis ante. Mauris aliquet posuere nunc. Sed in pharetra odio. Suspendisse tempor sed nisl vitae ultrices. Phasellus ac risus lorem. Nullam rutrum molestie dictum. Vestibulum sed lectus at nisi bibendum eleifend. Fusce in lectus id dolor cursus venenatis vel nec leo. Ut a augue nec turpis semper commodo. Ut sit amet mi in sapien dapibus sodales interdum eget magna. Maecenas eget metus non quam sodales posuere. Donec non magna a est gravida gravida. Maecenas eleifend sodales risus, id dictum odio vehicula pulvinar. Nullam pellentesque euismod porta.";
    [self.view addSubview:self.textView];
}

@end
