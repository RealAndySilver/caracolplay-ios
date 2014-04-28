//
//  MovieDetailsViewController.m
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MovieDetailsPadViewController.h"
#import "SeriesDetailPadViewController.h"
#import "VideoPlayerPadViewController.h"
#import <Social/Social.h>
#import "Product.h"
#import "JMImageCache.h"
#import "LargeProductionImageView.h"
#import "RateView.h"
#import "StarsView.h"
#import "Reachability.h"
#import "FileSaver.h"
#import "SuscriptionAlertPadViewController.h"
#import "ServerCommunicator.h"
#import "Episode.h"
#import "Season.h"
#import "Video.h"
#import "ContentNotAvailableForUserPadViewController.h"
#import "UserInfo.h"
#import "NSDictionary+NullReplacement.h"
#import "NSArray+NullReplacement.h"

NSString *const moviesCellIdentifier = @"CellIdentifier";

@interface MovieDetailsPadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, RateViewDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *opaqueView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) UIButton *watchTrailerButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *viewProductionButton;
@property (strong, nonatomic) UIButton *rateButton;
@property (strong, nonatomic) UITextView *productionDetailTextView;
@property (strong, nonatomic) UILabel *recommendedProductionsLabel;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIImageView *smallProductionImageView;
@property (strong, nonatomic) UIImageView *freeBandImageView;
@property (strong, nonatomic) UIView *grayView;

@property (strong, nonatomic) NSDictionary *unparsedProductionInfoDic;
@property (strong, nonatomic) NSMutableArray *recommendedProductions;
@property (strong, nonatomic) Product *production;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) StarsView *starsView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation MovieDetailsPadViewController

#pragma mark - Setters & Getters

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(335 - 20.0, 300 - 20.0, 40.0, 40.0);
    }
    return _spinner;
}

-(void)setRecommendedProductions:(NSMutableArray *)recommendedProductions {
    _recommendedProductions = recommendedProductions;
    [self setupRecommendedProductionsCollectionView];
}

-(void)setupRecommendedProductionsCollectionView {
    //10.0 collecitionView setup
    self.collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 370.0, self.view.bounds.size.width, self.view.bounds.size.height - 370.0) collectionViewLayout:self.collectionViewFlowLayout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:moviesCellIdentifier];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    [self.view addSubview:self.collectionView];
}

-(void)setUnparsedProductionInfoDic:(NSDictionary *)unparsedProductionInfoDic {
    _unparsedProductionInfoDic = unparsedProductionInfoDic;
    NSDictionary *parsedProductionInfoDic = [self dictionaryWithParsedProductionInfo:unparsedProductionInfoDic];
    self.production = [[Product alloc] initWithDictionary:parsedProductionInfoDic];
    [self getRecommendedProductionsForProductID:self.production.identifier];
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
        /*NSLog(@"El producto no tiene temporadas");
        NSArray *unparsedEpisodesArray = [NSArray arrayWithArray:unparsedDic[@"episodes"]];
        NSMutableArray *parsedEpisodesArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [unparsedEpisodesArray count]; i++) {
            Episode *episode = unparsedEpisodesArray[i];
            [parsedEpisodesArray addObject:episode];
        }
        [newDictionary setObject:parsedEpisodesArray forKey:@"episodes"];
        return newDictionary;*/
        
        //The product has no seasons
        NSLog(@"El producto no tiene temporadas");
        NSDictionary *productionVideoDic = unparsedDic[@"episodes"];
        [newDictionary setObject:productionVideoDic forKey:@"episodes"];
        return newDictionary;
    }
}

