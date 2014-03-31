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
#import "MBHUDView.h"
#import "Season.h"
#import "Episode.h"
#import "NSDictionary+NullReplacement.h"
#import "Video.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface MoviesEventsDetailsViewController () <UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, RateViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) Product *production;
@property (strong, nonatomic) NSDictionary *unparsedProductionInfo;
@property (strong, nonatomic) NSArray *recommendedProductions;
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
    [self UISetup];
}

-(void)setRecommendedProductions:(NSArray *)recommendedProductions {
    _recommendedProductions = recommendedProductions;
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
    [self getRecommendedProductionsForProductID:self.productionID];
    [self getProductWithID:self.productionID];
    //[self UISetup];
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
        VideoPlayerViewController *videoPLayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
        [self.navigationController pushViewController:videoPLayerVC animated:YES];
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
    //1. Create the main image view of the movie/event
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    UIImageView *movieEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
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
    [self.view addSubview:opacityPatternView];
    
    //2. Create the secondary image of the movie/event
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(10.0,
                                                                 20.0,
                                                                 90.0,
                                                                  screenFrame.size.height/4.0)];
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
    
    //Add the play icon into the secondaty image view
    UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.size.width/2 - 25.0, secondaryMovieEventImageView.frame.size.height/2 - 25.0, 50.0, 50.0)];
    playIcon.clipsToBounds = YES;
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    playIcon.image = [UIImage imageNamed:@"PlayIconHomeScreen.png"];
    [secondaryMovieEventImageView addSubview:playIcon];
    
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
    
    //4. Create the stars images
    self.starsView = [[StarsView alloc] initWithFrame:CGRectMake(120.0, 50.0, 100.0, 20.0) rate:[self.production.rate intValue]];
    [self.view addSubview:self.starsView];
    [self.view bringSubviewToFront:self.starsView];
    
    //Add a tap gesture to the starView to open the rate view when the user touches the stars
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRateView)];
    [self.starsView addGestureRecognizer:tapGesture];
    
    //5. Create a button to see the movie/event trailer
    UIButton *watchTrailerButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                              screenFrame.size.height/6.3,
                                                                              90.0,
                                                                              30.0)];
    [watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    [watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [watchTrailerButton addTarget:self action:@selector(watchTrailer) forControlEvents:UIControlEventTouchUpInside];
    [watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:watchTrailerButton];
    
    //6. Create a button to share the movie/event
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 120.0, screenFrame.size.height/6.3, 90.0, 30.0)];
    [shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    
    shareButton.layer.shadowColor = [UIColor blackColor].CGColor;
    shareButton.layer.shadowOpacity = 0.8;
    shareButton.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    shareButton.layer.shadowRadius = 5.0;
    
    [self.view addSubview:shareButton];
    
    //Create the button to watch the production
    UIButton *watchProductionButton = [[UIButton alloc] initWithFrame:CGRectMake(watchTrailerButton.frame.origin.x, watchTrailerButton.frame.origin.y + watchTrailerButton.frame.size.height + 10.0, 190.0, 30.0)];
    [watchProductionButton setTitle:@"Ver Producción" forState:UIControlStateNormal];
    [watchProductionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [watchProductionButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    watchProductionButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [watchProductionButton addTarget:self action:@selector(watchProduction) forControlEvents:UIControlEventTouchUpInside];
    
    watchTrailerButton.layer.shadowColor = [UIColor blackColor].CGColor;
    watchTrailerButton.layer.shadowOpacity = 0.8;
    watchTrailerButton.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    watchTrailerButton.layer.shadowRadius = 5.0;
    
    [self.view addSubview:watchProductionButton];
    
    //7. Create a text view to display the detail of the event/movie
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, movieEventImageView.frame.origin.y + movieEventImageView.frame.size.height, screenFrame.size.width - 20.0, screenFrame.size.height/8.0)];
    
    detailTextView.text = self.production.detailDescription;
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.textColor = [UIColor whiteColor];
    detailTextView.editable = NO;
    detailTextView.selectable = NO;
    detailTextView.textAlignment = NSTextAlignmentJustified;
    detailTextView.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:detailTextView];
    
    
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
    return [self.recommendedProductions count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendedProdCollectionViewCell *cell = (RecommendedProdCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.cellImageView setImageWithURL:[NSURL URLWithString:self.recommendedProductions[indexPath.row][@"product"][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100.0, [UIScreen mainScreen].bounds.size.height/4.3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Series"] ||
        [self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Telenovelas"]) {
        
        TelenovelSeriesDetailViewController *telenovelSeriesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
        telenovelSeriesVC.serieID = self.recommendedProductions[indexPath.item][@"product"][@"id"];
        [self.navigationController pushViewController:telenovelSeriesVC animated:YES];
        /*MoviesEventsDetailsViewController *moviesEventDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
        [self.navigationController pushViewController:moviesEventDetail animated:YES];*/
        
    } else if ([self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Peliculas"]) {
        MoviesEventsDetailsViewController *moviesEventDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
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
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu conexión a internet es muy lenta. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        } else if (status == ReachableViaWiFi) {
            //The user can watch the video
            VideoPlayerViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.embedCode = video.embedHD;
            [self.navigationController pushViewController:videoPlayer animated:YES];
        }
        
    } else {
        //The video is not available for the user, so pass to the
        //Content not available for user
        ContentNotAvailableForUserViewController *contentNotAvailableForUser =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUser"];
        [self.navigationController pushViewController:contentNotAvailableForUser animated:YES];
    }
}

-(void)watchProduction {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        SuscriptionAlertViewController *suscriptionAlertVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlert"];
        [self.navigationController pushViewController:suscriptionAlertVC animated:YES];
        NSLog(@"no puedo ver la producción porque no he ingresado");
        return;
    }
    
    [self getIsContentAvailableForUserWithID:self.production.identifier];
    /*BOOL contentIsAvailableForUser = NO;
    if (!contentIsAvailableForUser) {
        //The content is not availble for the user
        ContentNotAvailableForUserViewController *contentNotAvailableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUser"];
        [self.navigationController pushViewController:contentNotAvailableVC animated:YES];
        
    } else {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        if (status == NotReachable) {
            [[[UIAlertView alloc] initWithTitle:nil  message:@"Para poder ver la producción debes estar conectado a internet" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            [self.navigationController pushViewController:videoPlayerVC animated:YES];
        }
    }*/
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
    RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(50.0, self.view.frame.size.height/2 - 50.0, self.view.frame.size.width - 100.0, 120.0) goldStars:[self.production.rate intValue]];
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

-(void)getIsContentAvailableForUserWithID:(NSString *)ProductionID {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Cargando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:ProductionID];
}

-(void)getProductWithID:(NSString *)productID {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Cargando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:productID];
}

