//
//  SeriesDetailPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SeriesDetailPadViewController.h"
#import "VideoPlayerPadViewController.h"
#import <Social/Social.h>
#import "Product.h"
#import "Episode.h"
#import "JMImageCache.h"
#import "LargeProductionImageView.h"
#import "RateView.h"
#import "StarsView.h"
#import "MyUtilities.h"
#import "Reachability.h"
#import "FileSaver.h"
#import "EpisodesPadTableViewCell.h"
#import "AddToListView.h"
#import "ServerCommunicator.h"
#import "MBHUDView.h"
#import "Season.h"
#import "SuscriptionAlertPadViewController.h"
#import "Video.h"

@interface SeriesDetailPadViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, RateViewDelegate, EpisodesPadTableViewCellDelegate, AddToListViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *opacityPatternView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) UIButton *watchTrailerButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *rateButton;
@property (strong, nonatomic) UITextView *productionDetailTextView;
@property (strong, nonatomic) UITableView *seasonsTableView;
@property (strong, nonatomic) UITableView *chaptersTableView;

//@property (strong, nonatomic) NSArray *unparsedEpisodesInfo;
//@property (strong, nonatomic) NSDictionary *productionInfo;
//@property (strong, nonatomic) NSMutableArray *parsedEpisodesArray;
@property (strong, nonatomic) NSDictionary *unparsedProductionInfoDic;
@property (strong, nonatomic) Product *production;

@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) StarsView *starsView;
@property (assign, nonatomic) NSInteger selectedSeason;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation SeriesDetailPadViewController

