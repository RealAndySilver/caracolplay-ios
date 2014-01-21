//
//  CategoriesViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CategoriesViewController.h"

static NSString *CellIdentifier = @"CellIdentifier";

@interface CategoriesViewController ()
@property (strong, nonatomic) NSArray *categoriesList;
@end

@implementation CategoriesViewController

-(void)UISetup {
    
    self.navigationItem.title = @"Categorías";
    
    //1. Create a TableView to display the categories
    UITableView *categoriesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                                     self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                                     self.view.frame.size.width,
                                                                                     self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height) - 44.0)
                                                                    style:UITableViewStylePlain];
    categoriesTableView.delegate = self;
    categoriesTableView.dataSource = self;
    categoriesTableView.backgroundColor = [UIColor blackColor];
    categoriesTableView.rowHeight = 60.0;
    [self.view addSubview:categoriesTableView];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
    
    self.categoriesList = @[@"Vistos Recientemente", @"Telenovelas", @"Series", @"Películas", @"Noticias", @"Eventos en Vivo"];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categoriesList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.categoriesList[indexPath.row];
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3 ) {
        MoviesViewController *moviesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Movies"];
        [self.navigationController pushViewController:moviesVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
