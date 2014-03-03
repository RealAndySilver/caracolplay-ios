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

@interface SearchPadViewController () < UIBarPositioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *searchResultsArray;
@end

@implementation SearchPadViewController

#pragma mark - Lazy Instantiation 

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
    CGRect screenFrame = CGRectMake(0.0, 0.0, 1024.0, 768.0);
    //1. Navigation bar setup
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 20.0, screenFrame.size.width, 44.0)];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"CategoriesNavBarImage.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    [self.view addSubview:self.navigationBar];
    
    //2. SearchBar setup
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10.0, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height + 10.0, screenFrame.size.width - 10.0, 30.0)];
    self.searchBar.translucent = YES;
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"SearchBarPad.png"] forState:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    self.searchBar.backgroundImage = [UIImage imageNamed:@"FondoBarraBusqueda.png"];
    [self.view addSubview:self.searchBar];
    
    //3. Collection view
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.itemSize = CGSizeMake(320.0, 130.0);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.searchBar.frame.origin.y + self.searchBar.frame.size.height + 10.0, screenFrame.size.width, screenFrame.size.height - (self.searchBar.frame.origin.y + self.searchBar.frame.size.height + 20.0) - 64.0)collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    [self.collectionView registerClass:[SearchPadCollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    self.collectionView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

#pragma mark - UIColelctionViewDataSource 

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.searchResultsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchPadCollectionViewCell *cell = (SearchPadCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    [cell.productionImageView setImageWithURL:[NSURL URLWithString:self.searchResultsArray[indexPath.item][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    cell.productionNameLabel.text = self.searchResultsArray[indexPath.item][@"name"];
    cell.productionStarsView.rate = [self.searchResultsArray[indexPath.item][@"rate"] intValue];
    cell.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    return cell;
}

#pragma mark - UICollectionViewDelegate 

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchResultsArray[indexPath.item][@"type"] isEqualToString:@"Peliculas"]) {
        MovieDetailsPadViewController *movieDetailsPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
        movieDetailsPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        movieDetailsPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:movieDetailsPadVC animated:YES completion:nil];
        NSLog(@"peliculas");
        
    } else if ([self.searchResultsArray[indexPath.item][@"type"] isEqualToString:@"Series"]) {
        SeriesDetailPadViewController *seriesDetailPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
        seriesDetailPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        seriesDetailPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:seriesDetailPadVC animated:YES completion:nil];
        NSLog(@"series");
    }
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
