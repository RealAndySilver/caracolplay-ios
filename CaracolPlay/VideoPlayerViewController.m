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
#import "ServerCommunicator.h"

@interface VideoPlayerViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) OOOoyalaPlayerViewController *ooyalaPlayerViewController;
@property (assign, nonatomic) BOOL sendProgressSecToServer;
@end

@implementation VideoPlayerViewController

NSString * const EMBED_CODE = @"1xZHNqazrsqfsHoMSjFk7Run5dd0DxKT";
NSString * const PCODE = @"n728cv9Ro-9N2pIPcA0vqCPxI_1yuaWcz1XaEpkc";
NSString * const PLAYERDOMAIN = @"www.ooyala.com";


-(void)viewDidLoad {
    [super viewDidLoad];
    self.sendProgressSecToServer = NO;
    
    if (!self.controllerWasPresenteFromRedeemCode) {
        [self sendPlayVideoPetitionToServer];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStartedPlaying) name:OOOoyalaPlayerPlayStartedNotification object:nil];
    
    //Create the Ooyala ViewController
    self.ooyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPcode:PCODE domain:PLAYERDOMAIN controlType:OOOoyalaPlayerControlTypeInline];
    
    //Attach the Oooyala view controller to the view
    //self.ooyalaPlayerViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width/2, self.view.frame.size.height/2);
    NSLog(@"width: %f", self.view.frame.size.width);
    self.ooyalaPlayerViewController.view.backgroundColor = [UIColor blackColor];
    [self addChildViewController:self.ooyalaPlayerViewController];
    [self.view addSubview:self.ooyalaPlayerViewController.view];
    
    //Load the video
    [self.ooyalaPlayerViewController.player setEmbedCode:self.embedCode];
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"la vista aprecerá");
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.alpha = 0.0;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"me layoueee: width: %f", self.view.frame.size.width);
    self.ooyalaPlayerViewController.view.frame = self.view.bounds;
    //[self.ooyalaPlayerViewController.player play];
    [self.ooyalaPlayerViewController.player playWithInitialTime:self.progressSec];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.controllerWasPresenteFromRedeemCode) {
        [self postProgressSecToServer];
    }
    self.tabBarController.tabBar.alpha = 1.0;
    [self.ooyalaPlayerViewController.player pause];
    NSLog(@"tiempo actual: %f", self.ooyalaPlayerViewController.player.playheadTime);
}

#pragma mark - Server Stuff

-(void)sendPlayVideoPetitionToServer {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"PlayVideo" andParameter:self.productID];
}

-(void)postProgressSecToServer {
    //FIXME: no está funcionando la petición
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"%@/%d", self.productID, (int)self.ooyalaPlayerViewController.player.playheadTime];
    [serverCommunicator callServerWithGETMethod:@"VideoWatched" andParameter:parameters];
    NSLog(@"parámetros: %@", parameters);
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    if ([methodName isEqualToString:@"VideoWatched"] && responseDictionary) {
        NSLog(@"Petición exitosa: %@", responseDictionary);
        
    } else if ([methodName isEqualToString:@"PlayVideo"] && responseDictionary) {
        NSLog(@"peticion PlayVideo exitosa: %@", responseDictionary);
    } else {
        NSLog(@"Hubo un problema enviando la info al server");
    }
}

-(void)serverError:(NSError *)error {
    NSLog(@"hubo un problema enviando la info al server");
}

#pragma mark - Notification Handlers

-(void)videoStartedPlaying {
    NSLog(@"el video empezó a reproducirse");
    self.sendProgressSecToServer = YES;
}

/*-(void)notificacion:(NSNotification *)notification {
    NSLog(@"Llegó la notificación");
}*/

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

/*-(void)forceLandscapeMode{
    
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
}*/

@end
