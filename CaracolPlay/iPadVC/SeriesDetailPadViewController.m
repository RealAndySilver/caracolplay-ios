//
//  SeriesDetailPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SeriesDetailPadViewController.h"
#import "EpisodesPadTableViewCell.h"
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

@interface SeriesDetailPadViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, RateViewDelegate>
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *opacityPatternView;
@property (strong, nonatomic) UIImageView *smallProductionImageView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) UIButton *watchTrailerButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *rateButton;
@property (strong, nonatomic) UITextView *productionDetailTextView;
@property (strong, nonatomic) UITableView *seasonsTableView;
@property (strong, nonatomic) UITableView *chaptersTableView;

@property (strong, nonatomic) NSArray *unparsedEpisodesInfo;
@property (strong, nonatomic) NSDictionary *productionInfo;
@property (strong, nonatomic) NSMutableArray *parsedEpisodesArray;
@property (strong, nonatomic) Product *production;

@property (strong, nonatomic) UIView *opacityView;

@end

@implementation SeriesDetailPadViewController

#pragma mark - Lazy Instantiation

-(NSArray *)unparsedEpisodesInfo {
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
                                    @"is_3g": @NO,},
                                  
                                  @{@"product_name": @"Pedro el Escamoso", @"episode_name": @"Primera prueba para las modelos.",
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
                                    @"is_3g": @YES,},
                                  ];
    }
    return _unparsedEpisodesInfo;
}

-(NSDictionary *)productionInfo {
    if (!_productionInfo) {
        _productionInfo = @{@"name": @"Colombia's Next Top Model", @"type" : @"Series", @"rate" : @5, @"my_rate" : @3, @"category_id" : @"59393",
                            @"id" : @"567", @"image_url" : @"http://esteeselpunto.com/wp-content/uploads/2013/02/Final-Colombia-Next-Top-Model-1024x871.png", @"trailer_url" : @"", @"has_seasons" : @YES, @"description" : @"Colombia's Next Top Model (a menudo abreviado como CNTM), fue un reality show de Colombia basado el en popular formato estadounidense America's Next Top Model en el que un número de mujeres compite por el título de Colombia's Next Top Model y una oportunidad para iniciar su carrera en la industria del modelaje", @"episodes" : self.unparsedEpisodesInfo, @"season_list" : @[]};
    }
    return _productionInfo;
}


#pragma mark - UISetup & Initialization stuff
-(void)parseEpisodesInfo {
    self.parsedEpisodesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.production.episodes count]; i++) {
        Episode *episode = [[Episode alloc] initWithDictionary:self.production.episodes[i]];
        [self.parsedEpisodesArray addObject:episode];
    }
    self.production.episodes = self.parsedEpisodesArray;
}

-(void)parseProductionInfo {
    self.production = [[Product alloc] initWithDictionary:self.productionInfo];
}