#pragma mark - Setters & Getters

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(335 - 20.0, 313.0 - 20.0, 40.0, 40.0);
    }
    return _spinner;
}

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
    //2. background image view setup
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //Set the opacity pattern view
    self.opacityPatternView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"SeriesOpacityPatternPad.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, 626.0)];
    self.opacityPatternView.clipsToBounds = YES;
    self.opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [self.backgroundImageView addSubview:self.opacityPatternView];
    
    //3. Small production image view setup
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 30.0, 128.0, 194.0)];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    shadowView.layer.shadowRadius = 6.0;
    shadowView.layer.shadowOpacity = 0.8;
    [self.view addSubview:shadowView];
    
    UIImageView *smallProductionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, shadowView.frame.size.width, shadowView.frame.size.height)];
    [smallProductionImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    smallProductionImageView.clipsToBounds = YES;
    smallProductionImageView.userInteractionEnabled = YES;
    smallProductionImageView.contentMode = UIViewContentModeScaleAspectFill;
    [shadowView addSubview:smallProductionImageView];
    
    //Add the play icon into the secondaty image view
    UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(smallProductionImageView.frame.size.width/2 - 25.0, smallProductionImageView.frame.size.height/2 - 25.0, 50.0, 50.0)];
    playIcon.clipsToBounds = YES;
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    playIcon.image = [UIImage imageNamed:@"PlayIconHomeScreen.png"];
    [smallProductionImageView addSubview:playIcon];
    
    // Add the stars to the view
    self.starsView = [[StarsView alloc] initWithFrame:CGRectMake(180.0, 65.0, 100.0, 20.0) rate:[self.production.rate intValue]/20.0 + 1];
    [self.view addSubview:self.starsView];
    
    //Add a tap gesture to the star view. when the user touches the stars, show the rate view
    UITapGestureRecognizer *starsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRateView)];
    [self.starsView addGestureRecognizer:starsTapGesture];
    
    //Create a tap gesture and add it to the small image view, to display
    //a larger image when the user taps on it.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [smallProductionImageView addGestureRecognizer:tapGesture];
    
    //4. production name label setup
    self.productionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(180.0, 30.0, self.view.bounds.size.width - 180.0, 30.0)];
    self.productionNameLabel.text = self.production.name;
    self.productionNameLabel.textColor = [UIColor whiteColor];
    self.productionNameLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [self.view addSubview:self.productionNameLabel];
    
    //5. Watch Trailer button setup
    self.watchTrailerButton = [[UIButton alloc] initWithFrame:CGRectMake(180.0, 100.0, 140.0, 35.0)];
    [self.watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    [self.watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.watchTrailerButton addTarget:self action:@selector(watchTrailer) forControlEvents:UIControlEventTouchUpInside];
    
    self.watchTrailerButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.watchTrailerButton.layer.shadowOpacity = 0.8;
    self.watchTrailerButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.watchTrailerButton.layer.shadowRadius = 5.0;
    
    [self.view addSubview:self.watchTrailerButton];
    
    //6. Share button setup
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(340.0, 100.0, 140.0, 35.0)];
    [self.shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shareButton.layer.shadowOpacity = 0.8;
    self.shareButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.shareButton.layer.shadowRadius = 5.0;
    
    [self.view addSubview:self.shareButton];
    
    //7. Production detail text view
    self.productionDetailTextView = [[UITextView alloc] initWithFrame:CGRectMake(180.0, 150.0, self.view.bounds.size.width - 190.0, 100.0)];
    self.productionDetailTextView.text = self.production.detailDescription;
    /*self.productionDetailTextView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel neque interdum quam auctor ultricies. Donec eget scelerisque leo, sed commodo nibh. Suspendisse potenti. Morbi vitae est ac ipsum mollis vulputate eget commodo elit. Donec magna justo, semper sit amet libero eget, tempus condimentum ipsum. Aenean lobortis eget justo sed mattis. Suspendisse eget libero eget est imperdiet dignissim vel quis erat.";*/
    self.productionDetailTextView.userInteractionEnabled = NO;
    self.productionDetailTextView.textColor = [UIColor whiteColor];
    self.productionDetailTextView.backgroundColor = [UIColor clearColor];
    self.productionDetailTextView.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.productionDetailTextView];
    
    if (self.production.hasSeasons) {
        //8. Seasons table view setup
        self.seasonsTableView = [[UITableView alloc] initWithFrame:CGRectMake(30.0, 280.0, 128.0, self.view.bounds.size.height - 280.0) style:UITableViewStylePlain];
        self.seasonsTableView.delegate = self;
        self.seasonsTableView.dataSource = self;
        self.seasonsTableView.tag = 1;
        self.seasonsTableView.backgroundColor = [UIColor clearColor];
        self.seasonsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.seasonsTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [self.view addSubview:self.seasonsTableView];
    }
    
    //9. Chapters table view setup
    self.chaptersTableView = [[UITableView alloc] initWithFrame:CGRectMake(180.0, 280.0, self.view.bounds.size.width - 180.0 - 30.0, self.view.bounds.size.height - 280.0 - 30.0) style:UITableViewStylePlain];
    self.chaptersTableView.delegate = self;
    self.chaptersTableView.dataSource = self;
    self.chaptersTableView.tag = 2;
    self.chaptersTableView.backgroundColor = [UIColor darkGrayColor];
    self.chaptersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chaptersTableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:self.chaptersTableView];
}

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    //Add the spinner to the view inmediatly
    [self.view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    
    //Start the view with season 1
    self.selectedSeason = 0;
    
    self.view.backgroundColor = [UIColor blackColor];
    [self getProductionInfoWithID:self.productID];

    //Create the dismiss button. It's neccesary to create te button here, because
    //if there's a server error, the UISetup method won't get called, and nothing will
    //load, so the user won't be able to dismiss the view
    //1. dismiss buton setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 626.0);
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -30.0, 88.0, 88.0);
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        //Seasons table view
        return [self.production.seasonList count];
    } else {
        //Episodes table view
        if (self.production.hasSeasons) {
            //The product has seasons
            Season *season = self.production.seasonList[self.selectedSeason];
            return [season.episodes count];
        } else {
            //The product doesn't have episodes
            return [self.production.episodes count];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        //Seasons table view
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"Temporada %d", indexPath.row + 1];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        return cell;
        
    } else {
        //Episodes table view
        EpisodesPadTableViewCell *cell = (EpisodesPadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[EpisodesPadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        cell.delegate = self;
        
        if (self.production.hasSeasons) {
            //The product has seasons
            Season *season = self.production.seasonList[self.selectedSeason];
            Episode *episode = season.episodes[indexPath.row];
            cell.episodeNameLabel.text = episode.episodeName;
            cell.episodeNumberLabel.text = [episode.episodeNumber description];
            return cell;
        } else {
            //the product doesn't have seasons
            Episode *episode = self.production.episodes[indexPath.row];
            cell.episodeNameLabel.text = episode.episodeName;
            cell.episodeNumberLabel.text = [episode.episodeNumber description];
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 1) {
        //Seasons table view
        self.selectedSeason = indexPath.row;
        [self.chaptersTableView reloadData];
    }
    
    if (tableView.tag == 2) {
        //Episodes table view
        FileSaver *fileSaver = [[FileSaver alloc] init];
        if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
            //If the user isn't logged in, he can't watch the video
            SuscriptionAlertPadViewController *suscriptionAlertPadVC =
            [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlertPad"];
            suscriptionAlertPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            suscriptionAlertPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:suscriptionAlertPadVC animated:YES completion:nil];
            
        } else {
            //The user is already logged in, so check if the video is available
            if (self.production.hasSeasons) {
                Season *currentSeason = self.production.seasonList[self.selectedSeason];
                Episode *episode = currentSeason.episodes[indexPath.row];
                [self getIsContentAvailableForUserWithID:episode.identifier];
                NSLog(@"el identificador del capítulo es: %@", episode.identifier);
                
            } else {
                Episode *episode = self.production.episodes[indexPath.row];
                [self getIsContentAvailableForUserWithID:episode.identifier];
            }
        }
    }
}

#pragma mark - Actions

-(void)watchTrailer {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para ver el trailer de esta producción debes estar conectado a internet." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        VideoPlayerPadViewController *videoPlayerPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
        videoPlayerPadVC.embedCode = self.production.trailerURL;
        videoPlayerPadVC.isWatchingTrailer = YES;
        [self presentViewController:videoPlayerPadVC animated:YES completion:nil];
    }
}

