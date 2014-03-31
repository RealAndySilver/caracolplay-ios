//
//  MoviesViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ProductionsListViewController.h"
#import "JMImageCache.h"
#import "ServerCommunicator.h"
#import "NSDictionary+NullReplacement.h"
#import "NSArray+NullReplacement.h"
#import "MBHUDView.h"

static NSString *cellIdentifier = @"CellIdentifier";

@interface ProductionsListViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) NSArray *moviesArray;
@property (strong, nonatomic) NSArray *unparsedProductionsArray;
@property (strong, nonatomic) NSArray *productionsArray;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation ProductionsListViewController

#pragma mark - Setters & Getters

/*-(NSArray *)productionsArray {
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
}*/

-(NSArray *)productionsArray {
    if (!_productionsArray) {
        _productionsArray = [[NSArray alloc] init];
    }
    return _productionsArray;
}

-(void)setUnparsedProductionsArray:(NSArray *)unparsedProductionsArray {
    _unparsedProductionsArray = unparsedProductionsArray;
    self.productionsArray = [_unparsedProductionsArray arrayByReplacingNullsWithBlanks];
    [self.tableView reloadData];
}

#pragma mark - UISetup

-(void)UISetup {
    
    /*-----------------------------------------------------------*/
    //1. Create Button to filter the movies
    /*UIButton *filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0,
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
    [self.view addSubview:filterButton];*/
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Lo Último", @"+Visto", @"+Votado", @"Nombre"]];
    segmentedControl.frame = CGRectMake(20.0, 10.0, self.view.bounds.size.width - 40.0, 29.0);
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [UIColor whiteColor];
    [segmentedControl addTarget:self action:@selector(sortProductionList:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    //3. Create the table view to display the movies
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                           segmentedControl.frame.origin.y + segmentedControl.frame.size.height + 10.0,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height - (segmentedControl.frame.origin.y + segmentedControl.frame.size.height) - 44.0 - 64.0 - 20.0)
                                                          style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    self.tableView.rowHeight = 140.0;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = self.navigationBarTitle;
    [self getListFromCategoryID:self.categoryID withFilter:1];
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
    productionCell.stars = [self.productionsArray[indexPath.row][@"rate"] intValue]/20;
    productionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return productionCell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Películas"] || [self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Noticias"]) {
        MoviesEventsDetailsViewController *movieAndEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
        movieAndEventDetailsVC.productionID = self.productionsArray[indexPath.row][@"id"];
        [self.navigationController pushViewController:movieAndEventDetailsVC animated:YES];
    }
    else if ([self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Series"] || [self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Telenovelas"]) {
        TelenovelSeriesDetailViewController *telenovelSeriesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
        telenovelSeriesVC.serieID = self.productionsArray[indexPath.row][@"id"];
        [self.navigationController pushViewController:telenovelSeriesVC animated:YES];
    }
}

#pragma mark - Actions 

-(void)sortProductionList:(UISegmentedControl *)segmentedControl {
    //We add 1 to the filter number because if the user selects the number 1 segment
    //of the segmented control (+visto), ths filter is the number 2 in the server.
    [self getListFromCategoryID:self.categoryID withFilter:segmentedControl.selectedSegmentIndex + 1];
}

#pragma mark - Server Stuff

-(void)getListFromCategoryID:(NSString *)categoryID withFilter:(NSInteger)filter {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Cargando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [serverCommunicator callServerWithGETMethod:@"GetListFromCategoryID" andParameter:[NSString stringWithFormat:@"%@/%d", categoryID, filter]];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
#warning aquí hay un log de tal cosa
    NSLog(@"Recibí info del servidor");
    if ([methodName isEqualToString:@"GetListFromCategoryID"] && [responseDictionary[@"status"] boolValue]) {
        self.unparsedProductionsArray = responseDictionary[@"products"];
    
    } else {
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conetándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
#warning Aquí hay un log
    NSLog(@"server errror: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conetándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
