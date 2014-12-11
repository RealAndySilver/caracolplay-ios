//
//  MyListsDetailPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 14/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsDetailPadViewController.h"
#import "VideoPlayerPadViewController.h"
#import "MyListsPadTableViewCell.h"
#import "JMImageCache.h"
#import "Episode.h"
#import "MBProgressHUD.h"
#import "ServerCommunicator.h"
#import "Video.h"
#import "NSDictionary+NullReplacement.h"

@interface MyListsDetailPadViewController () < UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation MyListsDetailPadViewController

@synthesize episodes = _episodes;

#pragma mark - Setters & Getters

-(NSMutableArray *)episodes {
    if (!_episodes) {
        _episodes = [[NSMutableArray alloc] init];
    }
    return _episodes;
}

-(void)setEpisodes:(NSMutableArray *)episodes {
    _episodes = episodes;
    [self.tableView reloadData];
}

#pragma mark - UISetup & Initialization stuff

-(void)UISetup {
    // 1. NavigationBar Setup
    self.navigationBar = [[UINavigationBar alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarDetail.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    [self.view addSubview:self.navigationBar];
    
    //2. Table view setup
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 100.0;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.view addSubview:self.tableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userListInfoReceived:) name:@"FirstUserListNotification" object:nil];
    
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //Set subviews frame
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.tableView.frame = CGRectMake(0.0, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height));
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.episodes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyListsPadTableViewCell *cell = (MyListsPadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[MyListsPadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height)];
        selectedView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        cell.selectedBackgroundView = selectedView;
    }
    cell.backgroundColor=[UIColor clearColor];

    Episode *episode = self.episodes[indexPath.row];
    [cell.productionImageView setImageWithURL:[NSURL URLWithString:episode.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    cell.productionNameLabel.text = episode.productName;
    cell.productionDetailLabel.text = [NSString stringWithFormat:@"Capítulo %d: %@", [episode.episodeNumber intValue], episode.aDescription];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Episode *episode = self.episodes[indexPath.row];
    [self isContentAvailableForUserWithID:episode.identifier];
    
    //We have to check the network status to allow the user to watch the video.
    /*Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        // No internet, so the user can't pass
        [[[UIAlertView alloc] initWithTitle:nil message:@"No hay conexión a internet. Por favor revisa que tu dispositivo esté conectado a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else if (status == ReachableViaWWAN) {
        // 3G connection. If the video can be watched using 3g, the user can pass, otherwise we show an alert
        if ([self.episodes[indexPath.row][@"is_3g"] boolValue]) {
            [self watchEpisode:episode];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Tu conexión a internet es muy lenta. Por favor conéctate a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if (status == ReachableViaWiFi) {
        // Wi-Fi Connection. The user can watch the video.
        [self watchEpisode:episode];
    }*/
}

#pragma mark - Custom Methods

-(void)checkVideoAvailability:(Video *)video {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Episode *episode = self.episodes[indexPath.row];
    
    if (video.status) {
        //The video is available for the user, so check the network connection to decide
        //if the user can pass to watch it or not.
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        if (status == NotReachable) {
            //The user can't watch the video
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No te encuentras conectado a internet. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        } else if (status == ReachableViaWWAN) {
            if (video.is3G) {
                //The user can watch it with 3G
                [[[UIAlertView alloc] initWithTitle:nil message:@"Para una mejor experiencia, se recomienda usar una conexión Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                videoPlayer.embedCode = video.embedHD;
                videoPlayer.productID = episode.identifier;
                videoPlayer.progressSec = video.progressSec;
                [self.navigationController pushViewController:videoPlayer animated:YES];
            } else {
                //The user can't watch the video because the connection is to slow
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Para ver este contenido conéctese a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else if (status == ReachableViaWiFi) {
            //The user can watch the video
            VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.embedCode = video.embedHD;
            videoPlayer.progressSec = video.progressSec;
            videoPlayer.productID = episode.identifier;
            [self.navigationController pushViewController:videoPlayer animated:YES];
        }
        
    } else {
        //The video is not available for the user, so pass to the
        //Content not available for user
        /*ContentNotAvailableForUserViewController *contentNotAvailableForUser =
         [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUser"];
         contentNotAvailableForUser.productID = episode.identifier;
         contentNotAvailableForUser.productName = episode.productName;
         contentNotAvailableForUser.productType = self.production.type;
         contentNotAvailableForUser.viewType = video.typeView;
         [self.navigationController pushViewController:contentNotAvailableForUser animated:YES];*/
        [[[UIAlertView alloc] initWithTitle:nil message:@"Este contenido no está disponible" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)isContentAvailableForUserWithID:(NSString *)episodeID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:[NSString stringWithFormat:@"%@?provider=aim", episodeID]];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:@"IsContentAvailableForUser"] && dictionary) {
        if ([dictionary[@"status"] boolValue]) {
            //La petición fue exitosa
            NSLog(@"info del video: %@", dictionary);
            NSDictionary *dicWithoutNulls = [dictionary dictionaryByReplacingNullWithBlanks];
            Video *video = [[Video alloc] initWithDictionary:dicWithoutNulls[@"video"]];
            [self checkVideoAvailability:video];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"El contenido no está disponible" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            NSLog(@"error en el is content: %@", dictionary);
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

/*-(void)watchEpisode:(Episode*)episode {
//    VideoPlayerPadViewController *videoPlayerPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
//    [self presentViewController:videoPlayerPadVC animated:YES completion:nil];
    VideoPlayerPadViewController *videoPlayerPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
    videoPlayerPadVC.progressSec = [episode.progressSec intValue];
    videoPlayerPadVC.productID = episode.identifier;
    videoPlayerPadVC.embedCode = episode.url;
    [self presentViewController:videoPlayerPadVC animated:YES completion:nil];
}*/

#pragma mark - Notification Handlers

-(void)userListInfoReceived:(NSNotification *)notification {
    NSLog(@"recibí la info de las listas");
    NSDictionary *notificationDictionary = [notification userInfo];
    self.episodes = notificationDictionary[@"FirstUserList"];
}

#pragma mark - UIBarPositioningDelegate 

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