-(void)UISetup {
    /*//2. Background image view
    self.backgroundImageView = [[UIImageView alloc] init];
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:nil completionBlock:nil failureBlock:nil];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];*/
    
    //Free band image view
    if ([self.production.free isEqualToString:@"1"]) {
        self.freeBandImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 118.0, 0.0, 118.0, 86.0)];
        self.freeBandImageView.image = [UIImage imageNamed:@"FreeBandPad.png"];
        [self.view addSubview:self.freeBandImageView];
    }
    
    //3. add a UIView to opaque the background view
    /*self.opaqueView = [[UIView alloc] init];
    self.opaqueView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.backgroundImageView addSubview:self.opaqueView];*/
    
    //3. small production image view
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 30.0, 160.0, 260.0)];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    shadowView.layer.shadowRadius = 6.0;
    shadowView.layer.shadowOpacity = 0.8;
    [self.view addSubview:shadowView];
    
    self.smallProductionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, shadowView.frame.size.width, shadowView.frame.size.height)];
    [self.smallProductionImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL]
                                       placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    self.smallProductionImageView.clipsToBounds = YES;
    self.smallProductionImageView.userInteractionEnabled = YES;
    self.smallProductionImageView.contentMode = UIViewContentModeScaleAspectFill;
    [shadowView addSubview:self.smallProductionImageView];
    
    //Add the play icon into the secondaty image view
    /*UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(smallProductionImageView.frame.size.width/2 - 25.0, smallProductionImageView.frame.size.height/2 - 25.0, 50.0, 50.0)];
    playIcon.clipsToBounds = YES;
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    playIcon.image = [UIImage imageNamed:@"PlayIconHomeScreen.png"];
    [smallProductionImageView addSubview:playIcon];*/
    
    if (![self.production.type isEqualToString:@"Eventos en vivo"]) {
        //Stars view
        self.starsView = [[StarsView alloc] initWithFrame:CGRectMake(210.0, 55.0, 100.0, 50.0) rate:[self.production.rate intValue]/20.0 + 1];
        [self.view addSubview:self.starsView];
        UITapGestureRecognizer *starsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRateView)];
        [self.starsView addGestureRecognizer:starsTapGesture];
        
        //5. Watch Trailer button setup
        self.watchTrailerButton = [[UIButton alloc] init];
        [self.watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
        [self.watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"WatchTrailerButton.png"] forState:UIControlStateNormal];
        self.watchTrailerButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
        self.watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.watchTrailerButton addTarget:self action:@selector(watchTrailer) forControlEvents:UIControlEventTouchUpInside];
        
        self.watchTrailerButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.watchTrailerButton.layer.shadowOpacity = 0.8;
        self.watchTrailerButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
        self.watchTrailerButton.layer.shadowRadius = 5.0;
        
        [self.view addSubview:self.watchTrailerButton];
    }
  
    
    //Create a tap gesture and add it to the small image view, so when the user touches the image,
    //a larger image will be displayed
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.smallProductionImageView addGestureRecognizer:tapGesture];
    
    //4. Production name label setup
    self.productionNameLabel = [[UILabel alloc] init];
    self.productionNameLabel.text = self.production.name;
    self.productionNameLabel.textColor = [UIColor whiteColor];
    self.productionNameLabel.font = [UIFont boldSystemFontOfSize:25.0];
    [self.view addSubview:self.productionNameLabel];
    
    
    //6. Share button
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"ShareButton.png"] forState:UIControlStateNormal];
    self.shareButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    self.shareButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shareButton.layer.shadowOpacity = 0.8;
    self.shareButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.shareButton.layer.shadowRadius = 5.0;
    [self.view addSubview:self.shareButton];
    
    //View production button
    self.viewProductionButton = [[UIButton alloc] init];
    [self.viewProductionButton setTitle:@"Ver Producción" forState:UIControlStateNormal];
    [self.viewProductionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.viewProductionButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.viewProductionButton addTarget:self action:@selector(watchProduction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewProductionButton setBackgroundImage:[UIImage imageNamed:@"OrangeButton.png"] forState:UIControlStateNormal];
    
    self.viewProductionButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.viewProductionButton.layer.shadowOpacity = 0.8;
    self.viewProductionButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.viewProductionButton.layer.shadowRadius = 5.0;
    [self.view addSubview:self.viewProductionButton];
    
    
    //7. Productiond etail textview setup
    /*self.productionDetailTextView = [[UITextView alloc] init];
    self.productionDetailTextView.text = self.production.detailDescription;
    self.productionDetailTextView.textColor = [UIColor whiteColor];
    self.productionDetailTextView.selectable = NO;
    self.productionDetailTextView.editable = NO;
    self.productionDetailTextView.backgroundColor = [UIColor clearColor];
    self.productionDetailTextView.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.productionDetailTextView];*/
    
    self.webView = [[UIWebView alloc] init];
    self.webView.opaque=NO;
    [self.webView setBackgroundColor:[UIColor clearColor]];
    NSString *str = [NSString stringWithFormat:@"<html><body style='background-color: transparent; color:white; font-family: helvetica;'>%@</body></html>",self.production.detailDescription];
    [self.webView loadHTMLString:str baseURL:nil];
    [self.view addSubview:self.webView];
    
    ////////////////////////////////////////////////
    //gray view
    self.grayView = [[UIView alloc] init];
    self.grayView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.view addSubview:self.grayView];
    
    
    //9. Recommended productions label setup
    self.recommendedProductionsLabel = [[UILabel alloc] init];
    self.recommendedProductionsLabel.text = @"Producciones Recomendadas";
    self.recommendedProductionsLabel.textColor = [UIColor whiteColor];
    self.recommendedProductionsLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.view addSubview:self.recommendedProductionsLabel];
}

