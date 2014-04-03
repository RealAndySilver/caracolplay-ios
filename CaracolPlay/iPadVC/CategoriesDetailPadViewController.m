//
//  CategoriesDetailPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 11/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

NSString *const splitCollectionViewCellIdentifier = @"CellIdentifier";

#import "CategoriesDetailPadViewController.h"
#import "ProductionsPadCollectionViewCell.h"
#import "SeriesDetailPadViewController.h"
#import "MovieDetailsPadViewController.h"
#import "JMImageCache.h"
#import "ServerCommunicator.h"
#import "NSArray+NullReplacement.h"

@interface CategoriesDetailPadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIBarPositioningDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *unparsedProductionsArray;
@property (strong, nonatomic) NSArray *productionsArray;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation CategoriesDetailPadViewController

#pragma mark - Lazy Instantiation

-(NSArray *)productionsArray {
    if (!_productionsArray) {
        _productionsArray = [[NSArray alloc] init];
    }
    return _productionsArray;
}

-(void)setUnparsedProductionsArray:(NSArray *)unparsedProductionsArray {
    _unparsedProductionsArray = unparsedProductionsArray;
    self.productionsArray = [_unparsedProductionsArray arrayByReplacingNullsWithBlanks];
    [self.collectionView reloadData];
}

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(300.0 - 20.0, self.view.bounds.size.height/2.0 - 20.0, 40.0, 40.0);
    }
    return _spinner;
}

-(void)UISetup {
    
    //1. NavigationBar
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarDetail.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    //2. Segmented Control
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Lo último", @"Lo mas visto", @"Lo mas votado", @"Nombre"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.segmentedControl];
    
    //3. CollectionView
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewFlowLayout];
    [self.collectionView registerClass:[ProductionsPadCollectionViewCell class] forCellWithReuseIdentifier:splitCollectionViewCellIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    [self.view addSubview:self.spinner];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(categoryIDNotificationReceived:)
                                                 name:@"CategoryIDNotification"
                                               object:nil];
    //[self getListFromCategoryID:self.categoryID withFilter:0];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.segmentedControl.frame = CGRectMake(self.view.bounds.size.width/2 - 200.0, 80.0, 400.0, 29.0);
    self.collectionView.frame = CGRectMake(20.0, 120.0, self.view.bounds.size.width - 40.0, self.view.bounds.size.height - 120.0);
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.productionsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductionsPadCollectionViewCell *cell = (ProductionsPadCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:splitCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell.productionImageView setImageWithURL:[NSURL URLWithString:self.productionsArray[indexPath.item][@"image_url"]]
                                  placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    cell.goldStars = [self.productionsArray[indexPath.item][@"rate"] intValue];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150.0, 250.0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.productionsArray[indexPath.item][@"type"] isEqualToString:@"Series"]) {
        SeriesDetailPadViewController *seriesDetailPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
        seriesDetailPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        seriesDetailPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:seriesDetailPadVC animated:YES completion:nil];
        
    } else if ([self.productionsArray[indexPath.item][@"type"] isEqualToString:@"Peliculas"]) {
        MovieDetailsPadViewController *movieDetailsPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
        movieDetailsPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        movieDetailsPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:movieDetailsPadVC animated:YES completion:nil];
    }
}

#pragma mark - Server Stuff

-(void)getListFromCategoryID:(NSString *)categoryID withFilter:(NSInteger)filter {
    NSLog(@"llamaré al server");
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"%@/%d", self.categoryID, filter];
    NSLog(@"parametros: %@", parameters);
    [serverCommunicator callServerWithGETMethod:@"GetListFromCategoryID" andParameter:parameters];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    if ([methodName isEqualToString:@"GetListFromCategoryID"] && [responseDictionary[@"status"] boolValue]) {
        NSLog(@"la peticion del listado de categorías fue exitosa: %@", responseDictionary);
        self.unparsedProductionsArray = responseDictionary[@"products"];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error al conectarse con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handlers 

-(void)categoryIDNotificationReceived:(NSNotification *)notification {
    NSLog(@"recibí la notificación");
    NSDictionary *notificationDic = [notification userInfo];
    NSString *categoryID = notificationDic[@"CategoryID"];
    [self getListFromCategoryID:categoryID withFilter:0];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
