//
//  VideoPlayerPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 14/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "VideoPlayerPadViewController.h"
//#import "OOOoyalaPlayerViewController.h"
//#import "OOOoyalaPlayer.h"
//#import "OOOoyalaError.h"
#import "ServerCommunicator.h"
#import "BCOVPlayerSDK.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayerPadViewController () <UIBarPositioningDelegate, ServerCommunicatorDelegate, BCOVPlaybackControllerDelegate, UINavigationBarDelegate>
//@property (strong, nonatomic) OOOoyalaPlayerViewController *ooyalaPlayerViewController;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UINavigationItem *navBarItem;
@property (strong, nonatomic) NSString *pcode;
@property (strong, nonatomic) NSString *playerDomain;
@property (assign, nonatomic) BOOL videoWasPlayed;
@property (strong, nonatomic) id <BCOVPlaybackController> controller;
@end

@implementation VideoPlayerPadViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.pcode = @"n728cv9Ro-9N2pIPcA0vqCPxI_1yuaWcz1XaEpkc";
    self.playerDomain = @"www.ooyala.com";
    
    if (!self.isWatchingTrailer) {
        //Add as an observer of the OoyalaPlayerPlayStartedNotification. When this notification is received,
        //the video started playing, so we have to send to the server the progress seconds of the video when the
        //user stops watching it.
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStartedPlaying) name:OOOoyalaPlayerPlayStartedNotification object:nil];
    }
    
    //Navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"CategoriesNavBarImage.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    [self.view addSubview:self.navigationBar];
    
    self.navBarItem = [[UINavigationItem alloc] initWithTitle:nil];
    self.navigationBar.items = @[self.navBarItem];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás" style:UIBarButtonItemStylePlain target:self action:@selector(dismissVC)];
    self.navBarItem.leftBarButtonItem = backBarButtonItem;
    
    //////////////////////////////////////////////////////////////////////////////
    //BrightCove Setup
    NSArray *videos = @[[self videoWithURL:[NSURL URLWithString:@"http://cf9c36303a9981e3e8cc-31a5eb2af178214dc2ca6ce50f208bb5.r97.cf1.rackcdn.com/bigger_badminton_600.mp4"]]];
    
    // add the playback controller
    self.controller = [[BCOVPlayerSDKManager sharedManager] createPlaybackControllerWithViewStrategy:[self viewStrategy]];
    self.controller.view.frame = self.view.bounds;
    // create a playback controller delegate
    self.controller.delegate = self;
    
    self.controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    // add the controller view as a subview of the SVPViewController's view
    [self.view addSubview:self.controller.view];
    [self.view bringSubviewToFront:self.navigationBar];
    
    // turn on auto-advance
    self.controller.autoAdvance = YES;
    
    // add the video array to the controller's playback queue
    [self.controller setVideos:videos];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    [self.controller.view addGestureRecognizer:tapGesture];
    
    
    
    //Ooyala Setup
    //[self ooyalaSetup];
}

-(void)tapDetected {
    //NSLog(@"Detecté el tap");
    NSArray *subViews = [self.controller.view subviews];
    NSLog(@"EL número de subviews: %lu", (unsigned long)[subViews count]);
    UIView *subview = subViews[1];
    
    static BOOL navigationBarHidden = NO;
    if (!navigationBarHidden) {
        self.navigationBar.hidden = YES;
        subview.hidden = YES;
        navigationBarHidden = YES;
    } else {
        self.navigationBar.hidden = NO;
        navigationBarHidden = NO;
        subview.hidden = NO;
    }
}

-(void)ooyalaSetup {
    //Create the Ooyala ViewController
    /*self.ooyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPcode:self.pcode domain:self.playerDomain controlType:OOOoyalaPlayerControlTypeInline];
    
    //Attach the Oooyala view controller to the view
    //self.ooyalaPlayerViewController.view.frame = self.view.frame;
    self.ooyalaPlayerViewController.view.backgroundColor = [UIColor blackColor];
    [self addChildViewController:self.ooyalaPlayerViewController];
    [self.view addSubview:self.ooyalaPlayerViewController.view];
    
    //Load the video
    [self.ooyalaPlayerViewController.player setEmbedCode:self.embedCode];
    [self.ooyalaPlayerViewController.player playWithInitialTime:self.progressSec];*/
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"bounds of video: %@", NSStringFromCGRect(self.view.bounds));
    //self.ooyalaPlayerViewController.view.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.controller pause];
    //self.tabBarController.tabBar.alpha = 1.0;
    //[self.ooyalaPlayerViewController.player pause];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.controller.view removeFromSuperview];
    self.controller = nil;
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

#pragma mark - Notification Handlers

-(void)videoStartedPlaying {
    NSLog(@"llegó la notificación de que el video empezó a correr");
    self.videoWasPlayed = YES;
}

#pragma mark - Actions

-(void)dismissVC {
    if (self.videoWasPlayed) {
       /* NSLog(@"envié la info de los segundos al server");
        
        //If the video was played, send the progress sec info to the server
        ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
        serverCommunicator.delegate = self;
        int segundos = (int)self.ooyalaPlayerViewController.player.playheadTime;
        NSString *parameters = [NSString stringWithFormat:@"%@/%d", self.episodeID, segundos];
        NSLog(@"parámetros: %@", parameters);
        [serverCommunicator callServerWithGETMethod:@"VideoWatched" andParameter:parameters];*/
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    if ([methodName isEqualToString:@"VideoWatched"] && responseDictionary) {
        NSLog(@"respuesta de los segundos del video: %@", responseDictionary);
        
    } else {
        NSLog(@"No se envio la info al server");
    }
}

-(void)serverError:(NSError *)error {
    NSLog(@"no se envió la info al server");
}

#pragma mark - PlaybackControllerDelegate

-(void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didProgressTo:(NSTimeInterval)progress {
    //NSLog(@"Progresss: %f", progress);
}

-(void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didReceiveLifecycleEvent:(BCOVPlaybackSessionLifecycleEvent *)lifecycleEvent {
    if ([lifecycleEvent.eventType isEqualToString:kBCOVPlaybackSessionLifecycleEventReady]) {
        AVPlayer *player = session.player;
        [player seekToTime:CMTimeMakeWithSeconds(8, 1) completionHandler:^(BOOL finished) {
            [player play];
        }];
    }
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}
@end