-(void)UISetup {
    //1. dismiss buton setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //2. background image view setup
    self.backgroundImageView = [[UIImageView alloc] init];
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //Set the opacity pattern view
    self.opacityPatternView = [[UIView alloc] init];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"SeriesOpacityPatternPad.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, 626.0)];
    self.opacityPatternView.clipsToBounds = YES;
    self.opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [self.backgroundImageView addSubview:self.opacityPatternView];
    
    //3. Small production image view setup
    self.smallProductionImageView = [[UIImageView alloc] init];
    [self.smallProductionImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    self.smallProductionImageView.clipsToBounds = YES;
    self.smallProductionImageView.userInteractionEnabled = YES;
    self.smallProductionImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.smallProductionImageView];
    
    // Add the stars to the view
    StarsView *starsView = [[StarsView alloc] initWithFrame:CGRectMake(180.0, 65.0, 100.0, 20.0) rate:[self.production.rate intValue]];
    [self.view addSubview:starsView];
    
    //Create a tap gesture and add it to the small image view, to display
    //a larger image when the user taps on it.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.smallProductionImageView addGestureRecognizer:tapGesture];
    
    //4. production name label setup
    self.productionNameLabel = [[UILabel alloc] init];
    self.productionNameLabel.text = self.production.name;
    self.productionNameLabel.textColor = [UIColor whiteColor];
    self.productionNameLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [self.view addSubview:self.productionNameLabel];
    
    //'Calificar' button setup
    self.rateButton = [[UIButton alloc] init];
    [self.rateButton setTitle:@"Calificar" forState:UIControlStateNormal];
    [self.rateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rateButton addTarget:self action:@selector(showRateView) forControlEvents:UIControlEventTouchUpInside];
    [self.rateButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.rateButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.rateButton];
    
    //5. Watch Trailer button setup
    self.watchTrailerButton = [[UIButton alloc] init];
    [self.watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    [self.watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.watchTrailerButton addTarget:self action:@selector(watchTrailer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.watchTrailerButton];
    
    //6. Share button setup
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
    
    //7. Production detail text view
    self.productionDetailTextView = [[UITextView alloc] init];
    self.productionDetailTextView.text = self.production.detailDescription;
    /*self.productionDetailTextView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel neque interdum quam auctor ultricies. Donec eget scelerisque leo, sed commodo nibh. Suspendisse potenti. Morbi vitae est ac ipsum mollis vulputate eget commodo elit. Donec magna justo, semper sit amet libero eget, tempus condimentum ipsum. Aenean lobortis eget justo sed mattis. Suspendisse eget libero eget est imperdiet dignissim vel quis erat.";*/
    self.productionDetailTextView.userInteractionEnabled = NO;
    self.productionDetailTextView.textColor = [UIColor whiteColor];
    self.productionDetailTextView.backgroundColor = [UIColor clearColor];
    self.productionDetailTextView.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.productionDetailTextView];
    
    //8. Seasons table view setup
    self.seasonsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.seasonsTableView.delegate = self;
    self.seasonsTableView.dataSource = self;
    self.seasonsTableView.tag = 1;
    self.seasonsTableView.backgroundColor = [UIColor clearColor];
    self.seasonsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.seasonsTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    [self.view addSubview:self.seasonsTableView];
    
    //9. Chapters table view setup
    self.chaptersTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.chaptersTableView.delegate = self;
    self.chaptersTableView.dataSource = self;
    self.chaptersTableView.tag = 2;
    self.chaptersTableView.backgroundColor = [UIColor darkGrayColor];
    self.chaptersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chaptersTableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:self.chaptersTableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self parseProductionInfo];
    [self parseEpisodesInfo];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 626.0);
    
    //Set subviews frame
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 25.0, 0.0, 25.0, 25.0);
    self.backgroundImageView.frame = self.view.bounds;
    self.opacityPatternView.frame = self.view.bounds;
    self.smallProductionImageView.frame = CGRectMake(30.0, 30.0, 128.0, 194.0);
    self.productionNameLabel.frame = CGRectMake(180.0, 30.0, self.view.bounds.size.width - 180.0, 30.0);
    self.rateButton.frame = CGRectMake(340.0, 60.0, 140.0, 35.0);
    self.watchTrailerButton.frame = CGRectMake(180.0, 100.0, 140.0, 35.0);
    self.shareButton.frame = CGRectMake(340.0, 100.0, 140.0, 35.0);
    self.productionDetailTextView.frame = CGRectMake(180.0, 150.0, self.view.bounds.size.width - 190.0, 100.0);
    self.seasonsTableView.frame = CGRectMake(30.0, 280.0, 128.0, self.view.bounds.size.height - 250.0);
    self.chaptersTableView.frame = CGRectMake(180.0, 280.0, self.view.bounds.size.width - 180.0 - 30.0, self.view.bounds.size.height - 280.0 - 30.0);
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
        [self presentViewController:videoPlayerPadVC animated:YES completion:nil];
    }
}

-(void)showRateView {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.6;
    [self.view addSubview:self.opacityView];
    RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100.0, self.view.frame.size.height/2 - 50.0, 200.0, 100.0)];
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

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        return 5;
    } else {
        return [self.production.episodes count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        cell.textLabel.text = @"Temporada 1";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        return cell;
    } else {
        EpisodesPadTableViewCell *cell = (EpisodesPadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[EpisodesPadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        Episode *episode = self.production.episodes[indexPath.row];
        cell.episodeNameLabel.text = episode.episodeName;
        cell.episodeNumberLabel.text = [episode.episodeNumber description];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 2) {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if (status == NotReachable) {
            NSLog(@"no hay internet");
            [[[UIAlertView alloc] initWithTitle:nil message:@"No es posible ver el video. Por favor revisa que tu dispositivo esté conectado a internet" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        } else if (status == ReachableViaWWAN) {
            NSLog(@"si hay internet pero 3g");
            if (((Episode *)self.production.episodes[indexPath.row]).is3G) {
                [self watchTrailer];
            } else {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Tu conexión es muy lenta para ver esta producción. Por favor conéctate a una red Wi-Fi" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else if (status == ReachableViaWiFi) {
            NSLog(@"hay wifi");
            [self watchTrailer];
        }
    }
}

#pragma mark - RateViewDelegate

-(void)rateButtonWasTappedInRateView:(RateView *)rateView withRate:(int)rate {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
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
