//
//  AddToListViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 17/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "AddToListViewController.h"

@interface AddToListViewController () <UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation AddToListViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

-(void)UISetup {
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 20.0, self.view.frame.size.width, 44.0)];
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
    navigationBar.delegate = self;
    [self.view addSubview:navigationBar];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Agregar a Lista"];
    navigationBar.items = @[navigationItem];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self
                                                                                   action:@selector(dismissVC)];
    navigationItem.rightBarButtonItem = barButtonItem;
    
    //lists table view
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, navigationBar.frame.origin.y + navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (navigationBar.frame.origin.y + navigationBar.frame.size.height)) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60.0;
    tableView.separatorColor = [UIColor blackColor];
    tableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
    cell.textLabel.text = @"Series Clásicas";
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
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
