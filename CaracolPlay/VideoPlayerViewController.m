//
//  VideoPlayerViewController.m
//  CaracolPlay
//
//  Created by Developer on 24/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "OOOoyalaPlayerViewController.h"
#import "OOOoyalaPlayer.h"
#import "OOOoyalaError.h"
#import <objc/message.h>

@interface VideoPlayerViewController ()
@property (strong, nonatomic) OOOoyalaPlayerViewController *ooyalaPlayerViewController;
@end

@implementation VideoPlayerViewController

NSString * const EMBED_CODE = @"xxbjk1YjpHm4-VkWfWfEKBbyEkh358su";
NSString * const PCODE = @"Z5Mm06XeZlcDlfU_1R9v_L2KwYG6";
NSString * const PLAYERDOMAIN = @"www.ooyala.com";

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"la vista aprecerá");
    [super viewWillAppear:animated];
   // [self.ooyalaPlayerViewController setFullscreen:YES];
    //Create the Ooyala ViewController
    self.ooyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPcode:PCODE domain:PLAYERDOMAIN controlType:OOOoyalaPlayerControlTypeInline];
    
    //Attach the Oooyala view controller to the view
    //self.ooyalaPlayerViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width/2, self.view.frame.size.height/2);
    NSLog(@"width: %f", self.view.frame.size.width);
    self.ooyalaPlayerViewController.view.backgroundColor = [UIColor blueColor];
    [self addChildViewController:self.ooyalaPlayerViewController];
    [self.view addSubview:self.ooyalaPlayerViewController.view];
    
    //Load the video
    [self.ooyalaPlayerViewController.player setEmbedCode:EMBED_CODE];
    //NSLog(@"Control type: %ld", (long)self.ooyalaPlayerViewController.controlType);
    [self forceLandscapeMode];
}

-(void)viewDidLayoutSubviews {
    NSLog(@"me layoueee: width: %f", self.view.frame.size.width);
    self.ooyalaPlayerViewController.view.frame = CGRectMake(0.0, 44.0, self.view.bounds.size.width, self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height) - 40.0);
}

-(void)notificacion:(NSNotification *)notification {
    NSLog(@"Llegó la notificación");
}

/*-(BOOL)shouldAutorotate {
//    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
//        NSLog(@"yes");
//        return YES;
//    } else {
//        NSLog(@"No");
//        return NO;
//    }
    return NO;
}*/

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)forceLandscapeMode{
    
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        
        int type = [[UIDevice currentDevice] orientation];
        
        BOOL leftRotated=NO;
        
        if(type ==3){
            leftRotated=NO;
        }
        
        else if(type==4) {
            leftRotated=YES;
        }
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationLandscapeLeft );
            NSLog(@"dentro del if portrait");
        }
    }
}

@end