-(void)removeUI {
    NSLog(@"entré a quitar estas vainas");
    [self.backgroundImageView removeFromSuperview];
    [self.productionDetailTextView removeFromSuperview];
    [self.productionNameLabel removeFromSuperview];
    [self.recommendedProductionsLabel removeFromSuperview];
    [self.webView removeFromSuperview];
    [self.starsView removeFromSuperview];
    [self.shareButton removeFromSuperview];
    [self.watchTrailerButton removeFromSuperview];
    [self.viewProductionButton removeFromSuperview];
    [self.smallProductionImageView removeFromSuperview];
    [self.freeBandImageView removeFromSuperview];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.spinner];
    [self getProductWithID:self.productID];
    
    //Dismiss button setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //Add as an oberver of the VideoShoulBeDisplayed notification. when this notification
    //is received, the video controller should be presented automaticly
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoShouldBeDisplayedReceived)
                                                 name:@"Video"
                                               object:nil];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 600.0);
    
    //Set subviews frame
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -30.0, 88.0, 88.0);
    self.backgroundImageView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height/2 + 50.0);
    self.opaqueView.frame = self.backgroundImageView.frame;
    self.productionNameLabel.frame = CGRectMake(210.0, 25.0, self.view.bounds.size.width - 180.0, 30.0);
    self.rateButton.frame = CGRectMake(370.0, 60.0, 140.0, 35.0);
    self.watchTrailerButton.frame = CGRectMake(210.0, 100.0, 130.0, 35.0);
    
    if ([self.production.type isEqualToString:@"Eventos en vivo"]) {
        self.shareButton.frame = CGRectMake(210.0, 100.0, 130.0, 35.0);
    } else {
        self.shareButton.frame = CGRectMake(360.0, 100.0, 130.0, 35.0);
    }
    self.viewProductionButton.frame = CGRectMake(self.shareButton.frame.origin.x + self.shareButton.frame.size.width + 20.0, 100.0, 130.0, 35.0);
    self.webView.frame = CGRectMake(210.0, 150.0, self.view.bounds.size.width - 210.0, 130.0);
    self.grayView.frame = CGRectMake(0.0, 350.0, self.view.bounds.size.width, self.view.bounds.size.height - 350.0);
    self.recommendedProductionsLabel.frame = CGRectMake(20.0, 360.0, 250.0, 30.0);
    //self.collectionView.frame = CGRectMake(0.0, 370.0, self.view.bounds.size.width, self.view.bounds.size.height - 370.0);
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.recommendedProductions count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:moviesCellIdentifier forIndexPath:indexPath];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    shadowView.layer.shadowRadius = 5.0;
    shadowView.layer.shadowOpacity = 1.0;
    [cell.contentView addSubview:shadowView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, cell.contentView.bounds.size.width - 20.0, cell.contentView.bounds.size.height - 20.0)];
    [imageView setImageWithURL:[NSURL URLWithString:self.recommendedProductions[indexPath.item][@"product"][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [shadowView addSubview:imageView];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma  mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //return CGSizeMake(120.0, 180.0);
    return CGSizeMake(140.0, 200.0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     NSLog(@"Seleccioné el item %d", indexPath.item);
    if ([self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Series"] || [self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Telenovelas"] || [self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Noticias"]) {
        /*SeriesDetailPadViewController *seriesDetailPad = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
        seriesDetailPad.modalPresentationStyle = UIModalPresentationFormSheet;
        seriesDetailPad.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        seriesDetailPad.productID = self.recommendedProductions[indexPath.item][@"product"][@"id"];
        [self presentViewController:seriesDetailPad animated:YES completion:nil];*/
        
    } else if ([self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Películas"] || [self.recommendedProductions[indexPath.item][@"product"][@"type"] isEqualToString:@"Eventos en vivo"]) {
        /*MovieDetailsPadViewController *movieDetailsPad = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
        movieDetailsPad.modalPresentationStyle = UIModalPresentationFormSheet;
        movieDetailsPad.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        movieDetailsPad.productID = self.recommendedProductions[indexPath.item][@"product"][@"id"];
        [self presentViewController:movieDetailsPad animated:YES completion:nil];*/
        NSString *selectedProductID = self.recommendedProductions[indexPath.item][@"product"][@"id"];
        [self.recommendedProductions removeAllObjects];
        [self removeUI];
        [self.collectionView reloadData];
        [self getProductWithID:selectedProductID];
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
                [[[UIAlertView alloc] initWithTitle:nil message:@"Para una mejor experiencia, se recomienda usar una coenxión Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                videoPlayer.embedCode = video.embedHD;
                videoPlayer.episodeID = self.production.identifier;
                videoPlayer.progressSec = video.progressSec;
                videoPlayer.productID = self.production.identifier;
                [self.navigationController pushViewController:videoPlayer animated:YES];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu conexión a internet es muy lenta. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else if (status == ReachableViaWiFi) {
            //The user can watch the video
            VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.embedCode = video.embedHD;
            videoPlayer.progressSec = video.progressSec;
            videoPlayer.episodeID = self.production.identifier;
            videoPlayer.productID = self.production.identifier;
            [self presentViewController:videoPlayer animated:YES completion:nil];
        }
        
    } else {
        ContentNotAvailableForUserPadViewController *contentNotAvailableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUserPad"];
        contentNotAvailableVC.productID = self.production.identifier;
        contentNotAvailableVC.productName = self.production.name;
        contentNotAvailableVC.productType = self.production.type;
        contentNotAvailableVC.viewType = self.production.viewType;
        contentNotAvailableVC.modalPresentationStyle = UIModalPresentationFormSheet;
        contentNotAvailableVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:contentNotAvailableVC animated:YES completion:nil];
    }
}

#pragma mark - Actions

-(void)watchProduction {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        SuscriptionAlertPadViewController *suscriptionAlertPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlertPad"];
        suscriptionAlertPadVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        suscriptionAlertPadVC.productID = self.production.identifier;
        suscriptionAlertPadVC.productName = self.production.name;
        suscriptionAlertPadVC.productType = self.production.type;
        suscriptionAlertPadVC.viewType = self.production.viewType;
        [self presentViewController:suscriptionAlertPadVC animated:YES completion:nil];
        /*[[[UIAlertView alloc] initWithTitle:nil message:@"Para poder ver la producción debes ingresar con tu usuario." delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ingresar", nil] show];*/
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
        VideoPlayerPadViewController *videoPlayerPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
        videoPlayerPadVC.embedCode = self.production.trailerURL;
        [self presentViewController:videoPlayerPadVC animated:YES completion:nil];
    }
}

-(void)showRateView {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.6;
    [self.view addSubview:self.opacityView];
    RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100.0, self.view.frame.size.height/2 - 50.0, 200.0, 120.0) goldStars:[self.production.rate intValue]/20.0 + 1];
    rateView.delegate = self;
    [self.view addSubview:rateView];
}

-(void)imageTapped:(UITapGestureRecognizer *)tapGesture {
    LargeProductionImageView *largeProdView = [[LargeProductionImageView alloc] initWithFrame:self.view.bounds];
    [largeProdView.largeImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:nil completionBlock:nil failureBlock:nil];
    [self.view addSubview:largeProdView];
}

-(void)shareProduction {
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Volver" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", nil] showInView:self.view];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification Handlers

-(void)videoShouldBeDisplayedReceived {
    NSLog(@"llegó la notificación: video");
    [self.viewProductionButton removeFromSuperview];
    [self getIsContentAvailableForUserWithID:self.production.identifier];
}

#pragma mark - Server Stuff

-(void)getIsContentAvailableForUserWithID:(NSString *)ProductionID {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:ProductionID];
}

-(void)getProductWithID:(NSString *)productID {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:[NSString stringWithFormat:@"%@/%@", productID, @"0"]];
    } else {
        NSString *userID = [UserInfo sharedInstance].userID;
        [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:[NSString stringWithFormat:@"%@/%@", productID, userID]];
    }
}

