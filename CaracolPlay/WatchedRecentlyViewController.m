//
//  WatchedRecentlyViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "WatchedRecentlyViewController.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface WatchedRecentlyViewController ()

@end

@implementation WatchedRecentlyViewController

-(void)UISetup {
    
    //1. Create a segmented control to filter the productions
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"+ Nuevo", @"+ Vistas", @"+ Votadas", @"Todas"]];
    segmentedControl.frame = CGRectMake(20.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 10.0, self.view.frame.size.width - 40.0, 29.0);
    segmentedControl.tintColor = [UIColor whiteColor];
    [self.view addSubview:segmentedControl];
    
    //2. Create a table view to display the productions
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, segmentedControl.frame.origin.y + segmentedControl.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height - (segmentedControl.frame.origin.y + segmentedControl.frame.size.height + 10.0) - 44.0) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 140.0;
    tableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:tableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Vistos Recientemente";
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

#pragma mark  - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WatchedRecentlyTableViewCell *cell = (WatchedRecentlyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[WatchedRecentlyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.mainImageView.image = [UIImage imageNamed:@"MentirasPerfectas.jpg"];
    cell.mainTitleLabel.text = @"Mentiras Perfectas";
    cell.secondaryTitleLabel.text = @"Perfect Lies";
    cell.chapterNumberLabel.text = @"Capítulo 4";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewCellDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
    //videoPlayerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //[self presentViewController:videoPlayerVC animated:YES completion:nil];
    [self.navigationController pushViewController:videoPlayerVC animated:YES];
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
    return YES;
}

@end
