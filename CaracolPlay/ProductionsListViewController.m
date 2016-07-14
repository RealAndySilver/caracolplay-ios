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
#import "MBProgressHUD.h"
#import "MyListsPadTableViewCell.h"
#import "Video.h"
#import "VideoPlayerViewController.h"

static NSString *cellIdentifier = @"CellIdentifier";

@interface ProductionsListViewController () <ServerCommunicatorDelegate, TelenovelSeriesDetailDelegate, MoviesDocumentariesDetailDelegate>
@property (strong, nonatomic) NSArray *moviesArray;
@property (strong, nonatomic) NSMutableArray *removedProductions;
@property (strong, nonatomic) NSArray *unparsedProductionsArray;
@property (strong, nonatomic) NSMutableArray *productionsArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *selectedEpisodeID;
@end

@implementation ProductionsListViewController

#pragma mark - Setters & Getters

-(NSMutableArray *)productionsArray {
    if (!_productionsArray) {
        _productionsArray = [[NSMutableArray alloc] init];
    }
    return _productionsArray;
}

-(void)setUnparsedProductionsArray:(NSArray *)unparsedProductionsArray {
    _unparsedProductionsArray = unparsedProductionsArray;
    self.productionsArray = [_unparsedProductionsArray arrayByReplacingNullsWithBlanks].mutableCopy;
    [self.tableView reloadData];
}

#pragma mark - UISetup

