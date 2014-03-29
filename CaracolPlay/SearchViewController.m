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

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchResultsArray;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation SearchViewController

@synthesize searchResultsArray = _searchResultsArray;

/*-(NSArray *)searchResultsArray {
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
}*/

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

-(void)setSearchResultsArray:(NSMutableArray *)searchResultsArray {
    _searchResultsArray = searchResultsArray;
    [self.tableView reloadData];
}

-(void)UISetup {
    
    //1. Search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 10.0, self.view.frame.size.width, 30.0)];
    self.searchBar.translucent = YES;
    self.searchBar.delegate = self;
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

-(void)createTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchKeyboard)];
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
    //[cell.movieImageView setImageWithURL:[NSURL URLWithString:self.searchResultsArray[indexPath.row][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    cell.movieTitleLabel.text = self.searchResultsArray[indexPath.row][@"name"];
    //cell.stars = [self.searchResultsArray[indexPath.row][@"rate"] intValue];
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
        self.searchResultsArray = [responseDictionary[@"products"] mutableCopy];
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
