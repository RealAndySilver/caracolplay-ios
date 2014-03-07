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

NSString *const moviesCellIdentifier = @"CellIdentifier";

@interface MovieDetailsPadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, RateViewDelegate>
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

@property (strong, nonatomic) NSDictionary *productionInfo;
@property (strong, nonatomic) NSArray *recommendedProductions;
@property (strong, nonatomic) Product *production;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) StarsView *starsView;
@end

@implementation MovieDetailsPadViewController

#pragma mark - Lazy Instantiation

-(NSDictionary *)productionInfo {
    if (!_productionInfo) {
        _productionInfo = @{@"name": @"Colombia's Next Top Model", @"type" : @"Series", @"rate" : @5, @"my_rate" : @3, @"category_id" : @"59393",
                            @"id" : @"567", @"image_url" : @"http://static.cromos.com.co/sites/cromos.com.co/files/images/2013/01/ba6538c2bf4d087330be745adfa8d0bd.jpg", @"trailer_url" : @"", @"has_seasons" : @NO, @"description" : @"Colombia's Next Top Model (a menudo abreviado como CNTM), fue un reality show de Colombia basado el en popular formato estadounidense America's Next Top Model en el que un número de mujeres compite por el título de Colombia's Next Top Model y una oportunidad para iniciar su carrera en la industria del modelaje", @"episodes" : @[], @"season_list" : @[]};
    }
    return _productionInfo;
}

-(NSArray *)recommendedProductions {
    if (!_recommendedProductions) {
        _recommendedProductions = @[@{@"name": @"Pedro el Escamoso",@"type": @"Series", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://compass-images-1.comcast.net/ccp_img/pkr_prod/VMS_POC_Image_Ingest/9/258/escobar_el_patron_del_mal_21_3000x1500_16613258.jpg"},
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Peliculas", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://www.eltiempo.com/entretenimiento/tv/IMAGEN/IMAGEN-8759821-2.png"},
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Series", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://www.bluradio.com/sites/default/files/la_voz_colombia.jpg"},
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Peliculas", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://hispanic-tv.jumptv.com/images/2008/09/18/diaadiatucasa_2.png"},
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Series", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://compass-images-1.comcast.net/ccp_img/pkr_prod/VMS_POC_Image_Ingest/9/258/escobar_el_patron_del_mal_21_3000x1500_16613258.jpg"},
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Peliculas", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://www.eltiempo.com/entretenimiento/tv/IMAGEN/IMAGEN-8759821-2.png"},
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Series", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://www.bluradio.com/sites/default/files/la_voz_colombia.jpg"},
];
    }
    return _recommendedProductions;
}

-(void)parseProductionInfo {
    self.production = [[Product alloc] initWithDictionary:self.productionInfo];
}

