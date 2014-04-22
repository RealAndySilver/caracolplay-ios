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
#import "ServerCommunicator.h"
#import "NSArray+NullReplacement.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchResultsArray;
@property (strong, nonatomic) NSMutableArray *searchResultsArrayWithNulls;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation SearchViewController

@synthesize searchResultsArray = _searchResultsArray;

#pragma mark - Lazy Instantiation, Getters & Setters

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    }
    return _spinner;
}

-(NSMutableArray *)searchResultsArray {
    if (!_searchResultsArray) {
        _searchResultsArray = [[NSMutableArray alloc] init];
    }
    return _searchResultsArray;
}

-(void)setSearchResultsArrayWithNulls:(NSMutableArray *)searchResultsArrayWithNulls {
    _searchResultsArrayWithNulls = searchResultsArrayWithNulls;
    self.searchResultsArray = [[_searchResultsArrayWithNulls arrayByReplacingNullsWithBlanks] mutableCopy];
    [self.tableView reloadData];
}

-(void)UISetup {
    
    //1. Search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 10.0, self.view.frame.size.width, 30.0)];
    self.searchBar.translucent = YES;
    self.searchBar.delegate = self;
    self.searchBar.backgroundImage = [UIImage imageNamed:@"FondoBarraBusqueda.png"];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"SearchBarBackground.png"] forState:UIControlStateNormal];
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

-(void)createTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Buscar";
    [self UISetup];
    [self createTapGesture];
    //Create a bar button item to display a spinner when the
    //user searchs for some production
    UIBarButtonItem *spinnerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    self.navigationItem.rightBarButtonItem = spinnerBarButtonItem;
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
    cell.stars = [self.searchResultsArray[indexPath.row][@"rate"] intValue]/20.0 + 1;
    if ([self.searchResultsArray[indexPath.row][@"free"] isEqualToString:@"1"]) {
        cell.freeImageView.image = [UIImage imageNamed:@"FreeBand.png"];
    } else {
        cell.freeImageView.image = nil;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Elegí uno de los resultados");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.searchResultsArray[indexPath.row][@"type"] isEqualToString:@"Series"] || [self.searchResultsArray[indexPath.row][@"type"] isEqualToString:@"Telenovelas"] || [self.searchResultsArray[indexPath.row][@"type"] isEqualToString:@"Noticias"]) {
        TelenovelSeriesDetailViewController *telenovelSeriesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
        telenovelSeriesVC.serieID = self.searchResultsArray[indexPath.row][@"id"];
        [self.navigationController pushViewController:telenovelSeriesVC animated:YES];
    
    }else if ([self.searchResultsArray[indexPath.row][@"type"] isEqualToString:@"Películas"] || [self.searchResultsArray[indexPath.row][@"type"] isEqualToString:@"Eventos en vivo"]) {
        MoviesEventsDetailsViewController *movieEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
        movieEventDetailsVC.productionID = self.searchResultsArray[indexPath.row][@"id"];
        [self.navigationController pushViewController:movieEventDetailsVC animated:YES];
    }
}

#pragma mark - Actions 

-(void)hideSearchKeyboard {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Server Stuff

-(void)getSearchResultsFromServer {
    NSLog(@"llamé al server");
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetListFromSearchWithKey" andParameter:self.searchBar.text];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    if ([methodName isEqualToString:@"GetListFromSearchWithKey"] && responseDictionary) {
        NSLog(@"La petición fue exitosa");
        self.searchResultsArrayWithNulls = [responseDictionary[@"products"] mutableCopy];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    NSLog(@"server error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Cambió el texto de la barra de búsqueda");
    [self.timer invalidate];
    if ([searchBar.text length] > 0) {
        [self.spinner startAnimating];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(getSearchResultsFromServer) userInfo:nil repeats:NO];
    } else {
        [self.searchResultsArray removeAllObjects];
        [self.spinner stopAnimating];
        [self.tableView reloadData];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