-(void)getRecommendedProductionsForProductID:(NSString *)productID {
    ServerCommunicator *serveCommunicator = [[ServerCommunicator alloc] init];
    serveCommunicator.delegate = self;
    //FIXME: El parámetro debe ser el id de la producción.
    [serveCommunicator callServerWithGETMethod:@"GetRecommendationsWithProductID" andParameter:productID];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
    NSLog(@"Recibí respuesta del servidor");
    if ([methodName isEqualToString:@"GetRecommendationsWithProductID"] && [responseDictionary[@"status"] boolValue]) {
        self.recommendedProductions = responseDictionary[@"recommended_products"];
        
    } else if ([methodName isEqualToString:@"GetProductWithID"] && [responseDictionary[@"status"] boolValue]) {
        //FIXME: la posición en la cual llega la info de la producción no será la que se está usando
        //en este momento.
        self.unparsedProductionInfo = responseDictionary[@"products"][0][0];
        NSLog(@"La petición fue exitosa. producto: %@", self.unparsedProductionInfo);
        
    } else if ([methodName isEqualToString:@"IsContentAvailableForUser"] && [responseDictionary[@"status"] boolValue]){
        Video *video = [[Video alloc] initWithDictionary:responseDictionary[@"video"]];
        [self checkVideoAvailability:video];
        
    } else {
          [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
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
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            NSLog(@"Facebook está disponible");
            SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [facebookViewController setInitialText:[NSString stringWithFormat:@"%@: %@", self.production.name, self.production.detailDescription]];
            [self presentViewController:facebookViewController animated:YES completion:nil];
            
        } else {
            NSLog(@"Facebook no está disponible");
            [[[UIAlertView alloc] initWithTitle:nil message:@"Facebook no está configurado en tu dispositivo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if (buttonIndex == 1) {
        //Twitter
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            NSLog(@"Twitter está disponible");
            SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [twitterViewController setInitialText:[NSString stringWithFormat:@"%@: %@", self.production.name, self.production.detailDescription]];
            [self presentViewController:twitterViewController animated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Twitter no está configurado en tu dispositivo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

#pragma mark - RateViewDelegate

-(void)rateButtonWasTappedInRateView:(RateView *)rateView withRate:(int)rate {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
    self.starsView.rate = rate;
}

-(void)cancelButtonWasTappedInRateView:(RateView *)rateView {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

#pragma mark - Interface Orientation 

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
