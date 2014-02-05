//
//  CategoriesPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CategoriesPadViewController.h"
#import "ProductionsPadCollectionViewCell.h"
#import "CategoriesPopoverViewController.h"
#import "MovieDetailsPadViewController.h"

NSString *const collectionViewCellIdentifier = @"CellIdentifier";

@interface CategoriesPadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIBarPositioningDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIBarButtonItem *barButtonItem;
@property (strong, nonatomic) UIPopoverController *categoriesPopover;
@end

@implementation CategoriesPadViewController

-(void)UISetup {
    
    //1. NavigationBar
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 20.0, 1024.0, 44.0)];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"CategoriesNavBarImage.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    //2. Segmented Control
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Lo último", @"Lo mas visto", @"Lo mas votado", @"Todo"]];
    self.segmentedControl.frame = CGRectMake(1024.0/2.0 - 200.0, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height + 20.0, 400.0, 29.0);
    [self.view addSubview:self.segmentedControl];
    
    //3. CollectionView
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(20.0, self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height + 60.0, 1024.0 - 40.0, 768.0 - 60.0) collectionViewLayout:collectionViewFlowLayout];
    [self.collectionView registerClass:[ProductionsPadCollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    //Create a bar button item to display the productins type list
    self.barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Categorías"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(showCategoriesPopoverView)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
    navigationItem.leftBarButtonItem = self.barButtonItem;
    self.navigationBar.items = @[navigationItem];
    
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self UISetup];
}

#pragma mark - Actions

-(void)showCategoriesPopoverView {
    
    if (![self.categoriesPopover isPopoverVisible]) {
        CategoriesPopoverViewController *categoriesPopoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoriesPopover"];
        self.categoriesPopover = [[UIPopoverController alloc] initWithContentViewController:categoriesPopoverVC];
        [self.categoriesPopover presentPopoverFromBarButtonItem:self.barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self.categoriesPopover dismissPopoverAnimated:YES];
    }
}

#pragma mark - UICollectionViewDataSource 

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 15;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductionsPadCollectionViewCell *cell = (ProductionsPadCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellIdentifier forIndexPath:indexPath];
    cell.productionImageView.image = [UIImage imageNamed:@"MentirasPerfectas2.jpg"];
    cell.goldStars = 3;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150.0, 250.0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieDetailsPadViewController *movieDetailsPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
    movieDetailsPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:movieDetailsPadVC animated:YES completion:nil];
}

#pragma mark - UIBarPositinDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
