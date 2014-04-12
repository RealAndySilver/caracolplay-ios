//
//  TelenovelSeriesViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

static NSString *const cellIdentifier = @"CellIdentifier";

#import "TelenovelSeriesDetailViewController.h"
#import <Social/Social.h>
#import "MyUtilities.h"
#import "JMImageCache.h"
#import "Product.h"
#import "RateView.h"
#import "Episode.h"
#import "LargeProductionImageView.h"
#import "StarsView.h"
#import "Reachability.h"
#import "VideoPlayerViewController.h"
#import "FileSaver.h"
#import "SuscriptionAlertViewController.h"
#import "SeasonsListView.h"
#import "AddToListView.h"
#import "MBHUDView.h"
#import "IngresarViewController.h"
#import "ServerCommunicator.h"
#import "Season.h"
#import "SeasonsViewController.h"
#import "AddToListViewController.h"
#import "ContentNotAvailableForUserViewController.h"
#import "ServerCommunicator.h"
#import "Video.h"
#import "NSDictionary+NullReplacement.h"

@interface TelenovelSeriesDetailViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, RateViewDelegate, SeasonListViewDelegate, TelenovelSeriesTableViewCellDelegate, AddToListViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSDictionary *productionInfo;
@property (strong, nonatomic) NSDictionary *unparsedProductionInfoDic;
@property (strong, nonatomic) NSArray *unparsedEpisodesInfo;
@property (strong, nonatomic) NSMutableArray *parsedEpisodesArray; //
@property (strong, nonatomic) UIButton *seasonsButton;
@property (strong, nonatomic) Product *production;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) StarsView *starsView;
@property (assign, nonatomic) NSUInteger selectedSeason;

//BOOL that indicates if the view controller received a notification
//indicating that ith has to display the production video automaticly
//when the view appears.
@property (assign, nonatomic) BOOL receivedVideoNotification;
@property (strong, nonatomic) NSString *selectedEpisodeID;

@end

@implementation TelenovelSeriesDetailViewController

#pragma mark - Setters

-(void)setUnparsedProductionInfoDic:(NSDictionary *)unparsedProductionInfoDic {
    _unparsedProductionInfoDic = unparsedProductionInfoDic;
    NSDictionary *parsedProductionInfoDic = [self dictionaryWithParsedProductionInfo:unparsedProductionInfoDic];
    self.production = [[Product alloc] initWithDictionary:parsedProductionInfoDic];
    [self UISetup];
}

-(NSDictionary *)dictionaryWithParsedProductionInfo:(NSDictionary *)unparsedDic {
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
        NSArray *unparsedEpisodesArray = [NSArray arrayWithArray:unparsedDic[@"episodes"]];
        NSMutableArray *parsedEpisodesArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [unparsedEpisodesArray count]; i++) {
            Episode *episode = unparsedEpisodesArray[i];
            [parsedEpisodesArray addObject:episode];
        }
        [newDictionary setObject:parsedEpisodesArray forKey:@"episodes"];
        return newDictionary;
    }
}

#pragma mark - UISetup & Initialization stuff

