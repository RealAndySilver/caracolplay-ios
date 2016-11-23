//
//  VideoPlayerViewController.m
//  CaracolPlay
//
//  Created by Developer on 24/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "VideoPlayerViewController.h"
//#import "OOOoyalaPlayerViewController.h"
//#import "OOOoyalaPlayer.h"
//#import "OOOoyalaError.h"
#import <objc/message.h>
#import "ServerCommunicator.h"
//#import "BCOVPlayerSDK.h"
#import <AVFoundation/AVFoundation.h>
#import <BrightcovePlayerSDK/BrightcovePlayerSDK.h>
//#import "BCOVCatalogService+BCOVWidevineAdditions.h"
//#import "BCOVWidevine.h"

@interface VideoPlayerViewController () <ServerCommunicatorDelegate, BCOVPlaybackControllerDelegate>
@property (assign, nonatomic) BOOL sendProgressSecToServer;
@property (strong, nonatomic) id <BCOVPlaybackController> controller;
@property (assign, nonatomic) int progressTime;
@end

@implementation VideoPlayerViewController

NSString * const TOKEN = @"23n6CnmhPeRe86DDzyGEpd49MDVnmYzUkSUqGaVv2oDVJSgcev5_qw..";

-(void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = YES;
    NSLog(@"embed code: %@", self.embedCode);
    self.sendProgressSecToServer = NO;
    
    if (!self.controllerWasPresenteFromRedeemCode) {
        [self sendPlayVideoPetitionToServer];
    }
    /*[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStartedPlaying) name:OOOoyalaPlayerPlayStartedNotification object:nil];
    
    //Create the Ooyala ViewController
    self.ooyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPcode:PCODE domain:PLAYERDOMAIN controlType:OOOoyalaPlayerControlTypeInline];
    
    //Attach the Oooyala view controller to the view
    //self.ooyalaPlayerViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.ooyalaPlayerViewController.view.backgroundColor = [UIColor blackColor];
    [self addChildViewController:self.ooyalaPlayerViewController];
    [self.view addSubview:self.ooyalaPlayerViewController.view];
    
    //Load the video
    [self.ooyalaPlayerViewController.player setEmbedCode:self.embedCode];
    [self.ooyalaPlayerViewController.player playWithInitialTime:self.progressSec];*/
    
    // create an array of videos
    /*NSArray *videos = @[
                        [self videoWithURL:[NSURL URLWithString:@"http://cf9c36303a9981e3e8cc-31a5eb2af178214dc2ca6ce50f208bb5.r97.cf1.rackcdn.com/bigger_badminton_600.mp4"]],
                        [self videoWithURL:[NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"]]
                        ];*/
    
    
   // NSArray *videos = @[[self videoWithURL:[NSURL URLWithString:@"http://cf9c36303a9981e3e8cc-31a5eb2af178214dc2ca6ce50f208bb5.r97.cf1.rackcdn.com/bigger_badminton_600.mp4"]]];
    
    // add the playback controller
    BCOVPlayerSDKManager *manager = [BCOVPlayerSDKManager sharedManager];
    self.controller = [manager createPlaybackController];
    [self.controller setAllowsExternalPlayback:YES];
    //self.controller.view.frame = self.view.bounds;
    // create a playback controller delegate
    self.controller.delegate = self;
    
    BCOVPUIPlayerView *playerView = [[BCOVPUIPlayerView alloc] initWithPlaybackController:self.controller];
    playerView.frame = self.view.bounds;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:playerView];
    
    //self.controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    // add the controller view as a subview of the SVPViewController's view
    //[self.view addSubview:self.controller.view];
    
    // turn on auto-advance
    //self.controller.autoAdvance = YES;
    
    // add the video array to the controller's playback queue
    //[self.controller setVideos:videos];
    
    //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    //[self.controller.view addGestureRecognizer:tapGesture];
    
    BCOVCatalogService *service = [[BCOVCatalogService alloc] initWithToken:TOKEN];
    //3936114092001
    [service findVideoWithVideoID:self.embedCode parameters:nil completion:^(BCOVVideo *video, NSDictionary *jsonResponse, NSError *error) {
        if (!error) {
            NSLog(@"Response: %@", jsonResponse);
            if (video) {
                NSLog(@"The video exists");
                [self.controller setVideos:@[video]];
                //[self.controller play];
            } else {
                NSLog(@"The video doesn't exist");
            }
            
        } else {
            NSLog(@"Error description: %@", [error localizedDescription]);
            NSLog(@"Response: %@", jsonResponse);
        }
    }];
}

/*-(void)tapDetected:(UITapGestureRecognizer *)tap {
    if ([tap locationInView:self.view].y < self.view.bounds.size.height - 60.0) {
        NSLog(@"Detecté el tap");
        NSArray *subViews = [self.controller.view subviews];
        NSLog(@"EL número de subviews: %lu", (unsigned long)[subViews count]);
        UIView *subview = subViews[1];
        
        static BOOL navigationBarHidden = NO;
        if (!navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            subview.hidden = YES;
            navigationBarHidden = YES;
        } else {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            navigationBarHidden = NO;
            subview.hidden = NO;
        }
    }
}*/

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.controller.view removeFromSuperview];
    self.controller = nil;
}

/*-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    //self.ooyalaPlayerViewController.view.frame = self.view.bounds;
}*/

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.controllerWasPresenteFromRedeemCode) {
        [self postProgressSecToServer];
    }
    self.tabBarController.tabBar.alpha = 1.0;
    [self.controller pause];
}

- (BCOVVideo *)videoWithURL:(NSURL *)url
{
    // set the delivery method for BCOVSources that belong to a video
    BCOVSource *source = [[BCOVSource alloc] initWithURL:url deliveryMethod:kBCOVSourceDeliveryHLS properties:nil];
    return [[BCOVVideo alloc] initWithSource:source cuePoints:[BCOVCuePointCollection collectionWithArray:@[]] properties:@{}];
}

- (id)viewStrategy
{
    // Most apps can create a playback controller with a `nil` view strategy,
    // but for the purposes of this demo we use the stock controls.
    return [[BCOVPlayerSDKManager sharedManager] defaultControlsViewStrategy];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.alpha = 0.0;
    //[self.ooyalaPlayerViewController.player playWithInitialTime:self.progressSec];
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
    NSString *parameters = [NSString stringWithFormat:@"%@/%d", self.productID, self.progressTime];
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

/*-(void)videoStartedPlaying {
    NSLog(@"el video empezó a reproducirse");
    self.sendProgressSecToServer = YES;
}*/

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - PlaybackControllerDelegate

-(void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didProgressTo:(NSTimeInterval)progress {
    //NSLog(@"Progresss: %f", progress);
    self.progressTime = (int)progress;
}

-(void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didReceiveLifecycleEvent:(BCOVPlaybackSessionLifecycleEvent *)lifecycleEvent {
    NSLog(@"se me llamó el delegateeeeeee***************************************");
    if ([lifecycleEvent.eventType isEqualToString:kBCOVPlaybackSessionLifecycleEventReady]) {
        NSLog(@"Listooooooooooo para empezar el video");
        AVPlayer *player = session.player;
        [player seekToTime:CMTimeMakeWithSeconds(self.progressSec, 1) completionHandler:^(BOOL finished) {
            NSLog(@"Plaayayayyyyyyyyyyy");
            [player play];
        }];
    }
}

/*-(void)notificacion:(NSNotification *)notification {
 NSLog(@"Llegó la notificación");
 }*/

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
