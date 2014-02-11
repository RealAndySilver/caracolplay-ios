//
//  CategoriesViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Categoria.h"

static NSString *CellIdentifier = @"CellIdentifier";

@interface CategoriesViewController ()
@property (strong, nonatomic) NSArray *unparsedCategoriesList;
@property (strong, nonatomic) NSMutableArray *parsedCategoriesList;
@end

@implementation CategoriesViewController

#pragma mark - Lazy Instantiation 

-(NSArray *)unparsedCategoriesList {
    if (!_unparsedCategoriesList) {
        _unparsedCategoriesList = @[@{@"name": @"Vistos Recientemente", @"id" : @"23556"},
                                    @{@"name": @"Telenovelas", @"id" : @"23532"},
                                    @{@"name": @"Series", @"id" : @"22133"},
                                    @{@"name": @"Películas", @"id" : @"64556"},
                                    @{@"name": @"Noticias", @"id" : @"23456"},
                                    @{@"name": @"Eventos en vivo", @"id" : @"63656"}];
    }
    return _unparsedCategoriesList;
}

#pragma mark - UISetup & Initialization stuff

-(void)parseCategoriesList {
    self.parsedCategoriesList = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedCategoriesList count]; i++) {
        Categoria *category = [[Categoria alloc] initWithDictionary:self.unparsedCategoriesList[i]];
        [self.parsedCategoriesList addObject:category];
    }
    NSLog(@"parse count: %d", [self.parsedCategoriesList count]);
}

-(void)UISetup {
    
    self.navigationItem.title = @"Categorías";
    
    //1. Create a TableView to display the categories
    UITableView *categoriesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                                     self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                                     self.view.bounds.size.width,
                                                                                     self.view.bounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height) - 44.0)
                                                                    style:UITableViewStylePlain];
    categoriesTableView.delegate = self;
    categoriesTableView.dataSource = self;
    categoriesTableView.backgroundColor = [UIColor blackColor];
    categoriesTableView.rowHeight = 50.0;
    categoriesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    categoriesTableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.view addSubview:categoriesTableView];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self parseCategoriesList];
    [self UISetup];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.parsedCategoriesList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Categoria *category = self.parsedCategoriesList[indexPath.row];
    cell.textLabel.text = category.name;
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Categoria *category = self.parsedCategoriesList[indexPath.row];
    
    if (indexPath.row == 0) {
        //Watched Recently
        WatchedRecentlyViewController *watchedRecentlyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WatchedRecently"];
        [self.navigationController pushViewController:watchedRecentlyVC animated:YES];
    }
    else if (indexPath.row == 1 || indexPath.row == 2) {
        //Telenovel/Series
        ProductionsListViewController *moviesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Movies"];
        //moviesVC.isTelenovelOrSeriesList = YES;
        moviesVC.navigationBarTitle = category.name;
        [self.navigationController pushViewController:moviesVC animated:YES];
    }
    else if (indexPath.row == 3 || indexPath.row == 5) {
        //Movies
        ProductionsListViewController *moviesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Movies"];
        //moviesVC.isTelenovelOrSeriesList = NO;
        moviesVC.navigationBarTitle = category.name;
        [self.navigationController pushViewController:moviesVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
