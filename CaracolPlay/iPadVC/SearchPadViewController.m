//
//  SearchPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SearchPadViewController.h"
#import "SearchPadCollectionViewCell.h"
#import "StarsView.h"
#import "JMImageCache.h"
#import "MovieDetailsPadViewController.h"
#import "SeriesDetailPadViewController.h"
#import "ServerCommunicator.h"
#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"

@interface SearchPadViewController () < UIBarPositioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSMutableArray *searchResultsArray;
@property (strong, nonatomic) NSMutableArray *searchResultsArrayWithNulls;
@property (strong, nonatomic) UIImageView *opacityView;
@end

@implementation SearchPadViewController

#pragma mark - Setters & Getters

-(NSMutableArray *)searchResultsArray {
    if (!_searchResultsArray) {
        _searchResultsArray = [[NSMutableArray alloc] init];
    }
    return _searchResultsArray;
}

-(void)setSearchResultsArrayWithNulls:(NSMutableArray *)searchResultsArrayWithNulls {
    _searchResultsArrayWithNulls = searchResultsArrayWithNulls;
    self.searchResultsArray = [NSMutableArray arrayWithArray:[searchResultsArrayWithNulls arrayByReplacingNullsWithBlanks]];
    [self setupCollectionVIew];
    //self.searchResultsArray = [[_searchResultsArrayWithNulls arrayByReplacingNullsWithBlanks] mutableCopy];
    //[self.collectionView reloadData];
}

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    }
    return _spinner;
}

-(void)setupCollectionVIew {
    CGRect screenFrame = CGRectMake(0.0, 0.0, 1024.0, 768.0);

    //3. Collection view
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.itemSize = CGSizeMake(320.0, 130.0);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 130.0, screenFrame.size.width, screenFrame.size.height - 190.0) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    [self.collectionView registerClass:[SearchPadCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
}

-(void)UISetup {
    CGRect screenFrame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    //1. Navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 20.0, screenFrame.size.width, 44.0)];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"CategoriesNavBarImage.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    [self.view addSubview:self.navigationBar];
    
    //NAvigation item
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    self.navigationBar.items = @[navigationItem];
    
    //Add the spinner to the navigation bar
    UIBarButtonItem *spinnerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    navigationItem.rightBarButtonItem = spinnerBarButtonItem;
    
    //Search bar background bar image
    UIImageView *searchBarBackgroundBarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height + 1.0, screenFrame.size.width, 42.0)];
    searchBarBackgroundBarImage.image = [UIImage imageNamed:@"SearchBarBackgroundBar.png"];
    [self.view addSubview:searchBarBackgroundBarImage];
    
    //2. SearchBar setup
    self.mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(screenFrame.size.width/2.0 - 200.0, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height + 10.0, 400.0, 28.0)];
    self.mySearchBar.translucent = YES;
    self.mySearchBar.delegate = self;
    self.mySearchBar.backgroundImage = [UIImage imageNamed:@"FondoBarraBusqueda.png"];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"SearchBarPad.png"] forState:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.mySearchBar];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOpacityView)
                                                 name:@"RemoveOpacityView"
                                               object:nil];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
    [self createTapGesture];
}

-(void)createTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}
#pragma mark - UIColelctionViewDataSource 

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.searchResultsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchPadCollectionViewCell *cell = (SearchPadCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];

    NSDictionary *productInfo = self.searchResultsArray[indexPath.item];
    [cell.productionImageView setImageWithURL:[NSURL URLWithString:productInfo[@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    cell.productionNameLabel.text = productInfo[@"name"];
    //cell.productionStarsView.rate = [self.searchResultsArray[indexPath.item][@"rate"] intValue]/20 + 1;
    
    if ([productInfo[@"type"] isEqualToString:@"Películas"] || [productInfo[@"type"] isEqualToString:@"Telenovelas"] || [productInfo[@"type"] isEqualToString:@"Series"]) {
        cell.starsView.alpha = 1.0;
        cell.rate = [productInfo[@"rate"] intValue]/20 + 1;
    } else {
        cell.starsView.alpha = 0.0;
        cell.rate = 0;
    }
    cell.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    return cell;
}

#pragma mark - UICollectionViewDelegate 

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    
    if ([self.searchResultsArray[indexPath.item][@"type"] isEqualToString:@"Películas"] || [self.searchResultsArray[indexPath.item][@"type"] isEqualToString:@"Eventos en vivo"]) {
        [self showOpacityView];
        
        MovieDetailsPadViewController *movieDetailsPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
        movieDetailsPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        movieDetailsPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        movieDetailsPadVC.productID = self.searchResultsArray[indexPath.item][@"id"];
        [self presentViewController:movieDetailsPadVC animated:YES completion:nil];
        NSLog(@"peliculas");
        
    } else if ([self.searchResultsArray[indexPath.item][@"type"] isEqualToString:@"Series"] || [self.searchResultsArray[indexPath.item][@"type"] isEqualToString:@"Telenovelas"] || [self.searchResultsArray[indexPath.item][@"type"] isEqualToString:@"Noticias"]) {
        [self showOpacityView];
        
        SeriesDetailPadViewController *seriesDetailPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
        seriesDetailPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        seriesDetailPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        seriesDetailPadVC.productID = self.searchResultsArray[indexPath.item][@"id"];
        [self presentViewController:seriesDetailPadVC animated:YES completion:nil];
        NSLog(@"series");
    }
}

#pragma mark - Custom methods
-(void)showOpacityView {
    self.opacityView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    //self.opacityView.image = [UIImage imageNamed:@"OpacityBackground.png"];
    self.opacityView.backgroundColor = [UIColor whiteColor];
    self.opacityView.alpha = 0.3;
    [self.tabBarController.view addSubview:self.opacityView];
}

#pragma mark - Actions

-(void)hideSearchKeyboard {
    [self.mySearchBar resignFirstResponder];
}

#pragma mark - Server Stuff

-(void)getSearchResultsFromServer {
    [self.searchResultsArray removeAllObjects];
    [self.searchResultsArrayWithNulls removeAllObjects];
    [self.collectionView reloadData];
    
    NSLog(@"llamé al server");
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetListFromSearchWithKey" andParameter:self.mySearchBar.text];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    if ([methodName isEqualToString:@"GetListFromSearchWithKey"] && responseDictionary) {
        NSLog(@"La petición fue exitosa: %@", responseDictionary);
        self.searchResultsArrayWithNulls = [NSMutableArray arrayWithArray:responseDictionary[@"products"]];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    NSLog(@"server error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handlers

-(void)removeOpacityView {
    [self.opacityView removeFromSuperview];
}

#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Cambió el texto de la barra de búsqueda");
    [self.timer invalidate];
    if ([searchBar.text length] > 0) {
        [self.spinner startAnimating];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(getSearchResultsFromServer) userInfo:nil repeats:NO];
    } else {
        [self.searchResultsArrayWithNulls removeAllObjects];
        [self.searchResultsArray removeAllObjects];
        [self.spinner stopAnimating];
        [self.collectionView reloadData];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
