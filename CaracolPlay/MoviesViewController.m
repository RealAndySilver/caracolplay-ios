//
//  MoviesViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MoviesViewController.h"

static NSString *cellIdentifier = @"CellIdentifier";

@interface MoviesViewController ()
@property (strong, nonatomic) NSArray *moviesArray;
@end

@implementation MoviesViewController

-(void)UISetup {
    
    /*-----------------------------------------------------------*/
    //1. Create Button to filter the movies
    UIButton *filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,
                                                                        self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                        self.view.frame.size.width,
                                                                        60.0)];
    filterButton.backgroundColor = [UIColor blackColor];
    
    //2. Create a custom label to create the button title
    UILabel *filterButtonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                                10.0,
                                                                                200.0,
                                                                                40.0)];
    filterButtonTitleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    filterButtonTitleLabel.textColor = [UIColor whiteColor];
    filterButtonTitleLabel.numberOfLines = 2;
    filterButtonTitleLabel.text = @"Organizar Por\nÚltimo (Default)";
    [filterButton addSubview:filterButtonTitleLabel];
    [self.view addSubview:filterButton];
    
    //3. Create the table view to display the movies
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                           filterButton.frame.origin.y + filterButton.frame.size.height,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height - (filterButton.frame.origin.y + filterButton.frame.size.height) - 44.0)
                                                          style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.separatorColor = [UIColor blackColor];
    tableView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    tableView.rowHeight = 140.0;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Películas";
    [self UISetup];
    self.moviesArray = @[@"Mentiras Perfectas", @"Mentiras Perfectas", @"Mentiras Perfectas", @"Mentiras Perfectas", @"Mentiras Perfectas"];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.moviesArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoviesTableViewCell *moviesCell = (MoviesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!moviesCell) {
        moviesCell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    moviesCell.movieTitleLabel.text = self.moviesArray[indexPath.row];
    moviesCell.movieImageView.image = [UIImage imageNamed:@"MentirasPerfectas.jpg"];
    moviesCell.stars = 2;
    moviesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return moviesCell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MoviesEventsDetailsViewController *movieAndEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
    [self.navigationController pushViewController:movieAndEventDetailsVC animated:YES];
}

@end
