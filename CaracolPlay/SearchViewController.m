//
//  SearchViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SearchViewController.h"
#import "MoviesTableViewCell.h"
#import "JMImageCache.h"
#import "TelenovelSeriesDetailViewController.h"
#import "MoviesEventsDetailsViewController.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *searchResultsArray;
@end

@implementation SearchViewController

-(NSArray *)searchResultsArray {
    if (!_searchResultsArray) {
        _searchResultsArray = @[@{@"name" : @"La pena máximo",
                                  @"type": @"Peliculas",
                                  @"feature_text": @"no te pierdas el capítulo de hoy!",
                                  @"rate": @3,
                                  @"id": @"90182734",
                                  @"category_id": @"823714",
                                  @"image_url": @"http://www.colombiancinema.org/web2008/posters/poster-lapenamaxima.jpg"},
                                
                                @{@"name" : @"La esquina",
                                  @"type": @"Peliculas",
                                  @"feature_text": @"no te pierdas el capítulo de hoy!",
                                  @"rate": @3,
                                  @"id": @"90182734",
                                  @"category_id": @"823714",
                                  @"image_url": @"http://cinecolombiano.com/wp-content/uploads/2013/06/La-Esquina-165x243.png"},
                                
                                @{@"name" : @"Pecados Capitales",
                                  @"type": @"Series",
                                  @"feature_text": @"no te pierdas el capítulo de hoy!",
                                  @"rate": @5,
                                  @"id": @"90182734",
                                  @"category_id": @"823714",
                                  @"image_url": @"http://2.bp.blogspot.com/-oDOoJn-nx3s/T_4rXnA7ZtI/AAAAAAAAAB4/qcm5N2bmG48/s1600/pecados.png"},
                                
                                @{@"name" : @"Escobar, el patrón del mal",
                                  @"type": @"Series",
                                  @"feature_text": @"no te pierdas el capítulo de hoy!",
                                  @"rate": @5,
                                  @"id": @"90182734",
                                  @"category_id": @"823714",
                                  @"image_url": @"http://cubademocraciayvida.org/media/ooooooooooooooooooo%20a%20fotos%20a%201/PABLO-ESCOBAR.jpg"},
                                
                                @{@"name" : @"Colombia's Next Top Model",
                                  @"type": @"Series",
                                  @"feature_text": @"no te pierdas el capítulo de hoy!",
                                  @"rate": @2,
                                  @"id": @"90182734",
                                  @"category_id": @"823714",
                                  @"image_url": @"http://esteeselpunto.com/wp-content/uploads/2013/02/Final-Colombia-Next-Top-Model-1024x871.png"},
                                
                                @{@"name" : @"El Carro",
                                  @"type": @"Peliculas",
                                  @"feature_text": @"no te pierdas el capítulo de hoy!",
                                  @"rate": @2,
                                  @"id": @"90182734",
                                  @"category_id": @"823714",
                                  @"image_url": @"http://2.bp.blogspot.com/-b53JD5BbF3M/Tl4VeZwpu5I/AAAAAAAAETs/OBqESxznww4/s1600/carro.jpg"}];
    }
    return _searchResultsArray;
}

-(void)UISetup {
    
    //1. Search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 10.0, self.view.frame.size.width, 30.0)];
    self.searchBar.translucent = YES;
    self.searchBar.backgroundImage = [UIImage imageNamed:@"FondoBarraBusqueda.png"];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"SearchBarPad.png"] forState:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.searchBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, self.searchBar.frame.origin.y + self.searchBar.frame.size.height + 10.0, self.view.frame.size.width, self.view.frame.size.height - 112.0 - (self.searchBar.frame.origin.y + self.searchBar.frame.size.height + 10.0)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 130.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.view addSubview:self.tableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Buscar";
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResultsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoviesTableViewCell *cell = (MoviesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    [cell.movieImageView setImageWithURL:[NSURL URLWithString:self.searchResultsArray[indexPath.row][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    cell.movieTitleLabel.text = self.searchResultsArray[indexPath.row][@"name"];
    cell.stars = [self.searchResultsArray[indexPath.row][@"rate"] intValue];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.searchResultsArray[indexPath.row][@"type"] isEqualToString:@"Series"]) {
        TelenovelSeriesDetailViewController *telenovelSeriesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
        [self.navigationController pushViewController:telenovelSeriesVC animated:YES];
    
    }else if ([self.searchResultsArray[indexPath.row][@"type"] isEqualToString:@"Peliculas"]) {
        MoviesEventsDetailsViewController *movieEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
        [self.navigationController pushViewController:movieEventDetailsVC animated:YES];
    }
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