-(void)UISetup {
    //1. Dismiss button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //2. Background image view
    self.backgroundImageView = [[UIImageView alloc] init];
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:nil completionBlock:nil failureBlock:nil];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //3. add a UIView to opaque the background view
    self.opaqueView = [[UIView alloc] init];
    self.opaqueView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.backgroundImageView addSubview:self.opaqueView];
    
    //3. small production image view
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 30.0, 160.0, 260.0)];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    shadowView.layer.shadowRadius = 6.0;
    shadowView.layer.shadowOpacity = 0.8;
    [self.view addSubview:shadowView];
    
    UIImageView *smallProductionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, shadowView.frame.size.width, shadowView.frame.size.height)];
    [smallProductionImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL]
                                       placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
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
    
    //Stars view
    self.starsView = [[StarsView alloc] initWithFrame:CGRectMake(210.0, 55.0, 100.0, 50.0) rate:[self.production.myRate intValue]];
    [self.view addSubview:self.starsView];
    UITapGestureRecognizer *starsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRateView)];
    [self.starsView addGestureRecognizer:starsTapGesture];
    
    //Create a tap gesture and add it to the small image view, so when the user touches the image,
    //a larger image will be displayed
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [smallProductionImageView addGestureRecognizer:tapGesture];
    
    //4. Production name label setup
    self.productionNameLabel = [[UILabel alloc] init];
    self.productionNameLabel.text = self.production.name;
    self.productionNameLabel.textColor = [UIColor whiteColor];
    self.productionNameLabel.font = [UIFont boldSystemFontOfSize:25.0];
    [self.view addSubview:self.productionNameLabel];
    
    //5. Watch Trailer button setup
    self.watchTrailerButton = [[UIButton alloc] init];
    [self.watchTrailerButton setTitle:@"▶︎ Ver Trailer" forState:UIControlStateNormal];
    [self.watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.watchTrailerButton addTarget:self action:@selector(watchTrailer) forControlEvents:UIControlEventTouchUpInside];
    
    self.watchTrailerButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.watchTrailerButton.layer.shadowOpacity = 0.8;
    self.watchTrailerButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.watchTrailerButton.layer.shadowRadius = 5.0;
    
    [self.view addSubview:self.watchTrailerButton];
    
    //6. Share button
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    
    self.shareButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shareButton.layer.shadowOpacity = 0.8;
    self.shareButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.shareButton.layer.shadowRadius = 5.0;
    [self.view addSubview:self.shareButton];
    
    //View production button
    self.viewProductionButton = [[UIButton alloc] init];
    [self.viewProductionButton setTitle:@"▶︎ Ver Producción" forState:UIControlStateNormal];
    [self.viewProductionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.viewProductionButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.viewProductionButton addTarget:self action:@selector(watchProduction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewProductionButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    
    self.viewProductionButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.viewProductionButton.layer.shadowOpacity = 0.8;
    self.viewProductionButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.viewProductionButton.layer.shadowRadius = 5.0;
    [self.view addSubview:self.viewProductionButton];
    
    
    //7. Productiond etail textview setup
    self.productionDetailTextView = [[UITextView alloc] init];
    self.productionDetailTextView.text = self.production.detailDescription;
    /*self.productionDetailTextView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel neque interdum quam auctor ultricies. Donec eget scelerisque leo, sed commodo nibh. Suspendisse potenti. Morbi vitae est ac ipsum mollis vulputate eget commodo elit. Donec magna justo, semper sit amet libero eget, tempus condimentum ipsum. Aenean lobortis eget justo sed mattis. Suspendisse eget libero eget est imperdiet dignissim vel quis erat.";*/
    self.productionDetailTextView.textColor = [UIColor whiteColor];
    self.productionDetailTextView.userInteractionEnabled = NO;
    self.productionDetailTextView.backgroundColor = [UIColor clearColor];
    self.productionDetailTextView.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.productionDetailTextView];
    
    //9. Recommended productions label setup
    self.recommendedProductionsLabel = [[UILabel alloc] init];
    self.recommendedProductionsLabel.text = @"Producciones Recomendadas";
    self.recommendedProductionsLabel.textColor = [UIColor whiteColor];
    self.recommendedProductionsLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.view addSubview:self.recommendedProductionsLabel];
    
    //10.0 collecitionView setup
    self.collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:moviesCellIdentifier];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    [self.view addSubview:self.collectionView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self parseProductionInfo];
    [self UISetup];
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
    self.shareButton.frame = CGRectMake(360.0, 100.0, 130.0, 35.0);
    self.viewProductionButton.frame = CGRectMake(510.0, 100.0, 130.0, 35.0);
    self.productionDetailTextView.frame = CGRectMake(210.0, 150.0, self.view.bounds.size.width - 210.0, 100.0);
    self.recommendedProductionsLabel.frame = CGRectMake(20.0, 360.0, 250.0, 30.0);
    self.collectionView.frame = CGRectMake(0.0, 370.0, self.view.bounds.size.width, self.view.bounds.size.height - 370.0);
}

#pragma mark - Custom Methods 

-(void)goToVideo {
    VideoPlayerPadViewController *videoPlayerPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
    [self presentViewController:videoPlayerPadVC animated:YES completion:nil];
}

#pragma mark - Actions

-(void)watchProduction {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        SuscriptionAlertPadViewController *suscriptionAlertPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlertPad"];
        suscriptionAlertPadVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        suscriptionAlertPadVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:suscriptionAlertPadVC animated:YES completion:nil];
        /*[[[UIAlertView alloc] initWithTitle:nil message:@"Para poder ver la producción debes ingresar con tu usuario." delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ingresar", nil] show];*/
        return;
    }
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para poder ver la producción debes estar conectado a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else if (status == ReachableViaWWAN) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Tu conexión es muy lenta. Por favor conéctate a una red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else if (status == ReachableViaWiFi) {
        [self goToVideo];
    }
}

-(void)watchTrailer {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para poder ver el trailer de esta producción debes estar conectado a internet" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        [self goToVideo];
    }
}

-(void)showRateView {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.6;
    [self.view addSubview:self.opacityView];
    RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100.0, self.view.frame.size.height/2 - 50.0, 200.0, 120.0) goldStars:[self.production.myRate intValue]];
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
    [imageView setImageWithURL:[NSURL URLWithString:self.recommendedProductions[indexPath.item][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
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
    NSLog(@"Seleccioné el item %d", indexPath.item);
    if ([self.recommendedProductions[indexPath.item][@"type"] isEqualToString:@"Series"]) {
        SeriesDetailPadViewController *seriesDetailPad = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
        seriesDetailPad.modalPresentationStyle = UIModalPresentationFormSheet;
        seriesDetailPad.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:seriesDetailPad animated:YES completion:nil];
        
    } else if ([self.recommendedProductions[indexPath.item][@"type"] isEqualToString:@"Peliculas"]) {
        MovieDetailsPadViewController *movieDetailsPad = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
        movieDetailsPad.modalPresentationStyle = UIModalPresentationFormSheet;
        movieDetailsPad.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:movieDetailsPad animated:YES completion:nil];
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
