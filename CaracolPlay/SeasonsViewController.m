//
//  SeasonsViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 14/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SeasonsViewController.h"

@interface SeasonsViewController () <UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation SeasonsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self UISetup];
}

-(void)UISetup {
    //Navigation Bar
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0)];
    navigationBar.delegate = self;
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Temporadas"];
    navigationBar.items = @[navigationItem];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissVC)];
    navigationItem.rightBarButtonItem = barButtonItem;
    
    [self.view addSubview:navigationBar];
    
    //Table view
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, navigationBar.frame.origin.y + navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - 54.0) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    tableView.separatorColor = [UIColor blackColor];
    tableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfSeasons;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [NSString stringWithFormat:@"Temporada %d", indexPath.row + 1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissVC];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SeasonSelectedNotification" object:nil userInfo:@{@"SeasonSelected": @(indexPath.row)}];
}

#pragma mark - Actions

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
