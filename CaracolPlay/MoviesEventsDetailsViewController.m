//
//  MoviesEventsViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MoviesEventsDetailsViewController.h"
#import "TelenovelSeriesDetailViewController.h"
#import "Product.h"
#import "JMImageCache.h"
#import "RateView.h"
#import "LargeProductionImageView.h"
#import "StarsView.h"
#import "Reachability.h"
#import "VideoPlayerViewController.h"
#import "FileSaver.h"
#import "SuscriptionAlertViewController.h"
#import "ContentNotAvailableForUserViewController.h"
#import "ServerCommunicator.h"
#import "Season.h"
#import "Episode.h"
#import "NSDictionary+NullReplacement.h"
#import "Video.h"
#import "MBProgressHUD.h"
#import "UserInfo.h"
#import "NSArray+NullReplacement.h"
#import "SinopsisView.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface MoviesEventsDetailsViewController () <UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, RateViewDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate, SinopsisViewDelegate>
@property (strong, nonatomic) Product *production;
@property (strong, nonatomic) NSDictionary *unparsedProductionInfo;
@property (strong, nonatomic) NSArray *recommendedProductions;
@property (strong, nonatomic) NSArray *recommendedProdWithoutNulls;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) StarsView *starsView;
@property (strong, nonatomic) UIImage *productionImage;

//BOOL that indicates if the view controller received a notification
//indicating that ith has to display the production video automaticly
//when the view appears.
@property (assign, nonatomic) BOOL receivedVideoNotification;

/*@property (strong, nonatomic) FXBlurView *blurView;
@property (strong, nonatomic) FXBlurView *tabBarBlurView;
@property (strong, nonatomic) FXBlurView *navigationBarBlurView;*/
@end

@implementation MoviesEventsDetailsViewController

#pragma mark - Setters & Getters

-(void)setUnparsedProductionInfo:(NSDictionary *)unparsedProductionInfo {
    _unparsedProductionInfo = unparsedProductionInfo;
    NSDictionary *parsedDictionaryWithNulls = [self parseProductionInfoWithDictionary:unparsedProductionInfo];
    NSDictionary *parsedDictionaryWithoutNulls = [parsedDictionaryWithNulls dictionaryByReplacingNullWithBlanks];
    self.production = [[Product alloc] initWithDictionary:parsedDictionaryWithoutNulls];
    [self getRecommendedProductionsForProductID:self.productionID];
    [self UISetup];
}

-(void)setRecommendedProductions:(NSArray *)recommendedProductions {
    _recommendedProductions = recommendedProductions;
    self.recommendedProdWithoutNulls = [recommendedProductions arrayByReplacingNullsWithBlanks];
    [self setupRecommendedProductionsCollectionView];
}

#pragma mark - Parsing Methods

