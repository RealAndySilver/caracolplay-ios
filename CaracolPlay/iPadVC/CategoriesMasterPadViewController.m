//
//  CategoriesMasterPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 11/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CategoriesMasterPadViewController.h"
#import "CategoriesDetailPadViewController.h"

@interface CategoriesMasterPadViewController () <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *categoriesList;
@property (strong, nonatomic) CategoriesDetailPadViewController *categoriesDetailVC;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIImageView *titleImageView;
@end

@implementation CategoriesMasterPadViewController

#pragma mark - Lazy Instantiation 

-(NSArray *)categoriesList {
    if (!_categoriesList) {
        _categoriesList = @[@"Vistos recientemente", @"Series", @"Telenovelas", @"Películas", @"Noticias", @"Eventos en vivo"];
    }
    return _categoriesList;
}

-(void)UISetup {
    //1. categories list
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    
    //2. navigation Bar
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarMaster.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    //3. Orange title image view
    self.titleImageView = [[UIImageView alloc] init];
    self.titleImageView.image = [UIImage imageNamed:@"CategoriesOrangeTitle.png"];
    [self.view addSubview:self.titleImageView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"Bounds: %@", NSStringFromCGRect(self.view.bounds));
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.titleImageView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, 73.0);
    self.tableView.frame = CGRectMake(0.0, self.titleImageView.frame.origin.y + self.titleImageView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.titleImageView.frame.origin.y + self.titleImageView.frame.size.height));
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categoriesList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = self.categoriesList[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.categoriesDetailVC = self.splitViewController.viewControllers[1];
    self.categoriesDetailVC.bgColor = [UIColor cyanColor];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
