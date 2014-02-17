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

@interface TelenovelSeriesDetailViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, RateViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSDictionary *productionInfo;
@property (strong, nonatomic) NSArray *unparsedEpisodesInfo;
@property (strong, nonatomic) NSMutableArray *parsedEpisodesArray; //
@property (strong, nonatomic) UIButton *seasonsButton;
@property (strong, nonatomic) Product *production;
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation TelenovelSeriesDetailViewController

#pragma mark - Lazy Instantiation

-(NSArray *)unparsedEpisodesInfo {
    if (!_unparsedEpisodesInfo) {
        _unparsedEpisodesInfo = @[@{@"product_name": @"Pedro el Escamoso", @"episode_name": @"El rescate de pedro",
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
                                    @"is_3g": @YES,},
                                  
                                  @{@"product_name": @"Pedro el Escamoso", @"episode_name": @"El rescate de pedro final",
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
                                    @"is_3g": @NO,},
                                  ];
    }
    return _unparsedEpisodesInfo;
}

-(NSDictionary *)productionInfo {
    if (!_productionInfo) {
        _productionInfo = @{@"name": @"Colombia's Next Top Model", @"type" : @"Series", @"rate" : @4, @"my_rate" : @3, @"category_id" : @"59393",
                            @"id" : @"567", @"image_url" : @"http://esteeselpunto.com/wp-content/uploads/2013/02/Final-Colombia-Next-Top-Model-1024x871.png", @"trailer_url" : @"", @"has_seasons" : @YES, @"description" : @"Esta es la descripción de la producción", @"episodes" : self.unparsedEpisodesInfo, @"season_list" : @[]};
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
    //1. Create the main image view of the movie/event
    UIImageView *movieEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                                     self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                                     self.view.frame.size.width,
                                                                                     self.view.frame.size.height/3)];
    movieEventImageView.clipsToBounds = YES;
    movieEventImageView.contentMode = UIViewContentModeScaleAspectFill;
    [movieEventImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:nil completionBlock:nil failureBlock:nil];
    [self.view addSubview:movieEventImageView];
    
    //Create a view with an opacity pattern to apply an opacity to the image
    UIView *opacityPatternView = [[UIView alloc] initWithFrame:movieEventImageView.frame];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"MoviesOpacityPattern.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, movieEventImageView.frame.size.height+5)];
    opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [self.view addSubview:opacityPatternView];
    
    //2. Create the secondary image of the movie/event
    UIImageView *secondaryMovieEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0,
                                                                                              self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0,
                                                                                              90.0,
                                                                                              140.0)];
    secondaryMovieEventImageView.clipsToBounds = YES;
    secondaryMovieEventImageView.userInteractionEnabled = YES;
    secondaryMovieEventImageView.contentMode = UIViewContentModeScaleAspectFill;
    [secondaryMovieEventImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:nil completionBlock:nil failureBlock:nil];
    [self.view addSubview:secondaryMovieEventImageView];
    
    //Create a tap gesture and add it to the secondary image view to allow the user
    //to open the image in bigger size
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(imageTapped:)];
    [secondaryMovieEventImageView addGestureRecognizer:tapGestureRecognizer];
    
    //3. Create the label to display the movie/event name
    UILabel *movieEventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                             self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0,
                                                                             self.view.frame.size.width - 50.0,
                                                                             30.0)];
    movieEventNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    movieEventNameLabel.text = self.production.name;
    movieEventNameLabel.textColor = [UIColor whiteColor];
    movieEventNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:movieEventNameLabel];
    
    //4. Create the stars images
    StarsView *starsView = [[StarsView alloc] initWithFrame:CGRectMake(120.0, 110.0, 80.0, 16.0) rate:[self.production.rate intValue]];
    [self.view addSubview:starsView];
    
    //'calificar' button setup
    UIButton *rateButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 120.0, 115.0, 90.0, 30.0)];
    [rateButton setTitle:@"Calificar" forState:UIControlStateNormal];
    [rateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rateButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [rateButton addTarget:self action:@selector(showRateView) forControlEvents:UIControlEventTouchUpInside];
    rateButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:rateButton];
    
    //5. Create a button to see the movie/event trailer
    UIButton *watchTrailerButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                              self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 90.0,
                                                                              90.0,
                                                                              30.0)];
    [watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    [watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:watchTrailerButton];
    
    //6. Create a button to share the movie/event
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 120.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 90.0, 90.0, 30.0)];
    [shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:shareButton];
    
    //7. Create a text view to display the detail of the event/movie
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, movieEventImageView.frame.origin.y + movieEventImageView.frame.size.height, self.view.frame.size.width - 20.0, 70.0)];
    
    detailTextView.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.";
    //detailTextView.text = self.production.detailDescription;
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.textColor = [UIColor whiteColor];
    detailTextView.editable = NO;
    detailTextView.selectable = NO;
    detailTextView.textAlignment = NSTextAlignmentJustified;
    detailTextView.font = [UIFont systemFontOfSize:13.0];
    [self.view addSubview:detailTextView];
    
    if (self.production.hasSeasons) {
        //'Temporadas' button setup
        self.seasonsButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 330.0, self.view.frame.size.width - 20.0, 44.0)];
        [self.seasonsButton setTitle:@"Temporada 1" forState:UIControlStateNormal];
        self.seasonsButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.seasonsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.seasonsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:self.seasonsButton];
    }
    
    CGFloat tableViewOriginY;
    if (self.production.hasSeasons) {
        tableViewOriginY = 370.0;
    } else {
        tableViewOriginY = 330.0;
    }
    //8. Create a TableView to diaply the list of chapters
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, tableViewOriginY, self.view.frame.size.width, self.view.frame.size.height - 220.0 - 44.0) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.tableView.rowHeight = 50.0;
    [self.view addSubview:self.tableView];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self parseProductionInfo];
    [self parseEpisodesInfo];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = self.production.name;
    [self UISetup];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.production.episodes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TelenovelSeriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TelenovelSeriesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.chapterNumberLabel.text = [((Episode *)self.production.episodes[indexPath.row]).episodeNumber description];
    cell.chapterNameLabel.text = ((Episode *)self.production.episodes[indexPath.row]).episodeName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

-(void)imageTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    LargeProductionImageView *largeImageView = [[LargeProductionImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [largeImageView.largeImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL]
                                       placeholder:nil
                                   completionBlock:nil
                                      failureBlock:nil];
    [self.tabBarController.view addSubview:largeImageView];
}

-(void)showRateView {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.6;
    [self.tabBarController.view addSubview:self.opacityView];
    RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(50.0, self.view.frame.size.height/2 - 50.0, self.view.frame.size.width - 100.0, 100.0)];
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

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
