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

@interface VideoPlayerPadViewController () < UIBarPositioningDelegate, ServerCommunicatorDelegate>
//@property (strong, nonatomic) OOOoyalaPlayerViewController *ooyalaPlayerViewController;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UINavigationItem *navBarItem;
@property (strong, nonatomic) NSString *pcode;
@property (strong, nonatomic) NSString *playerDomain;
@property (assign, nonatomic) BOOL videoWasPlayed;
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
    
    //Ooyala Setup
    [self ooyalaSetup];
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
    //self.tabBarController.tabBar.alpha = 1.0;
    //[self.ooyalaPlayerViewController.player pause];
    
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

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}
@end