-(void)getRecommendedProductionsForProductID:(NSString *)productID {
    ServerCommunicator *serveCommunicator = [[ServerCommunicator alloc] init];
    serveCommunicator.delegate = self;
    [serveCommunicator callServerWithGETMethod:@"GetRecommendationsWithProductID" andParameter:productID];
}

-(void)updateUserFeedbackForProductWithRate:(NSInteger)rate {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"%@/%@/%d", @"produccion",self.production.identifier, rate];
    [serverCommunicator callServerWithGETMethod:@"UpdateUserFeedbackForProduct" andParameter:parameters];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    
    //Responses: GetProductWithID
    if ([methodName isEqualToString:@"GetProductWithID"] && responseDictionary) {
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
            //El producto si está disponible
            NSDictionary *productionDic = responseDictionary[@"products"][@"0"][0];
            NSDictionary *productionDicWithoutNulls = [productionDic dictionaryByReplacingNullWithBlanks];
            self.unparsedProductionInfoDic = productionDicWithoutNulls;
        }
        
    } else if ([methodName isEqualToString:@"IsContentAvailableForUser"] && [responseDictionary[@"status"] boolValue]){
        Video *video = [[Video alloc] initWithDictionary:responseDictionary[@"video"]];
        [self checkVideoAvailability:video];
        
    } else if ([methodName isEqualToString:@"GetRecommendationsWithProductID"] && responseDictionary) {
        NSArray *responseArray = responseDictionary[@"recommended_products"];
        NSArray *arrayWithoutNulls = [responseArray arrayByReplacingNullsWithBlanks];
        self.recommendedProductions = [arrayWithoutNulls mutableCopy];
        
    } else if ([methodName isEqualToString:@"UpdateUserFeedbackForProduct"]) {
        NSLog(@"llegó la info de la calificación: %@", responseDictionary);
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error al conectarse con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error al conectarse con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    alert.tag = 1;
    [alert show];
}

#pragma mark - RateViewDelegate

-(void)rateButtonWasTappedInRateView:(RateView *)rateView withRate:(int)rate {
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

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Facebook
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *message = [NSString stringWithFormat:@"Estoy viendo %@ en CaracolPlay %@", self.production.name, @"https://itunes.apple.com/app/id714489424"];
        [facebookViewController setInitialText:message];
        [self presentViewController:facebookViewController animated:YES completion:nil];
    
    } else if (buttonIndex == 1) {
        //Twitter
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *message = [NSString stringWithFormat:@"Estoy viendo %@ en CaracolPlay %@", self.production.name, @"https://itunes.apple.com/app/id714489424"];
        [twitterViewController setInitialText:message];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
}

#pragma mark - UIAlertViewDelegate 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
