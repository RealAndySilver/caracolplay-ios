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
@end

@implementation TelenovelSeriesDetailViewController

#pragma mark - Lazy Instantiation

/*-(NSArray *)unparsedEpisodesInfo {
    if (!_unparsedEpisodesInfo) {
        _unparsedEpisodesInfo = @[@{@"product_name": @"Pedro el Escamoso", @"episode_name": @"Empieza Colombia's Next Top Model",
                                    @"description": @"Pedro es rescatado después de un terrible incidente de...",
                                    @"image_url": @"http://www.eldominio.com/laimagenparaestecapitulo.jpg",
                                    @"episode_number": @1,
                                    @"id": @"1235432",
                                    @"url": @"http://www.eldominio.com/laurldeestevideo.video",
                                    @"trailer_url": @"http://www.eldominio.com/laurldeltrailerdeestevideo.video",
                                    @"rate": @4,
                                    @"views": @"4321",//Número de veces visto
                                    @"duration": @2700,//En segundos
                                    @"category_id": @"7816234",
                                    @"progress_sec": @1500,//Tiempo del progreso (cuanto ha sido visto por el usuario)
                                    @"watched_on": @"2014-02-05",
                                    @"is_3g": @YES},
                                  
                                  @{@"product_name": @"Pedro el Escamoso", @"episode_name": @"La primera prueba para las modelos",
                                    @"description": @"Pedro es rescatado después de un terrible incidente de...",
                                    @"image_url": @"http://www.eldominio.com/laimagenparaestecapitulo.jpg",
                                    @"episode_number": @2,
                                    @"id": @"1235432",
                                    @"url": @"http://www.eldominio.com/laurldeestevideo.video",
                                    @"trailer_url": @"http://www.eldominio.com/laurldeltrailerdeestevideo.video",
                                    @"rate": @4,
                                    @"views": @"4321",//Número de veces visto
                                    @"duration": @2700,//En segundos
                                    @"category_id": @"7816234",
                                    @"progress_sec": @1500,//Tiempo del progreso (cuanto ha sido visto por el usuario)
                                    @"watched_on": @"2014-02-05",
                                    @"is_3g": @NO},
                                  
                                  @{@"product_name": @"Pedro el Escamoso", @"episode_name": @"La segunda prueba",
                                    @"description": @"Pedro es rescatado después de un terrible incidente de...",
                                    @"image_url": @"http://www.eldominio.com/laimagenparaestecapitulo.jpg",
                                    @"episode_number": @3,
                                    @"id": @"1235432",
                                    @"url": @"http://www.eldominio.com/laurldeestevideo.video",
                                    @"trailer_url": @"http://www.eldominio.com/laurldeltrailerdeestevideo.video",
                                    @"rate": @4,
                                    @"views": @"4321",//Número de veces visto
                                    @"duration": @2700,//En segundos
                                    @"category_id": @"7816234",
                                    @"progress_sec": @1500,//Tiempo del progreso (cuanto ha sido visto por el usuario)
                                    @"watched_on": @"2014-02-05",
                                    @"is_3g": @NO},
                                  ];
    }
    return _unparsedEpisodesInfo;
}*/

/*-(NSDictionary *)productionInfo {
    if (!_productionInfo) {
        _productionInfo = @{@"name": @"Colombia's Next Top Model", @"type" : @"Series", @"rate" : @4, @"my_rate" : @1, @"category_id" : @"59393",
                            @"id" : @"567", @"image_url" : @"http://esteeselpunto.com/wp-content/uploads/2013/02/Final-Colombia-Next-Top-Model-1024x871.png", @"trailer_url" : @"", @"has_seasons" : @YES, @"description" : @"Colombia's Next Top Model (a menudo abreviado como CNTM), fue un reality show de Colombia basado el en popular formato estadounidense America's Next Top Model en el que un número de mujeres compite por el título de Colombia's Next Top Model y una oportunidad para iniciar su carrera en la industria del modelaje.", @"episodes" : self.unparsedEpisodesInfo, @"season_list" : @[]};
    }
    return _productionInfo;
}*/

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
        return nil;
    }
}

