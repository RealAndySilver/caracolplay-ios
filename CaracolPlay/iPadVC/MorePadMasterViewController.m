//
//  MoreViewController.m
//  CaracolPlay
//
//  Created by Developer on 17/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MorePadMasterViewController.h"
#import "TermsAndConditionsPadViewController.h"
#import "MyAccountDetailPadViewController.h"

@interface MorePadMasterViewController () <UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *menuOptionsArray;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation MorePadMasterViewController

#pragma mark - Lazy Instantiation

-(NSArray *)menuOptionsArray {
    if (!_menuOptionsArray) {
        _menuOptionsArray = @[@"Mi Cuenta", @"Reporte de errores", @"Terminos y condiciones", @"Politicas del servicio"];
    }
    return _menuOptionsArray;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // Set subviews frame
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.tableView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0);
}

#pragma mark - UISetup & Initialization stuff

-(void)UISetup {
    // 1. Create a navigation bar
    self.navigationBar = [[UINavigationBar alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarMaster.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    [self.view addSubview:self.navigationBar];
    
    // 2. Table view setup
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuOptionsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.textLabel.text = self.menuOptionsArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        MyAccountDetailPadViewController *myAccountDetailPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAccountDetailPad"];
        NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:self.splitViewController.viewControllers];
        [viewControllersArray replaceObjectAtIndex:1 withObject:myAccountDetailPadVC];
        self.splitViewController.viewControllers = viewControllersArray;
        
    } else if (indexPath.row == 2 || indexPath.row == 3) {
        TermsAndConditionsPadViewController *termsConditionsPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsPad"];
        NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:self.splitViewController.viewControllers];
        [viewControllersArray replaceObjectAtIndex:1 withObject:termsConditionsPadVC];
        self.splitViewController.viewControllers = viewControllersArray;
    }
}

#pragma mark - UIBarPositioningDelegate 

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


@end