-(void)showRateView {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.6;
    [self.view addSubview:self.opacityView];
    RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100.0, self.view.frame.size.height/2 - 50.0, 200.0, 120.0) goldStars:[self.production.rate  intValue]];
    rateView.delegate = self;
    [self.view addSubview:rateView];
}

-(void)imageTapped:(UITapGestureRecognizer *)tapGesture {
    LargeProductionImageView *largeProdView = [[LargeProductionImageView alloc] initWithFrame:self.view.bounds];
    [largeProdView.largeImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"HomeScreenPlaceholder.png"] completionBlock:nil failureBlock:nil];
    [self.view addSubview:largeProdView];
    [self.view bringSubviewToFront:largeProdView];
}

-(void)shareProduction {
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Volver" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", nil] showInView:self.view];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
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
            //The user can't watch the video because the connection is to slow
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu conexión a internet es muy lenta. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        } else if (status == ReachableViaWiFi) {
            //The user can watch the video
            VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.embedCode = video.embedHD;
            videoPlayer.isWatchingTrailer = NO;
            videoPlayer.progressSec = video.progressSec;
            videoPlayer.productID = self.productID;
            [self presentViewController:videoPlayer animated:YES completion:nil];
        }
        
    } else {
        //The video is not available for the user, so pass to the
        //Content not available for user
        //TODO: definir que se hará cuando el video no esté disponible para el usuario
        NSLog(@"el contenido no está disponible para el usuario");
    }
}

#pragma mark - ServerCommunicator 

-(void)getIsContentAvailableForUserWithID:(NSString *)episodeID {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:episodeID];
}

-(void)updateUserFeedbackForProductWithID:(NSString *)productID rate:(NSInteger)rate {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"product_id=%@&rate=%d", self.productID, rate];
    NSLog(@"paramters = %@", parameters);
    [serverCommunicator callServerWithPOSTMethod:@"UpdateUserFeedbackForProduct" andParameter:parameters httpMethod:@"POST"];
}

