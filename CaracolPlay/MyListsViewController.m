//
//  MyListsViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsViewController.h"
#import "List.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface MyListsViewController ()
@property (strong, nonatomic) NSArray *unparsedLists;
@property (strong, nonatomic) NSMutableArray *parsedLists;
@end

@implementation MyListsViewController

#pragma mark - Lazy Instantiation 

-(NSArray *)unparsedLists {
    if (!_unparsedLists) {
        _unparsedLists = @[@{@"list_name": @"Películas Chistosas", @"list_id" : @"23424", @"episodes" : @[]},
                           @{@"list_name": @"Series Drámaticas", @"list_id" : @"23424", @"episodes" : @[]},
                           @{@"list_name": @"Partidos Clásicos", @"list_id" : @"23424", @"episodes" : @[]},
                           @{@"list_name": @"Películas de Terror", @"list_id" : @"23424", @"episodes" : @[]},
                           @{@"list_name": @"Telenovelas de los 90's", @"list_id" : @"23424", @"episodes" : @[]}];
    }
    return _unparsedLists;
}

-(void)parseLists {
    self.parsedLists = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedLists count]; i++) {
        List *list = [[List alloc] initWithDictionary:self.unparsedLists[i]];
        [self.parsedLists addObject:list];
    }
}

#pragma mark - UISetup & Initialization Stuff

-(void)UISetup {
    //1. Create a segmented control to choose my lists or the recommended lists
    /*UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Mis Listas", @"Recomendadas"]];
    segmentedControl.frame = CGRectMake(40.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 10.0, self.view.frame.size.width - 80.0, 29.0);
    segmentedControl.tintColor = [UIColor whiteColor];
    [self.view addSubview:segmentedControl];*/
    
    //2. Create a table view to diaply the user's lists
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 50.0)) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50.0;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:tableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self parseLists];
    [self UISetup];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Mis Listas";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.parsedLists count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = ((List *)self.parsedLists[indexPath.row]).listName;
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
