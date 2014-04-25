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

@interface MyListsDetailsViewController () <UITableViewDataSource, UITableViewDelegate>
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
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
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
    }
}
#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
