//
//  MyListsDetailsViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 19/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsDetailsViewController.h"
#import "MyListsPadTableViewCell.h"
#import "JMImageCache.h"
#import "VideoPlayerViewController.h"
#import "Episode.h"
#import "MBProgressHUD.h"
#import "ServerCommunicator.h"
#import "NSDictionary+NullReplacement.h"
#import "Video.h"
#import "ContentNotAvailableForUserViewController.h"

@interface MyListsDetailsViewController () <UITableViewDataSource, UITableViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation MyListsDetailsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = self.navigationBarTitle;
    [self UISetup];
}

-(void)UISetup {
    // 1. Table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 140.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.tableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0);
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
        selectedView.backgroundColor = [UIColor blackColor];
        cell.selectedBackgroundView = selectedView;
    }
    Episode *episode = self.episodes[indexPath.row];
    cell.productionNameLabel.text = episode.productName;
    cell.productionDetailLabel.text = [NSString stringWithFormat:@"Capítulo %@: %@", episode.episodeNumber, episode.episodeName];
    [cell.productionImageView setImageWithURL:[NSURL URLWithString:episode.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Episode *episode = self.episodes[indexPath.row];
    [self isContentAvailableForUserWithID:episode.identifier];
    
    /*Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Para poder ver esta producción debes estar conectado a una red Wi-Fi" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        
    } else if (status == ReachableViaWWAN) {
        if ([self.episodes[indexPath.row][@"is_3g"] boolValue]) {
            VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayerVC.progressSec = [episode.progressSec intValue];
            videoPlayerVC.productID = episode.identifier;
            videoPlayerVC.embedCode = episode.url;
            [self.navigationController pushViewController:videoPlayerVC animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Tu conexión es muy lenta para poder ver la producción. Por favor conéctate a una red Wi-Fi" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
    } else if (status == ReachableViaWiFi) {
        VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
        videoPlayerVC.progressSec = [episode.progressSec intValue];
        videoPlayerVC.productID = episode.identifier;
        videoPlayerVC.embedCode = episode.url;
        [self.navigationController pushViewController:videoPlayerVC animated:YES];
    }*/
}

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
                [[[UIAlertView alloc] initWithTitle:nil message:@"Para una mejor experiencia, se recomienda usar una coenxión Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                VideoPlayerViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
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
            VideoPlayerViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.embedCode = video.embedHD;
            videoPlayer.progressSec = video.progressSec;
            videoPlayer.productID = episode.identifier;
            [self.navigationController pushViewController:videoPlayer animated:YES];
        }
        
    } else {
        //The video is not available for the user, so pass to the
        //Content not available for user
        ContentNotAvailableForUserViewController *contentNotAvailableForUser =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUser"];
        contentNotAvailableForUser.productID = episode.identifier;
        contentNotAvailableForUser.productName = episode.productName;
       // contentNotAvailableForUser.productType = self.production.type;
        contentNotAvailableForUser.viewType = video.typeView;
        [self.navigationController pushViewController:contentNotAvailableForUser animated:YES];
    }
}

-(void)isContentAvailableForUserWithID:(NSString *)episodeID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:episodeID];
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

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
