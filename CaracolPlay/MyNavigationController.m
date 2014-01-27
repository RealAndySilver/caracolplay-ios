//
//  MyNavigationController.m
//  CaracolPlay
//
//  Created by Developer on 24/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@end

@implementation MyNavigationController

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