-(void)UISetup {
    self.navigationItem.title = self.production.type;
    //1. Create the main image view of the movie/event
    UIImageView *movieEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                                     0.0,
                                                                                     self.view.frame.size.width,
                                                                                     self.view.frame.size.height/3)];
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
                                                                  self.view.frame.size.height/4.0)];
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
    
    //Add the play icon to the secondary image view
    UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.size.width/2 - 25.0, secondaryMovieEventImageView.frame.size.height/2 - 25.0, 50.0, 50.0)];
    playIcon.image = [UIImage imageNamed:@"PlayIconHomeScreen.png"];
    playIcon.clipsToBounds = YES;
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    [secondaryMovieEventImageView addSubview:playIcon];
    
    //Create a tap gesture and add it to the secondary image view to allow the user
    //to open the image in bigger size
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(imageTapped:)];
    [secondaryMovieEventImageView addGestureRecognizer:tapGestureRecognizer];
    
    //3. Create the label to display the movie/event name
    UILabel *movieEventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                             20.0,
                                                                             200.0,
                                                                             30.0)];
    movieEventNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    movieEventNameLabel.text = self.production.name;
    movieEventNameLabel.textColor = [UIColor whiteColor];
    movieEventNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:movieEventNameLabel];
    
    //4. Create the stars images
    self.starsView = [[StarsView alloc] initWithFrame:CGRectMake(110.0, 50, 100.0, 20.0) rate:[self.production.rate intValue]/20 + 1];
    [self.view addSubview:self.starsView];
    
    //Create a tap gesture and add it to the stars view to display the rate view when the user touches the stars.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRateView)];
    [self.starsView addGestureRecognizer:tapGesture];
    
    //5. Create a button to see the movie/event trailer
    UIButton *watchTrailerButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                              90.0,
                                                                              90.0,
                                                                              30.0)];
    [watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    [watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [watchTrailerButton addTarget:self action:@selector(watchTrailer) forControlEvents:UIControlEventTouchUpInside];
    watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    
    watchTrailerButton.layer.shadowColor = [UIColor blackColor].CGColor;
    watchTrailerButton.layer.shadowOpacity = 0.8;
    watchTrailerButton.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    watchTrailerButton.layer.shadowRadius = 5.0;
    
    [self.view addSubview:watchTrailerButton];
    
    //6. Create a button to share the movie/event
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 120.0, 90.0, 90.0, 30.0)];
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
    
    //7. Create a text view to display the detail of the event/movie
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, secondaryMovieEventImageView.frame.origin.y + secondaryMovieEventImageView.frame.size.height + 35.0, self.view.frame.size.width - 20.0, 70.0)];
    
    detailTextView.text = self.production.detailDescription;
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.textColor = [UIColor whiteColor];
    detailTextView.editable = NO;
    detailTextView.selectable = NO;
    detailTextView.textAlignment = NSTextAlignmentJustified;
    detailTextView.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:detailTextView];
    
    if (self.production.hasSeasons && [self.production.seasonList count] > 1) {
        //'Temporadas' button setup
        self.seasonsButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, detailTextView.frame.origin.y + detailTextView.frame.size.height, self.view.frame.size.width - 20.0, 44.0)];
        [self.seasonsButton setTitle:@"Temporada 1 ►" forState:UIControlStateNormal];
        self.seasonsButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.seasonsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.seasonsButton addTarget:self action:@selector(showSeasonsList) forControlEvents:UIControlEventTouchUpInside];
        [self.seasonsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:self.seasonsButton];
    }
    
    CGFloat tableViewOriginY;
    if (self.production.hasSeasons && [self.production.seasonList count] > 1) {
        tableViewOriginY = self.seasonsButton.frame.origin.y + self.seasonsButton.frame.size.height;
    } else {
        tableViewOriginY = detailTextView.frame.origin.y + detailTextView.frame.size.height + 20.0;
    }
    //8. Create a TableView to diaply the list of chapters
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, tableViewOriginY, self.view.frame.size.width, self.view.frame.size.height - tableViewOriginY - self.tabBarController.tabBar.frame.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.rowHeight = 50.0;
    [self.view addSubview:self.tableView];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Add as an observer of the notification -seasonSelectedNotification, to make the
    //chapters table view changes when neccesary
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(seasonSelectedNotificationReceived:)
                                                 name:@"SeasonSelectedNotification"
                                               object:nil];
    
    //Add as an observer of the TelenovelVideoShouldBeDisplayed notification, to display
    //the video inmediatly
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(telenovelVideoShouldBeDisplayedNotification:)
                                                 name:@"VideoShouldBeDisplayed"
                                               object:nil];
    //[self parseProductionInfo];
    //[self parseEpisodesInfo];
    self.view.backgroundColor = [UIColor blackColor];
    //[self UISetup];
    [self getProductionWithID:self.serieID];
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
        [self getIsContentAvailableForUserWithID:self.selectedEpisodeID];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //Set this BOOL to NO. This BOOL is set to YES when we received a
    //notification indicating that we have to display the production video
    //automaticly when the view appears.
    self.receivedVideoNotification = NO;
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Season *season = self.production.seasonList[self.selectedSeason];
    NSLog(@"selected season: %d", self.selectedSeason);
    return [season.episodes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TelenovelSeriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TelenovelSeriesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Season *season = self.production.seasonList[self.selectedSeason];
    Episode *episode = season.episodes[indexPath.row];
    cell.delegate = self;
    cell.chapterNumberLabel.text = [episode.episodeNumber description];
    cell.chapterNameLabel.text = episode.episodeName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //The user is logged in, so get the selected item ID
    Season *currentSeason = self.production.seasonList[self.selectedSeason];
    Episode *selectedEpisode = currentSeason.episodes[indexPath.row];
    self.selectedEpisodeID = selectedEpisode.identifier;
    NSLog(@"selected episode id: %@", self.selectedEpisodeID);
    
    //Check if the user is logged in.
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue] && [self.production.free isEqualToString:@"0"]) {
        //The user isn't login.
        SuscriptionAlertViewController *suscriptionAlertVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlert"];
        suscriptionAlertVC.productID = self.selectedEpisodeID;
        suscriptionAlertVC.productName = self.production.name;
        [self.navigationController pushViewController:suscriptionAlertVC animated:YES];
        NSLog(@"no puedo ver la producción porque no he ingresado");
        
    } else {
        [self getIsContentAvailableForUserWithID:selectedEpisode.identifier];
    }
}