-(void)UISetup {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    if (![self.categoryID isEqualToString:@"1"] && ![self.categoryID isEqualToString:@"2"]) {
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Lo Último", @"+Visto", @"+Votado", @"Todo"]];
        segmentedControl.frame = CGRectMake(20.0, 10.0, self.view.bounds.size.width - 40.0, 29.0);
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.tintColor = [UIColor whiteColor];
        [segmentedControl addTarget:self action:@selector(sortProductionList:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:segmentedControl];
        
        self.tableView.frame = CGRectMake(0.0,
                                          segmentedControl.frame.origin.y + segmentedControl.frame.size.height + 10.0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height - (segmentedControl.frame.origin.y + segmentedControl.frame.size.height) - 44.0 - 64.0 - 15.0);
    } else {
        self.tableView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0 - 64.0);
    }
    
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    self.tableView.rowHeight = 140.0;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.removedProductions = [[NSMutableArray alloc] init];
    [self UISetup];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = self.navigationBarTitle;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eraseLastSeenCategory)
                                                 name:@"EraseLastSeenCategory"
                                               object:nil];
    
    if ([self.categoryID isEqualToString:@"1"]) {
        [self getUserRecentlyWatchedWithFilter:1];
    }
    
    else if ([self.categoryID isEqualToString:@"2"]) {
        [self getUserList];
        
    } else {
        [self getListFromCategoryID:self.categoryID withFilter:1];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.productionsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ///////////////////////////////////////////////////////////////////
    //'Vistos Recientemente'
    if ([self.categoryID isEqualToString:@"1"]) {
        NSDictionary *productDic = self.productionsArray[indexPath.row];
        MyListsPadTableViewCell *cell = (MyListsPadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MyListsPadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height)];
            selectedView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
            cell.selectedBackgroundView = selectedView;

        }
        cell.productionNameLabel.text = productDic[@"product_name"];
        if (![productDic[@"type"] isEqualToString:@"Noticias"] && ![productDic[@"type"] isEqualToString:@"Eventos en vivo"] && ![productDic[@"type"] isEqualToString:@"Telenovelas"] && ![productDic[@"type"] isEqualToString:@"Series"] && ![productDic[@"type"] isEqualToString:@"Películas"] && ![productDic[@"type"] isEqualToString:@"Documentales"]) {
            
            cell.productionDetailLabel.text = [NSString stringWithFormat:@"Capítulo %@: %@", productDic[@"episode_number"], productDic[@"episode_name"]];
        } else {
            if ([productDic[@"type"] isEqualToString:@"Películas"] || [productDic[@"type"] isEqualToString:@"Documentales"] || [productDic[@"type"] isEqualToString:@"Noticias"] || [productDic[@"type"] isEqualToString:@"Eventos en vivo"]) {
                cell.productionDetailLabel.text = @"";
            } else {
                cell.productionDetailLabel.text = [NSString stringWithFormat:@"Capítulo %@: %@", productDic[@"episode_number"], productDic[@"episode_name"]];
            }
        }
        
        
        [cell.productionImageView setImageWithURL:[NSURL URLWithString:self.productionsArray[indexPath.row][@"image_url"] ] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
        return cell;
        
    /////////////////////////////////////////////////////////////////////////////////
    //Other type of categories ('Noticias', 'Telenovelas', etc)
    } else {
        MoviesTableViewCell *productionCell = (MoviesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (productionCell==nil) {
            productionCell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            productionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, productionCell.contentView.bounds.size.width, productionCell.contentView.bounds.size.height)];
            selectedView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
            productionCell.selectedBackgroundView = selectedView;
        }
        
        if ([self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Noticias"] || [self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Eventos en vivo"]) {
            productionCell.starsView.alpha = 0.0;
            productionCell.stars = 0;
        } else {
            productionCell.starsView.alpha = 1.0;
            productionCell.stars = [self.productionsArray[indexPath.row][@"rate"] intValue]/20 + 1;
        }
        productionCell.movieTitleLabel.text = self.productionsArray[indexPath.row][@"name"];
        [productionCell.movieImageView setImageWithURL:[NSURL URLWithString:self.productionsArray[indexPath.row][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
        
        if ([self.productionsArray[indexPath.row][@"free"] isEqualToString:@"1"]) {
            productionCell.freeImageView.image = [UIImage imageNamed:@"FreeBand.png"];
        } else {
            productionCell.freeImageView.image = nil;
        }
        return productionCell;
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.categoryID isEqualToString:@"1"]) {
        [self getIsContentAvailableForUserWithID:self.productionsArray[indexPath.row][@"id"]];
        self.selectedEpisodeID = self.productionsArray[indexPath.row][@"id"];
        return;
    }
    
    if ([self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Películas"] || [self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Documentales"] || [self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Eventos en vivo"]) {
        MoviesEventsDetailsViewController *movieAndEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
        movieAndEventDetailsVC.productionID = self.productionsArray[indexPath.row][@"id"];
        movieAndEventDetailsVC.delegate = self;
        [self.navigationController pushViewController:movieAndEventDetailsVC animated:YES];
    }
    else if ([self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Series"] || [self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Telenovelas"] || [self.productionsArray[indexPath.row][@"type"] isEqualToString:@"Noticias"]) {
        TelenovelSeriesDetailViewController *telenovelSeriesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
        telenovelSeriesVC.serieID = self.productionsArray[indexPath.row][@"id"];
        telenovelSeriesVC.delegate = self;
        [self.navigationController pushViewController:telenovelSeriesVC animated:YES];
    }
}

#pragma mark - Actions 

-(void)sortProductionList:(UISegmentedControl *)segmentedControl {
    //We add 1 to the filter number because if the user selects the number 1 segment
    //of the segmented control (+visto), ths filter is the number 2 in the server.
    [self getListFromCategoryID:self.categoryID withFilter:segmentedControl.selectedSegmentIndex + 1];
}

#pragma mark - Custom Methods

-(void)checkVideoAvailability:(Video *)video {
    if (video.status) {
        //The video is available for the user, so check the network connection to decide
        //if the user can pass to watch it or not.
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        if (status == NotReachable) {
            //The user can't watch the video
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No te encuentras conectado a internet. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        } else if (status == ReachableViaWWAN) {
            if (video.is3G) {
                //The user can watch it with 3G
                [[[UIAlertView alloc] initWithTitle:nil message:@"Para una mejor experiencia, se recomienda usar una conexión Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                VideoPlayerViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                videoPlayer.embedCode = video.embedHD;
                videoPlayer.productID = self.selectedEpisodeID;
                videoPlayer.progressSec = video.progressSec;
                [self.navigationController pushViewController:videoPlayer animated:YES];
            } else {
                //The user can't watch the video because the connection is to slow
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Para ver este contenido conéctese a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else if (status == ReachableViaWiFi) {
            //The user can watch the video
            VideoPlayerViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.embedCode = video.embedHD;
            videoPlayer.progressSec = video.progressSec;
            videoPlayer.productID = self.selectedEpisodeID;
            [self.navigationController pushViewController:videoPlayer animated:YES];
        }
        
    } else {
        //The video is not available for the user, so pass to the
        //Content not available for user
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"En este momento no se puede acceder al video. Intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        /*ContentNotAvailableForUserViewController *contentNotAvailableForUser =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUser"];
        contentNotAvailableForUser.productID = self.selectedEpisodeID;
        contentNotAvailableForUser.productName = self.production.name;
        contentNotAvailableForUser.productType = self.production.type;
        [self.navigationController pushViewController:contentNotAvailableForUser animated:YES];*/
    }
}

#pragma mark - Server Stuff

-(void)getUserList {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"my_list/get" andParameter:@""];
}

-(void)getIsContentAvailableForUserWithID:(NSString *)episodeID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:[NSString stringWithFormat:@"%@", episodeID]];
}

-(void)getUserRecentlyWatchedWithFilter:(NSUInteger)filter {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetUserRecentlyWatched" andParameter:@""];
}

-(void)getListFromCategoryID:(NSString *)categoryID withFilter:(NSInteger)filter {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetListFromCategoryID" andParameter:[NSString stringWithFormat:@"%@/%d", categoryID, filter]];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSLog(@"Recibí info del servidor");
    if ([methodName isEqualToString:@"GetListFromCategoryID"] && responseDictionary) {
        NSLog(@"category list: %@", responseDictionary);
        self.unparsedProductionsArray = responseDictionary[@"products"];
    
    } else if ([methodName isEqualToString:@"GetUserRecentlyWatched"]) {
        NSLog(@"Respuesta de GetUserRencetlyWatched: %@", responseDictionary);
        self.unparsedProductionsArray = (NSArray *)responseDictionary;
    
    } else if ([methodName isEqualToString:@"IsContentAvailableForUser"] && [responseDictionary[@"status"] boolValue]) {
        //La petición fue exitosa
        NSLog(@"info del video: %@", responseDictionary);
        NSDictionary *dicWithoutNulls = [responseDictionary dictionaryByReplacingNullWithBlanks];
        Video *video = [[Video alloc] initWithDictionary:dicWithoutNulls[@"video"]];
        [self checkVideoAvailability:video];
        
    } else if ([methodName isEqualToString:@"my_list/get"]) {
        if (responseDictionary) {
            NSLog(@"Respuesta del get my list: %@", responseDictionary);
            if ([responseDictionary[@"status"] boolValue]) {
                self.unparsedProductionsArray = responseDictionary[@"my_list"];
                
            } else {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Hubo un error accediendo a tu lista, por favor intenta de nuevo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Hubo un error en el servidor. Por favor intenta de nuevo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
    } else {
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSLog(@"server errror: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - MovieEventDetailsDelegate

-(void)movieRemovedWithId:(NSString *)productionId {
    int indexToRemove = -1;
    for (int i = 0; i < self.productionsArray.count; i++) {
        NSDictionary *productDict = self.productionsArray[i];
        if ([productDict[@"id"] isEqualToString:productionId]) {
            indexToRemove = i;
            [self.removedProductions addObject:productDict];
            break;
        }
    }
    if (indexToRemove != -1) {
        [self.productionsArray removeObjectAtIndex:indexToRemove];
        [self.tableView reloadData];
    }
}

-(void)movieAddedToMyListWithId:(NSString *)productionId {
    int indexToAdd = -1;
    for (int i = 0; i < self.removedProductions.count; i++) {
        NSDictionary *productDict = self.removedProductions[i];
        if ([productDict[@"id"] isEqualToString:productionId]) {
            indexToAdd = i;
            break;
        }
    }
    if (indexToAdd != -1) {
        [self.productionsArray addObject:self.removedProductions[indexToAdd]];
        [self.tableView reloadData];
    }
}

#pragma mark - TelenovelSeriesDelegate

-(void)productionAddedToMyListWithId:(NSString *)addedProductionId {
    int indexToAdd = -1;
    for (int i = 0; i < self.removedProductions.count; i++) {
        NSDictionary *productDict = self.removedProductions[i];
        if ([productDict[@"id"] isEqualToString:addedProductionId]) {
            indexToAdd = i;
            break;
        }
    }
    if (indexToAdd != -1) {
        [self.productionsArray addObject:self.removedProductions[indexToAdd]];
        [self.tableView reloadData];
    }
}

-(void)productionRemovedWithId:(NSString *)removedProductionId {
    int indexToRemove = -1;
    for (int i = 0; i < self.productionsArray.count; i++) {
        NSDictionary *productDict = self.productionsArray[i];
        if ([productDict[@"id"] isEqualToString:removedProductionId]) {
            indexToRemove = i;
            [self.removedProductions addObject:productDict];
            break;
        }
    }
    if (indexToRemove != -1) {
        [self.productionsArray removeObjectAtIndex:indexToRemove];
        [self.tableView reloadData];
    }
}

#pragma mark - Notification Handlers 

-(void)eraseLastSeenCategory {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
