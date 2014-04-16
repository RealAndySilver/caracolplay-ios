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
#import "NSDictionary+NullReplacement.h"
#import "Video.h"
#import "VideoPlayerPadViewController.h"

@interface CategoriesDetailPadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIBarPositioningDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *unparsedProductionsArray;
@property (strong, nonatomic) NSMutableArray *productionsArray;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSString *selectedEpisodeID;
@end

@implementation CategoriesDetailPadViewController

#pragma mark - Lazy Instantiation

-(void)setCategoryID:(NSString *)categoryID {
    _categoryID = categoryID;
    if ([categoryID isEqualToString:@"1"]) {
        [self getUserRecentlyWatched];
        self.segmentedControl.hidden = YES;
    } else {
        [self getListFromCategoryID:categoryID withFilter:1];
        self.segmentedControl.hidden = NO;
        self.segmentedControl.selectedSegmentIndex = 0;
    }
}

-(NSMutableArray *)productionsArray {
    if (!_productionsArray) {
        _productionsArray = [[NSMutableArray alloc] init];
    }
    return _productionsArray;
}

-(void)setUnparsedProductionsArray:(NSMutableArray *)unparsedProductionsArray {
    _unparsedProductionsArray = unparsedProductionsArray;
    self.productionsArray = [[_unparsedProductionsArray arrayByReplacingNullsWithBlanks] mutableCopy];
    [self.collectionView reloadData];
}

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(320.0 - 20.0, 384 - 20.0, 40.0, 40.0);
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
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Lo último", @"Lo mas visto", @"Lo mas votado", @"Todo"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    [self.segmentedControl addTarget:self action:@selector(changeCategoryFilter) forControlEvents:UIControlEventValueChanged];
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
    self.collectionView.frame = CGRectMake(20.0, 120.0, self.view.bounds.size.width - 40.0, self.view.bounds.size.height - 170.0);
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.productionsArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductionsPadCollectionViewCell *cell = (ProductionsPadCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:splitCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell.productionImageView setImageWithURL:[NSURL URLWithString:self.productionsArray[indexPath.item][@"image_url"]]
                                  placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    cell.goldStars = ([self.productionsArray[indexPath.item][@"rate"] intValue]/20) + 1;
    if ([self.productionsArray[indexPath.item][@"free"] isEqualToString:@"1"]) {
        cell.freeImageView.image = [UIImage imageNamed:@"FreeBand.png"];
    } else {
        cell.freeImageView.image = nil;
    }
    NSLog(@"la celda %d tiene %d estrellas", indexPath.item, cell.goldStars);
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150.0, 250.0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.categoryID isEqualToString:@"1"]) {
        [self getIsContentAvailableForUserWithID:self.productionsArray[indexPath.row][@"id"]];
        self.selectedEpisodeID = self.productionsArray[indexPath.row][@"id"];
        return;
    }
    
    if ([self.productionsArray[indexPath.item][@"type"] isEqualToString:@"Series"] || [self.productionsArray[indexPath.item][@"type"] isEqualToString:@"Telenovelas"]) {
        SeriesDetailPadViewController *seriesDetailPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
        seriesDetailPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        seriesDetailPadVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        seriesDetailPadVC.productID = self.productionsArray[indexPath.item][@"id"];
        [self presentViewController:seriesDetailPadVC animated:YES completion:nil];
        
    } else if ([self.productionsArray[indexPath.item][@"type"] isEqualToString:@"Películas"] || [self.productionsArray[indexPath.item][@"type"] isEqualToString:@"Noticias"] || [self.productionsArray[indexPath.item][@"type"] isEqualToString:@"Eventos en vivo"]) {
        MovieDetailsPadViewController *movieDetailsPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
        movieDetailsPadVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        movieDetailsPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        movieDetailsPadVC.productID = self.productionsArray[indexPath.item][@"id"];
        [self presentViewController:movieDetailsPadVC animated:YES completion:nil];
    }
}

#pragma mark - Actions 

-(void)changeCategoryFilter {
    [self.productionsArray removeAllObjects];
    [self.collectionView reloadData];
    [self getListFromCategoryID:self.categoryID withFilter:self.segmentedControl.selectedSegmentIndex+1];
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
                [[[UIAlertView alloc] initWithTitle:nil message:@"Para una mejor experiencia, se recomienda usar una coenxión Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                videoPlayer.embedCode = video.embedHD;
                videoPlayer.productID = self.selectedEpisodeID;
                videoPlayer.progressSec = video.progressSec;
                [self presentViewController:videoPlayer animated:YES completion:nil];
            } else {
                //The user can't watch the video because the connection is to slow
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Para ver este contenido conéctese a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else if (status == ReachableViaWiFi) {
            //The user can watch the video
            VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.embedCode = video.embedHD;
            videoPlayer.progressSec = video.progressSec;
            videoPlayer.productID = self.selectedEpisodeID;
            [self presentViewController:videoPlayer animated:YES completion:nil];
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

-(void)getIsContentAvailableForUserWithID:(NSString *)episodeID {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:episodeID];
}

-(void)getUserRecentlyWatched {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetUserRecentlyWatched" andParameter:@""];
}

-(void)getListFromCategoryID:(NSString *)categoryID withFilter:(NSInteger)filter {
    NSLog(@"llamaré al server");
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"%@/%d", categoryID, filter];
    NSLog(@"parametros: %@", parameters);
    [serverCommunicator callServerWithGETMethod:@"GetListFromCategoryID" andParameter:parameters];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    if ([methodName isEqualToString:@"GetListFromCategoryID"] && responseDictionary) {
        //NSLog(@"la peticion del listado de categorías fue exitosa: %@", responseDictionary);
        self.unparsedProductionsArray = responseDictionary[@"products"];
        
    } else if ([methodName isEqualToString:@"GetUserRecentlyWatched"]) {
        self.unparsedProductionsArray = (NSMutableArray *)responseDictionary;
    
    } else if ([methodName isEqualToString:@"IsContentAvailableForUser"] && [responseDictionary[@"status"] boolValue]) {
        //La petición fue exitosa
        NSLog(@"info del video: %@", responseDictionary);
        NSDictionary *dicWithoutNulls = [responseDictionary dictionaryByReplacingNullWithBlanks];
        Video *video = [[Video alloc] initWithDictionary:dicWithoutNulls[@"video"]];
        [self checkVideoAvailability:video];
        
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
    NSDictionary *notificationDic = [notification userInfo];
    NSString *categoryID = notificationDic[@"CategoryID"];
    self.categoryID = categoryID;
    NSLog(@"recibí la notificación con un id de categoria: %@", categoryID);
    if ([self.categoryID isEqualToString:@"1"]) {
        [self getUserRecentlyWatched];
        self.segmentedControl.hidden = YES;
    } else {
        [self getListFromCategoryID:categoryID withFilter:1];
        self.segmentedControl.hidden = NO;
    }
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