#pragma mark - Actions 

-(void)showSeasonsList {
    NSLog(@"Me oprimieron");
    SeasonsViewController *seasonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Seasons"];
    seasonsVC.numberOfSeasons = [self.production.seasonList count];
    [self presentViewController:seasonsVC animated:YES completion:nil];
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
    LargeProductionImageView *largeImageView = [[LargeProductionImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    largeImageView.largeImageView.image = ((UIImageView *)[tapGestureRecognizer view]).image;
    /*[largeImageView.largeImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL]
                                       placeholder:nil
                                   completionBlock:nil
                                      failureBlock:nil];*/
    [self.tabBarController.view addSubview:largeImageView];
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
                VideoPlayerViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                videoPlayer.embedCode = video.embedHD;
                videoPlayer.productID = self.selectedEpisodeID;
                videoPlayer.progressSec = video.progressSec;
                [self.navigationController pushViewController:videoPlayer animated:YES];
            } else {
                //The user can't watch the video because the connection is to slow
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Este contenido no puede verse " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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
        ContentNotAvailableForUserViewController *contentNotAvailableForUser =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUser"];
        contentNotAvailableForUser.productID = self.selectedEpisodeID;
        contentNotAvailableForUser.productName = self.production.name;
        [self.navigationController pushViewController:contentNotAvailableForUser animated:YES];
    }
}

#pragma mark - Server Methods

-(void)updateUserFeedbackForProductWithRate:(NSInteger)rate {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Enviando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    NSString *parameters = [NSString stringWithFormat:@"%@/%@/%d", @"produccion",self.production.identifier, rate];
    [serverCommunicator callServerWithGETMethod:@"UpdateUserFeedbackForProduct" andParameter:parameters];
}

-(void)getIsContentAvailableForUserWithID:(NSString *)episodeID {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Cargando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:episodeID];
}

