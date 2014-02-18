//
//  MoviesViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ProductionsListViewController.h"
#import "JMImageCache.h"

static NSString *cellIdentifier = @"CellIdentifier";

@interface ProductionsListViewController ()
@property (strong, nonatomic) NSArray *moviesArray;
@property (strong, nonatomic) NSArray *productionsArray;
@end

@implementation ProductionsListViewController

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
                                @"id" : @"481233", @"category_id" : @"21232", @"image_url" : @"http://compass-images-1.comcast.net/ccp_img/pkr_prod/VMS_POC_Image_Ingest/9/258/escobar_el_patron_del_mal_21_3000x1500_16613258.jpg"}];
    }
    return _productionsArray;
}

-(void)UISetup {
    
    /*-----------------------------------------------------------*/
    //1. Create Button to filter the movies
    UIButton *filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,
                                                                        0.0,
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
    self.navigationItem.title = self.navigationBarTitle;
    [self UISetup];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.productionsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoviesTableViewCell *productionCell = (MoviesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!productionCell) {
        productionCell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    productionCell.movieTitleLabel.text = self.productionsArray[indexPath.row][@"name"];
    NSURL *productionImageURL = [NSURL URLWithString:self.productionsArray[indexPath.row][@"image_url"]];
    [productionCell.movieImageView setImageWithURL:productionImageURL placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    productionCell.stars = [self.productionsArray[indexPath.row][@"rate"] intValue];
    productionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return productionCell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Peliculas"]) {
        MoviesEventsDetailsViewController *movieAndEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
        [self.navigationController pushViewController:movieAndEventDetailsVC animated:YES];
    }
    else if ([self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Series"]) {
        TelenovelSeriesDetailViewController *telenovelSeriesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
        [self.navigationController pushViewController:telenovelSeriesVC animated:YES];
    }
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