-(NSDictionary *)parseProductionInfoWithDictionary:(NSDictionary *)unparsedDic {
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary:unparsedDic];
    
    //Check if the product has seasons
    if ([unparsedDic[@"has_seasons"] boolValue]) {
        //The product has seasons
        NSLog(@"Si tiene temporadas, no episodios sueltos");
        
        NSArray *unparsedSeasonsArray = [NSArray arrayWithArray:unparsedDic[@"season_list"]];
        NSLog(@"Numero de temporadas: %d", [unparsedSeasonsArray count]);
        NSMutableArray *parsedSeasonsArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [unparsedSeasonsArray count]; i++) {
            NSArray *unparsedEpisodesFromSeason = unparsedSeasonsArray[i][@"episodes"];
            NSLog(@"Numero de episodios en la temporada %d: %d", i+1, [unparsedEpisodesFromSeason count]);
            
            //Create a mutable array to store the Episodes objects that we are going to create
            NSMutableArray *parsedEpisodesFromSeason = [[NSMutableArray alloc] init];
            
            //Loop through all the season episodes.
            for (int i = 0; i < [unparsedEpisodesFromSeason count]; i++) {
                Episode *episode = [[Episode alloc] initWithDictionary:unparsedEpisodesFromSeason[i]];
                [parsedEpisodesFromSeason addObject:episode];
            }
            
            Season *season = [[Season alloc] initWithDictionary:@{@"season_id": unparsedSeasonsArray[i][@"season_id"],
                                                                  @"season_name" : unparsedSeasonsArray[i][@"season_name"],
                                                                  @"episodes" : parsedEpisodesFromSeason}];
            [parsedSeasonsArray addObject:season];
        }
        [newDictionary setObject:parsedSeasonsArray forKey:@"season_list"];
        return newDictionary;
    }
    else {
        //The product has no seasons
        NSLog(@"El producto no tiene temporadas");
        NSDictionary *productionVideoDic = unparsedDic[@"episodes"];
        [newDictionary setObject:productionVideoDic forKey:@"episodes"];
        return newDictionary;
    }
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Add as an observer of the -VideoShouldBeDisplayed notification, to show
    //the production video inmediatly
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoShoulBeDisplayedNotification:)
                                                 name:@"VideoShouldBeDisplayed"
                                               object:nil];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = self.production.type;
    [self getProductWithID:self.productionID];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.receivedVideoNotification) {
        NSLog(@"iré al video de unaaaa");
        [self getIsContentAvailableForUserWithID:self.productionID];
    }
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    //self.navigationBarBlurView.frame = self.navigationController.navigationBar.bounds;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Set this BOOL to NO. This BOOL is set to YES when we received a
    //notification indicating that we have to display the production video
    //automaticly when the view appears.
    self.receivedVideoNotification = NO;
    /*[self.blurView removeFromSuperview];
    [self.navigationBarBlurView removeFromSuperview];
    [self.tabBarBlurView removeFromSuperview];*/
}

#pragma mark - UISetup

