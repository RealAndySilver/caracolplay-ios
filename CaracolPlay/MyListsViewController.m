//
//  MyListsViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsViewController.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface MyListsViewController ()

@end

@implementation MyListsViewController

-(void)UISetup {
    //1. Create a segmented control to choose my lists or the recommended lists
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Mis Listas", @"Recomendadas"]];
    segmentedControl.frame = CGRectMake(40.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 10.0, self.view.frame.size.width - 80.0, 29.0);
    segmentedControl.tintColor = [UIColor whiteColor];
    [self.view addSubview:segmentedControl];
    
    //2. Create a table view to diaply the user's lists
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 50.0, self.view.frame.size.width, self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 50.0)) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50.0;
    tableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:tableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Mis Listas";
    [self UISetup];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"Mis peliculas favoritas";
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
