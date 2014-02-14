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

@interface CategoriesDetailPadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIBarPositioningDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *productionsArray;
@end

@implementation CategoriesDetailPadViewController

#pragma mark - Lazy Instantiation

-(NSArray *)productionsArray {
    if (!_productionsArray) {
        _productionsArray = @[@{@"name": @"Mentiras Perfectas", @"type" : @"Series", @"feature_text" : @"No te pierda...", @"rate" : @4,
                                @"id" : @"48393", @"category_id" : @"23432", @"image_url" : @"http://www.mundonets.com/images/johanna-cruz-laura-ramos.jpg"},
                              
                              @{@"name": @"Colombia's Next Top Model", @"type" : @"Peliculas", @"feature_text" : @"No te pierda...", @"rate" : @5,
                                @"id" : @"481233", @"category_id" : @"21232", @"image_url" : @"http://static.cromos.com.co/sites/cromos.com.co/files/images/2013/01/ba6538c2bf4d087330be745adfa8d0bd.jpg"},
                              
                              @{@"name": @"Yo me llamo", @"type" : @"Peliculas", @"feature_text" : @"No te pierda...", @"rate" : @1,
                                @"id" : @"481233", @"category_id" : @"21232", @"image_url" : @"http://www.cartagenacity.co/sites/default/files/field/image/yo-me-llamo.jpg"},
                              
                              @{@"name": @"Escobar, el patrón del mal", @"type" : @"Peliculas", @"feature_text" : @"No te pierda...", @"rate" : @3,
                                @"id" : @"481233", @"category_id" : @"21232", @"image_url" : @"http://compass-images-1.comcast.net/ccp_img/pkr_prod/VMS_POC_Image_Ingest/9/258/escobar_el_patron_del_mal_21_3000x1500_16613258.jpg"},
                              
                              @{@"name": @"Escobar, el patrón del mal", @"type" : @"Peliculas", @"feature_text" : @"No te pierda...", @"rate" : @3,
                                @"id" : @"481233", @"category_id" : @"21232", @"image_url" : @"http://static.canalcaracol.com/sites/caracoltv.com/files/imgs_12801024/fdb9f15a1610815e39b2dcbb298e223f.jpg"},
                              
                              @{@"name": @"Escobar, el patrón del mal", @"type" : @"Peliculas", @"feature_text" : @"No te pierda...", @"rate" : @3,
                                @"id" : @"481233", @"category_id" : @"21232", @"image_url" : @"http://www.eldiario.com.co/uploads/userfiles/20100704/image/monica_alta%5B1%5D-copia.jpg"},
                              
                              @{@"name": @"Escobar, el patrón del mal", @"type" : @"Peliculas", @"feature_text" : @"No te pierda...", @"rate" : @3,
                                @"id" : @"481233", @"category_id" : @"21232", @"image_url" : @"http://1.bp.blogspot.com/-5SeBwwOE0ak/T_4HH5Wj1YI/AAAAAAAAHw8/1aYXf8zxUNo/s1600/Stephanie%2BCayo%2BBLOG.png"},
                              
                              @{@"name": @"Escobar, el patrón del mal", @"type" : @"Peliculas", @"feature_text" : @"No te pierda...", @"rate" : @3,
                                @"id" : @"481233", @"category_id" : @"21232", @"image_url" : @"http://p1.trrsf.com/image/fget/cf/619/464/images.terra.com/2013/06/12/seleccion-5.jpg"},];
    }
    return _productionsArray;
}


-(void)UISetup {
    
    //1. NavigationBar
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarDetail.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    //2. Segmented Control
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Lo último", @"Lo mas visto", @"Lo mas votado", @"Todo"]];
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

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