-(void)setupRecommendedProductionsCollectionView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    //8. Create a background view and set it's color to gray
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, screenRect.size.height/2.0, screenRect.size.width, screenRect.size.height - 300.0 - 44.0)];
    grayView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    [self.view addSubview:grayView];
    
    //9. 'Producciones recomendadas'
    UILabel *recomendedProductionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 200.0, 20.0)];
    recomendedProductionsLabel.textAlignment = NSTextAlignmentLeft;
    recomendedProductionsLabel.textColor = [UIColor whiteColor];
    recomendedProductionsLabel.font = [UIFont boldSystemFontOfSize:13.0];
    recomendedProductionsLabel.text = @"Producciones Recomendadas";
    [grayView addSubview:recomendedProductionsLabel];
    
    //10. Create a collection view to display a list of recommended productions
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    collectionViewFlowLayout.itemSize = CGSizeMake(100.0, [UIScreen mainScreen].bounds.size.height/4.3);
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 30.0, grayView.frame.size.width, [UIScreen mainScreen].bounds.size.height/4.3) collectionViewLayout:collectionViewFlowLayout];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.dataSource = self;
    [collectionView registerClass:[RecommendedProdCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [grayView addSubview:collectionView];
}

-(void)UISetup {
    self.navigationItem.title = self.production.type;
    
    //1. Create the main image view of the movie/event
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    /*UIImageView *movieEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                                     0.0,
                                                                                     screenFrame.size.width,
                                                                                    screenFrame.size.height/3)];
    movieEventImageView.clipsToBounds = YES;
    movieEventImageView.contentMode = UIViewContentModeScaleAspectFill;
    [movieEventImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    [self.view addSubview:movieEventImageView];
    
    //Create a view with an opacity pattern to apply an opacity to the image
    UIView *opacityPatternView = [[UIView alloc] initWithFrame:movieEventImageView.frame];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"MoviesOpacityPattern.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, movieEventImageView.frame.size.height+5)];
    opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [self.view addSubview:opacityPatternView];*/
    
    //2. Create the secondary image of the movie/event
    
    float y_position;
    if (self.view.frame.size.height>480) {
        y_position = screenFrame.size.height/4.0;
    }
    else{
        y_position = screenFrame.size.height/3.75;
    }
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(10.0,
                                                                 20.0,
                                                                 90.0,
                                                                  y_position)];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    shadowView.layer.shadowOpacity = 0.9;
    shadowView.layer.shadowRadius = 5.0;
    [self.view addSubview:shadowView];
    
    UIImageView *secondaryMovieEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, shadowView.frame.size.width, shadowView.frame.size.height)];
    secondaryMovieEventImageView.clipsToBounds = YES;
    secondaryMovieEventImageView.userInteractionEnabled = YES;
    secondaryMovieEventImageView.contentMode = UIViewContentModeScaleAspectFill;
    [secondaryMovieEventImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    [shadowView addSubview:secondaryMovieEventImageView];
    
    //free band image view
    if ([self.production.free isEqualToString:@"1"]) {
        UIImageView *freeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, secondaryMovieEventImageView.frame.size.height - 15.0, secondaryMovieEventImageView.frame.size.width, 15.0)];
        freeImageView.image = [UIImage imageNamed:@"FreeBand.png"];
        [secondaryMovieEventImageView addSubview:freeImageView];
    }
    
    //Add the play icon into the secondaty image view
    /*UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.size.width/2 - 25.0, secondaryMovieEventImageView.frame.size.height/2 - 25.0, 50.0, 50.0)];
    playIcon.clipsToBounds = YES;
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    playIcon.image = [UIImage imageNamed:@"PlayIconHomeScreen.png"];
    [secondaryMovieEventImageView addSubview:playIcon];*/
    
    //Create a tap gesture and add it to our secondary image view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [secondaryMovieEventImageView addGestureRecognizer:tapGestureRecognizer];
    
    //3. Create the label to display the movie/event name
    UILabel *movieEventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                            20.0,
                                                                             self.view.frame.size.width - 50.0,
                                                                             30.0)];
    movieEventNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    movieEventNameLabel.text = self.production.name;
    movieEventNameLabel.textColor = [UIColor whiteColor];
    movieEventNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:movieEventNameLabel];
    
    //6. Create a button to share the movie/event
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0, screenFrame.size.height/6.3, 190.0, 30.0)];
    [shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"OrangeButton.png"] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    shareButton.layer.shadowColor = [UIColor blackColor].CGColor;
    shareButton.layer.shadowOpacity = 0.8;
    shareButton.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    shareButton.layer.shadowRadius = 5.0;
    [self.view addSubview:shareButton];
    
    //4. Create the stars images
    if (![self.production.type isEqualToString:@"Eventos en vivo"]) {
        //Modify the share button frame
        shareButton.frame = CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 120.0, screenFrame.size.height/6.3, 90.0, 30.0);
        
        //Create the stars
        self.starsView = [[StarsView alloc] initWithFrame:CGRectMake(120.0, 50.0, 100.0, 20.0) rate:[self.production.rate intValue]/20.0 + 1];
        [self.view addSubview:self.starsView];
        [self.view bringSubviewToFront:self.starsView];
        
        //Add a tap gesture to the starView to open the rate view when the user touches the stars
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRateView)];
        [self.starsView addGestureRecognizer:tapGesture];
        
        //Create the watch trailer button
        UIButton *watchTrailerButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                                  screenFrame.size.height/6.3,
                                                                                  90.0,
                                                                                  30.0)];
        [watchTrailerButton setTitle:@"Ver Tráiler" forState:UIControlStateNormal];
        [watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"OrangeButton.png"] forState:UIControlStateNormal];
        [watchTrailerButton addTarget:self action:@selector(watchTrailer) forControlEvents:UIControlEventTouchUpInside];
        [watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        watchTrailerButton.layer.shadowColor = [UIColor blackColor].CGColor;
        watchTrailerButton.layer.shadowOpacity = 0.8;
        watchTrailerButton.layer.shadowOffset = CGSizeMake(4.0, 4.0);
        watchTrailerButton.layer.shadowRadius = 5.0;
        [self.view addSubview:watchTrailerButton];
    }
    
    //Create the button to watch the production
    UIButton *watchProductionButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0, shareButton.frame.origin.y + shareButton.frame.size.height + 10.0, 190.0, 30.0)];
    [watchProductionButton setTitle:@"Ver Producción" forState:UIControlStateNormal];
    [watchProductionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [watchProductionButton setBackgroundImage:[UIImage imageNamed:@"OrangeButton.png"] forState:UIControlStateNormal];
    watchProductionButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [watchProductionButton addTarget:self action:@selector(watchProduction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:watchProductionButton];
    
    //Sinopsis webview
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(10.0, secondaryMovieEventImageView.frame.origin.y + secondaryMovieEventImageView.frame.size.height + 40, screenFrame.size.width - 20.0, screenFrame.size.height/8.7)];
    webView.opaque=NO;
    webView.userInteractionEnabled = NO;
    [webView setBackgroundColor:[UIColor clearColor]];
    NSString *str = [NSString stringWithFormat:@"<html><body style='background-color: transparent; color:white; font-family: helvetica; font-size:14px'>%@</body></html>",self.production.detailDescription];
    [webView loadHTMLString:str baseURL:nil];
    [self.view addSubview:webView];
    
    //"Ver mas" button
    UIButton *moreInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, webView.frame.origin.y + webView.frame.size.height, 70.0, 30.0)];
    [moreInfoButton setTitle:@"Ver más" forState:UIControlStateNormal];
    [moreInfoButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    moreInfoButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [moreInfoButton addTarget:self action:@selector(showMoreInfoView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreInfoButton];
    
    //Add a blur view to display when the user shares the production but an error was produced.
    /*self.blurView = [[FXBlurView alloc] initWithFrame:self.view.frame];
    self.blurView.blurRadius = 7.0;
    self.blurView.alpha = 0.0;
    //[self.view addSubview:self.blurView];
    
    self.tabBarBlurView = [[FXBlurView alloc] initWithFrame:self.tabBarController.tabBar.frame];
    self.tabBarBlurView.alpha = 0.0;
    self.tabBarBlurView.blurRadius = 7.0;
    //[self.tabBarController.view addSubview:self.tabBarBlurView];
    
    self.navigationBarBlurView = [[FXBlurView alloc] init];
    self.navigationBarBlurView.alpha = 0.0;
    self.navigationBarBlurView.blurRadius = 7.0;
    //[self.navigationController.navigationBar addSubview:self.navigationBarBlurView];
    //[self.navigationController.navigationBar bringSubviewToFront:self.navigationBarBlurView];*/
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.recommendedProdWithoutNulls count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendedProdCollectionViewCell *cell = (RecommendedProdCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.cellImageView setImageWithURL:[NSURL URLWithString:self.recommendedProdWithoutNulls[indexPath.row][@"product"][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100.0, [UIScreen mainScreen].bounds.size.height/4.3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Series"] ||
        [self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Telenovelas"] ||
        [self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Noticias"]) {
        
        TelenovelSeriesDetailViewController *telenovelSeriesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
        telenovelSeriesVC.serieID = self.recommendedProductions[indexPath.item][@"product"][@"id"];
        [self.navigationController pushViewController:telenovelSeriesVC animated:YES];
        
    } else if ([self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Películas"] || [self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Eventos en vivo"]) {
        MoviesEventsDetailsViewController *moviesEventDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
        moviesEventDetail.productionID = self.recommendedProductions[indexPath.item][@"product"][@"id"];
        [self.navigationController pushViewController:moviesEventDetail animated:YES];
    }
}

#pragma mark - Custom Methods

-(void)checkVideoAvailability:(Video *)video {
    if (video.status) {
        //The video is available to the user, so check the network connection to
        //decide if the user can watch the video
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if (status == NotReachable) {
            //There's no network connection, the user can't watch the video
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No te encuentras conectado a internet. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        } else if (status == ReachableViaWWAN) {
            //The user can't watch the video because the connection is to slow
            if (video.is3G) {
                //The user can watch it with 3G
                [[[UIAlertView alloc] initWithTitle:nil message:@"Para una mejor experiencia, se recomienda usar una conexión Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                VideoPlayerViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                videoPlayer.embedCode = video.embedHD;
                videoPlayer.productID = self.production.identifier;
                videoPlayer.progressSec = video.progressSec;
                [self.navigationController pushViewController:videoPlayer animated:YES];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu conexión a internet es muy lenta. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else if (status == ReachableViaWiFi) {
            //The user can watch the video
            VideoPlayerViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.embedCode = video.embedHD;
            videoPlayer.progressSec = video.progressSec;
            videoPlayer.productID = self.production.identifier;
            [self.navigationController pushViewController:videoPlayer animated:YES];
        }
        
    } else {
        //The video is not available for the user, so pass to the
        //Content not available for user
        ContentNotAvailableForUserViewController *contentNotAvailableForUser =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUser"];
        contentNotAvailableForUser.productID = self.production.identifier;
        contentNotAvailableForUser.productName = self.production.name;
        contentNotAvailableForUser.productType = self.production.type;
        contentNotAvailableForUser.viewType = self.production.viewType;
        [self.navigationController pushViewController:contentNotAvailableForUser animated:YES];
    }
}

-(void)watchProduction {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue] && [self.production.free isEqualToString:@"0"]) {
        SuscriptionAlertViewController *suscriptionAlertVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlert"];
        suscriptionAlertVC.productName = self.production.name;
        suscriptionAlertVC.productID = self.production.identifier;
        suscriptionAlertVC.productType = self.production.type;
        suscriptionAlertVC.viewType = self.production.viewType;
        [self.navigationController pushViewController:suscriptionAlertVC animated:YES];
        NSLog(@"no puedo ver la producción porque no he ingresado");
        return;
    }
    
    [self getIsContentAvailableForUserWithID:self.production.identifier];
}

-(void)watchTrailer {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para poder ver el trailer de esta producción debes estar conectado a internet" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
        videoPlayerVC.embedCode = self.production.trailerURL;
        [self.navigationController pushViewController:videoPlayerVC animated:YES];
    }
}

-(void)imageTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    LargeProductionImageView *largeProdView = [[LargeProductionImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    largeProdView.largeImageView.image = ((UIImageView *)[tapGestureRecognizer view]).image;
    /*[largeProdView.largeImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL]
                                      placeholder:nil
                                  completionBlock:nil
                                     failureBlock:nil];*/
    [self.tabBarController.view addSubview:largeProdView];
}

-(void)showRateView {
    self.opacityView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.6;
    [self.tabBarController.view addSubview:self.opacityView];
    RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(50.0, self.view.frame.size.height/2 - 50.0, self.view.frame.size.width - 100.0, 120.0) goldStars:[self.production.rate intValue]/20.0 + 1];
    rateView.delegate = self;
    [self.tabBarController.view addSubview:rateView];
}

-(void)shareProduction {
    [[[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"Volver"
                  destructiveButtonTitle:nil
                        otherButtonTitles:@"Facebook", @"Twitter", nil] showInView:self.view];
}

#pragma mark - Server Stuff 

-(void)showMoreInfoView {
    SinopsisView *sinopsisView = [[SinopsisView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    sinopsisView.delegate = self;
    sinopsisView.mainTitle.text = self.production.name;
    sinopsisView.sinopsisString = self.production.detailDescription;
    [sinopsisView showInView:self.view];
}

-(void)updateUserFeedbackForProductWithRate:(NSInteger)rate {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Calificando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"%@/%@/%d", @"produccion",self.production.identifier, rate];
    [serverCommunicator callServerWithGETMethod:@"UpdateUserFeedbackForProduct" andParameter:parameters];
}

-(void)getIsContentAvailableForUserWithID:(NSString *)ProductionID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:[NSString stringWithFormat:@"%@?provider=aim", ProductionID]];
}

-(void)getProductWithID:(NSString *)productID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:[NSString stringWithFormat:@"%@/%@?provider=aim", productID, @"0"]];
    } else {
        NSString *userID = [UserInfo sharedInstance].userID;
        [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:[NSString stringWithFormat:@"%@/%@?provider=aim", productID, userID]];
    }
}

-(void)getRecommendedProductionsForProductID:(NSString *)productID {
    ServerCommunicator *serveCommunicator = [[ServerCommunicator alloc] init];
    serveCommunicator.delegate = self;
    [serveCommunicator callServerWithGETMethod:@"GetRecommendationsWithProductID" andParameter:productID];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Recibí respuesta del servidor");
    if ([methodName isEqualToString:@"GetRecommendationsWithProductID"] && responseDictionary) {
        self.recommendedProductions = responseDictionary[@"recommended_products"];

    } else if ([methodName isEqualToString:@"GetProductWithID"]) {
        //FIXME: la posición en la cual llega la info de la producción no será la que se está usando
        //en este momento.
        if (![responseDictionary[@"products"][@"status"] boolValue]) {
            NSLog(@"El producto no está disponible");
            //Hubo algún problema y no se pudo acceder al producto
            if (responseDictionary[@"products"][@"response"]) {
                //Existe un mensaje de respuesta en el server, así que lo usamos en nuestra alerta
                NSString *alertMessage = responseDictionary[@"products"][@"response"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
                
            } else {
                //No existía un mensaje de respuesta en el servidor, entonces usamos un mensaje genérico.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No se pudo acceder al contenido. Por favor inténtalo de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
            }
            
        } else {
            //El status llegó true, entonces no hubo problema accediendo al producto
            //NSLog(@"El producto si está disponible");
            self.unparsedProductionInfo = responseDictionary[@"products"][@"0"][0];
        }
        
        
    } else if ([methodName isEqualToString:@"IsContentAvailableForUser"] && responseDictionary){
        if ([responseDictionary[@"status"] boolValue]) {
            NSDictionary *videoDicWithNulls = responseDictionary[@"video"];
            NSDictionary *videoDicWithoutNulss = [videoDicWithNulls dictionaryByReplacingNullWithBlanks];
            Video *video = [[Video alloc] initWithDictionary:videoDicWithoutNulss];
            [self checkVideoAvailability:video];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"El contenido no está disponible en este momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
    } else if ([methodName isEqualToString:@"UpdateUserFeedbackForProduct"] && responseDictionary) {
        NSLog(@"llegó la info de la calificación: %@", responseDictionary);
        
    } else {
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"server error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conetándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handlers 

-(void)videoShoulBeDisplayedNotification:(NSNotification *)notification {
    NSLog(@"Me llegó la notificacion de que deberia mostrar el video de one");
    self.receivedVideoNotification = YES;
}

#pragma mark - UIActionSheetDelegate 

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Facebook
        NSLog(@"Facebook está disponible");
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *message = [NSString stringWithFormat:@"Estoy viendo %@ en CaracolPlay %@", self.production.name, @"https://itunes.apple.com/app/id714489424"];
        [facebookViewController setInitialText:message];
        [self presentViewController:facebookViewController animated:YES completion:nil];
        
    } else if (buttonIndex == 1) {
        //Twitter
        NSLog(@"Twitter está disponible");
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *message = [NSString stringWithFormat:@"Estoy viendo %@ en CaracolPlay %@", self.production.name, @"https://itunes.apple.com/app/id714489424"];
        [twitterViewController setInitialText:message];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
}

#pragma mark - RateViewDelegate

-(void)rateButtonWasTappedInRateView:(RateView *)rateView withRate:(int)rate {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
    self.starsView.rate = rate;
    NSLog(@"rate: %d", rate);
    
    //FIXME: tal vez toque cambiar esto. hay que multiplicarlo por 20
    //porque los rates de caracol van de 0 a 100, no de 0 a 5
    [self updateUserFeedbackForProductWithRate:rate*20];
}

-(void)cancelButtonWasTappedInRateView:(RateView *)rateView {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - SinopsisViewDelegate 

-(void)closeButtonPressedInSinopsisView:(SinopsisView *)sinopsisView {
    
}

-(void)sinopsisViewDidDissapear:(SinopsisView *)sinopsisView {
    sinopsisView = nil;
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
