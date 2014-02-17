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
#import "Reachability.h"

@interface MyListsDetailPadViewController () < UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation MyListsDetailPadViewController

@synthesize episodes = _episodes;

#pragma mark - Lazy Instantiation 

-(NSMutableArray *)episodes {
    if (!_episodes) {
        _episodes = [[NSMutableArray alloc] init];
    }
    return _episodes;
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
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //Set subviews frame
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.tableView.frame = CGRectMake(0.0, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height));
}

#pragma mark - Setters

-(void)setEpisodes:(NSMutableArray *)episodes {
    _episodes = episodes;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.episodes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyListsPadTableViewCell *cell = (MyListsPadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[MyListsPadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    [cell.productionImageView setImageWithURL:[NSURL URLWithString:self.episodes[indexPath.row][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    cell.productionNameLabel.text = self.episodes[indexPath.row][@"product_name"];
    cell.productionDetailLabel.text = self.episodes[indexPath.row][@"description"];
    return cell;
}

#pragma mark - UITableViewDelegate

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.episodes removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //We have to check the network status to allow the user to watch the video.
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        // No internet, so the user can't pass
        [[[UIAlertView alloc] initWithTitle:nil message:@"No hay conexión a internet. Por favor revisa que tu dispositivo esté conectado a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else if (status == ReachableViaWWAN) {
        // 3G connection. If the video can be watched using 3g, the user can pass, otherwise we show an alert
        if ([self.episodes[indexPath.row][@"is_3g"] boolValue]) {
            [self watchEpisode];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Tu conexión a internet es muy lenta. Por favor conéctate a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if (status == ReachableViaWiFi) {
        // Wi-Fi Connection. The user can watch the video.
        [self watchEpisode];
    }
}

#pragma mark - Custom Methods

-(void)watchEpisode {
    VideoPlayerPadViewController *videoPlayerPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
    [self presentViewController:videoPlayerPadVC animated:YES completion:nil];
}

#pragma mark - UIBarPositioningDelegate 

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