-(void)getProductionWithID:(NSString *)productID {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Cargando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:productID];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
    
    if ([methodName isEqualToString:@"GetProductWithID"] && dictionary) {
        if (![dictionary[@"products"][@"status"] boolValue]) {
            NSLog(@"El producto no está disponible");
            //Hubo algún problema y no se pudo acceder al producto
            if (dictionary[@"products"][@"response"]) {
                //Existe un mensaje de respuesta en el server, así que lo usamos en nuestra alerta
                NSString *alertMessage = dictionary[@"products"][@"response"];
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
            NSLog(@"El producto si está disponible");
            self.unparsedProductionInfoDic = dictionary[@"products"][@"0"][0];
        }
    
    } else if ([methodName isEqualToString:@"IsContentAvailableForUser"] && [dictionary[@"status"] boolValue]) {
        //La petición fue exitosa
        NSLog(@"info del video: %@", dictionary);
        NSDictionary *dicWithoutNulls = [dictionary dictionaryByReplacingNullWithBlanks];
        Video *video = [[Video alloc] initWithDictionary:dicWithoutNulls[@"video"]];
        [self checkVideoAvailability:video];
        
    } else if ([methodName isEqualToString:@"UpdateUserFeedbackForProduct"] && dictionary){
        NSLog(@"llegó la info de la caloficación: %@", dictionary);
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
    NSLog(@"Server Error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error conectándose con el servidor. Por favor comprueba que estés conectado a una red Wi-Fi e intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handler

-(void)telenovelVideoShouldBeDisplayedNotification:(NSNotification *)notification {
    NSLog(@"me llegó la notificación de que debo mostrar el video");
    self.receivedVideoNotification = YES;
}

-(void)seasonSelectedNotificationReceived:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    self.selectedSeason = [info[@"SeasonSelected"] intValue];
    NSLog(@"se selecciono la temporada %d", self.selectedSeason);
    [self.seasonsButton setTitle:[NSString stringWithFormat:@"Temporada %d ►", self.selectedSeason + 1] forState:UIControlStateNormal];
    [self.tableView reloadData];
}

#pragma mark - TelenovelSeriesTableViewCellDelegate

-(void)addButtonWasSelectedInCell:(TelenovelSeriesTableViewCell *)cell {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para poder crear listas de reproducción y añadir producciones debes ingresar con tu usuario." delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ingresar", nil] show];
        return;
    }
    
    AddToListViewController *addToListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddToList"];
    [self presentViewController:addToListVC animated:YES completion:nil];
    /*self.opacityView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.tabBarController.view addSubview:self.opacityView];
    
    AddToListView *addToListView = [[AddToListView alloc] initWithFrame:CGRectMake(30.0, self.view.frame.size.height/3.8, self.view.frame.size.width - 60.0, 300.0)];
    NSLog(@"add to list view frame: %@", NSStringFromCGRect(addToListView.frame));
    addToListView.delegate = self;
    [self.tabBarController.view addSubview:addToListView];*/
}

#pragma mark - AddToListViewDelegate

-(void)listWasSelectedAtIndex:(NSUInteger)index inAddToListView:(AddToListView *)addToListView {
    NSLog(@"index selected: %d", index);
    [MBHUDView hudWithBody:@"Agregado a tu lista" type:MBAlertViewHUDTypeCheckmark hidesAfter:2.0 show:YES];
}

-(void)addToListViewWillDisappear:(AddToListView *)addToListView {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

-(void)addToListViewDidDisappear:(AddToListView *)addToListView {
    [addToListView removeFromSuperview];
    addToListView = nil;
}

#pragma mark - SeasonListDelegate 

/*-(void)seasonsListView:(SeasonsListView *)seasonListView didSelectSeasonAtIndex:(NSUInteger)index {
    NSLog(@"Selected index: %d", index);
}

-(void)seasonsListWillDisappear:(SeasonsListView *)seasonsListView {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

-(void)seasonsListDidDisappear:(SeasonsListView *)seasonsListView {
    [seasonsListView removeFromSuperview];
    seasonsListView = nil;
}*/

#pragma mark - RateViewDelegate

-(void)rateButtonWasTappedInRateView:(RateView *)rateView withRate:(int)rate {
    NSLog(@"rate: %d", rate);
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
    self.starsView.rate = rate;
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
    /*if (buttonIndex == 1) {
        IngresarViewController *ingresarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Ingresar"];
        ingresarVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController pushViewController:ingresarVC animated:YES];
    }*/
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Facebook
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookViewController setInitialText:[NSString stringWithFormat:@"%@: %@", self.production.name, self.production.detailDescription]];
        [self presentViewController:facebookViewController animated:YES completion:nil];
        
    } else if (buttonIndex == 1) {
        //Twitter
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:[NSString stringWithFormat:@"%@: %@", self.production.name, self.production.detailDescription]];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