-(void)getProductionInfoWithID:(NSString *)productID {
    //Start animating the spinner
    [self.spinner startAnimating];
    
    //Communicate with the server
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:productID];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    //Stop the spinner
    [self.spinner stopAnimating];
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //Responses: GetProductWithID
    if ([methodName isEqualToString:@"GetProductWithID"] && [responseDictionary[@"status"] boolValue]) {
        //FIXME: la posición en la cual llega la info de la producción no será la que se está usando
        //en este momento.
        if (![responseDictionary[@"products"][@"status"] boolValue]) {
            NSLog(@"El producto no está disponible");
            //Hubo algún problema y no se pudo acceder al producto
            if (responseDictionary[@"products"][@"response"]) {
                //Existe un mensaje de respuesta en el server, así que lo usamos en nuestra alerta
                NSString *alertMessage = responseDictionary[@"products"][@"response"];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            } else {
                //No existía un mensaje de respuesta en el servidor, entonces usamos un mensaje genérico.
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No se pudo acceder al contenido. Por favor inténtalo de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            //El producto si está disponible
            self.unparsedProductionInfoDic = responseDictionary[@"products"][@"0"][0];
        }
    
    //Response:UpdateUserFeedbackForProduct
    } else if ([methodName isEqualToString:@"UpdateUserFeedbackForProduct"] && responseDictionary) {
        NSLog(@"recibí respuesta exitosa de UpdateUserFeedbackForProduct: %@", responseDictionary);
        
    //Response: IsContentAvailableForUser
    } else if ([methodName isEqualToString:@"IsContentAvailableForUser"] && [responseDictionary[@"status"] boolValue]) {
        NSLog(@"info del video: %@", responseDictionary);
        Video *video = [[Video alloc] initWithDictionary:responseDictionary[@"video"]];
        [self checkVideoAvailability:video];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un problema conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    //Stop the spinner
    [self.spinner stopAnimating];
    
    NSLog(@"server error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - EpisodesPadTableViewCellDelegate

-(void)addButtonWasSelectedInCell:(EpisodesPadTableViewCell *)cell {
    NSLog(@"me llamé");
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para poder crear listas de reproducción y añadir producciones debes ingresar con tu usuario." delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ingresar", nil] show];
        return;
    }
    
    self.opacityView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.view addSubview:self.opacityView];
    
    AddToListView *addToListView = [[AddToListView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 200.0, self.view.bounds.size.height/2.0 - 150.0, 400.0, 300.0)];
    NSLog(@"add to list view frame: %@", NSStringFromCGRect(addToListView.frame));
    addToListView.delegate = self;
    [self.view addSubview:addToListView];
}

#pragma mark - AddToListViewDelegate 

-(void)listWasSelectedAtIndex:(NSUInteger)index inAddToListView:(AddToListView *)addToListView {
    NSLog(@"Me agregaron a la lista que estaba en el index %d", index);
    [[[UIAlertView alloc] initWithTitle:nil message:@"Agregado correctamente a tu lista!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)addToListViewDidDisappear:(AddToListView *)addToListView {
    [addToListView removeFromSuperview];
    addToListView = nil;
}

-(void)addToListViewWillDisappear:(AddToListView *)addToListView {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

#pragma mark - RateViewDelegate

-(void)rateButtonWasTappedInRateView:(RateView *)rateView withRate:(int)rate {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
    self.starsView.rate = rate;
    [self updateUserFeedbackForProductWithID:self.productID rate:rate*20.0];
}

-(void)cancelButtonWasTappedInRateView:(RateView *)rateView {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

#pragma mark - UIActionSheetDelegate 

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Facebook
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [facebookViewController setInitialText:[NSString stringWithFormat:@"%@: %@", self.production.name, self.production.detailDescription]];
            [self presentViewController:facebookViewController animated:YES completion:nil];
        } else {
            //Tell te user that facebook is not configured on the device
            [[[UIAlertView alloc] initWithTitle:nil message:@"Facebook no está configurado en tu dispositivo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if (buttonIndex == 1) {
        //Twitter
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [twitterViewController setInitialText:[NSString stringWithFormat:@"%@: %@", self.production.name, self.production.detailDescription]];
            [self presentViewController:twitterViewController animated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Twitter no está configurado en tu dispositivo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

@end