#pragma mark - UISetup & Initialization stuff
/*-(void)parseEpisodesInfo {
    self.parsedEpisodesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.production.episodes count]; i++) {
        Episode *episode = [[Episode alloc] initWithDictionary:self.production.episodes[i]];
        [self.parsedEpisodesArray addObject:episode];
    }
    self.production.episodes = self.parsedEpisodesArray;
}

-(void)parseProductionInfo {
    self.production = [[Product alloc] initWithDictionary:self.productionInfo];
}*/

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
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, secondaryMovieEventImageView.frame.origin.y + secondaryMovieEventImageView.frame.size.height + 20.0, self.view.frame.size.width - 20.0, 70.0)];
    
    detailTextView.text = self.production.detailDescription;
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.textColor = [UIColor whiteColor];
    detailTextView.editable = NO;
    detailTextView.selectable = NO;
    detailTextView.textAlignment = NSTextAlignmentJustified;
    detailTextView.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:detailTextView];
    
    if (self.production.hasSeasons) {
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
    if (self.production.hasSeasons) {
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(seasonSelectedNotificationReceived:)
                                                 name:@"SeasonSelectedNotification"
                                               object:nil];
    //[self parseProductionInfo];
    //[self parseEpisodesInfo];
    self.view.backgroundColor = [UIColor blackColor];
    //[self UISetup];
    [self getProductionWithID:@"1"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Season *season = self.production.seasonList[self.selectedSeason];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        //The user isn't login.
        SuscriptionAlertViewController *suscriptionAlertVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlert"];
        [self.navigationController pushViewController:suscriptionAlertVC animated:YES];
        NSLog(@"no puedo ver la producción porque no he ingresado");
        return;
    }
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"No estás conectado a internet. Por favor conéctate a una red Wi-Fi" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else if (status == ReachableViaWWAN) {
        if ([self.production.episodes[indexPath.row][@"is_3g"] boolValue]) {
            VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            [self.navigationController pushViewController:videoPlayerVC animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Tu conexión a internet es muy lenta. Por favor conéctate a una red Wi-Fi" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if (status == ReachableViaWiFi) {
        VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
        [self.navigationController pushViewController:videoPlayerVC animated:YES];
    }
}

#pragma mark - Actions 

-(void)showSeasonsList {
    NSLog(@"Me oprimieron");
    SeasonsViewController *seasonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Seasons"];
    seasonsVC.numberOfSeasons = [self.production.seasonList count];
    [self presentViewController:seasonsVC animated:YES completion:nil];
    /*self.opacityView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.tabBarController.view addSubview:self.opacityView];
    SeasonsListView *seasonListView = [[SeasonsListView alloc] initWithFrame:CGRectMake(20.0, self.view.frame.size.height/2 - 100.0, 280.0, 280.0)];
    seasonListView.delegate = self;
    [self.tabBarController.view addSubview:seasonListView];*/
}

-(void)watchTrailer {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para poder ver el trailer de esta producción debes estar conectado a internet" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        VideoPlayerViewController *videoPlayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
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

#pragma mark - Server 

-(void)getProductionWithID:(NSString *)productID {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Cargando" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:productID];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
    if ([methodName isEqualToString:@"GetProductWithID"]) {
        NSLog(@"Recibí la info del producto");
        self.unparsedProductionInfoDic = dictionary[@"products"][0][0];
    }
}

-(void)serverError:(NSError *)error {
    [MBHUDView dismissCurrentHUD];
    NSLog(@"Server Error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error conectándose con el servidor. Por favor comprueba que estés conectado a una red Wi-Fi e intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handler

-(void)seasonSelectedNotificationReceived:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSLog(@"La temporada que se seleccionó fue %d", [info[@"SeasonSelected"] intValue]);
    self.selectedSeason = [info[@"SeasonSelected"] intValue];
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
    
    self.opacityView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.tabBarController.view addSubview:self.opacityView];
    
    AddToListView *addToListView = [[AddToListView alloc] initWithFrame:CGRectMake(30.0, self.view.frame.size.height/3.8, self.view.frame.size.width - 60.0, 300.0)];
    NSLog(@"add to list view frame: %@", NSStringFromCGRect(addToListView.frame));
    addToListView.delegate = self;
    [self.tabBarController.view addSubview:addToListView];
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
}

-(void)cancelButtonWasTappedInRateView:(RateView *)rateView {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        IngresarViewController *ingresarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Ingresar"];
        ingresarVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController pushViewController:ingresarVC animated:YES];
    }
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
