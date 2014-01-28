//
//  CategoriesiPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 28/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CategoriesiPadViewController.h"

@interface CategoriesiPadViewController ()

@end

@implementation CategoriesiPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    self.navigationItem.title = @"Categorías";
    
    //Add a button to the navigation bar
    UIBarButtonItem *categoriesBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Vistos Recientemente" style:UIBarButtonItemStylePlain target:self action:@selector(openPopoverMenu)];
    self.navigationItem.rightBarButtonItem = categoriesBarButtonItem;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

-(void)openPopoverMenu {
    NSLog(@"Open Menu");
}

@end
