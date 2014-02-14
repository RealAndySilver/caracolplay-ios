//
//  MovieDetailsViewController.m
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MovieDetailsPadViewController.h"
#import "SeriesDetailPadViewController.h"
#import <Social/Social.h>
#import "Product.h"
#import "JMImageCache.h"
#import "LargeProductionImageView.h"
#import "RateView.h"
#import "StarsView.h"

NSString *const moviesCellIdentifier = @"CellIdentifier";

@interface MovieDetailsPadViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, RateViewDelegate>
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *opaqueView;
@property (strong, nonatomic) UIImageView *smallProductionImageView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) UIButton *watchTrailerButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *rateButton;
@property (strong, nonatomic) UITextView *productionDetailTextView;
@property (strong, nonatomic) UILabel *recommendedProductionsLabel;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property (strong, nonatomic) NSDictionary *productionInfo;
@property (strong, nonatomic) NSArray *recommendedProductions;
@property (strong, nonatomic) Product *production;
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation MovieDetailsPadViewController

#pragma mark - Lazy Instantiation

-(NSDictionary *)productionInfo {
    if (!_productionInfo) {
        _productionInfo = @{@"name": @"Colombia's Next Top Model", @"type" : @"Series", @"rate" : @5, @"my_rate" : @3, @"category_id" : @"59393",
                            @"id" : @"567", @"image_url" : @"http://static.cromos.com.co/sites/cromos.com.co/files/images/2013/01/ba6538c2bf4d087330be745adfa8d0bd.jpg", @"trailer_url" : @"", @"has_seasons" : @NO, @"description" : @"Esta es la descripción de la producción", @"episodes" : @[], @"season_list" : @[]};
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
    [self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
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
    self.smallProductionImageView = [[UIImageView alloc] init];
    [self.smallProductionImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL]
                                       placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    self.smallProductionImageView.clipsToBounds = YES;
    self.smallProductionImageView.userInteractionEnabled = YES;
    self.smallProductionImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.smallProductionImageView];
    
    //Stars view
    StarsView *starsView = [[StarsView alloc] initWithFrame:CGRectMake(170.0, 65.0, 100.0, 50.0) rate:[self.production.rate intValue]];
    [self.view addSubview:starsView];
    
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
    
    //Rate button
    self.rateButton = [[UIButton alloc] init];
    [self.rateButton setTitle:@"Calificar" forState:UIControlStateNormal];
    [self.rateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rateButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.rateButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.rateButton addTarget:self action:@selector(showRateView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rateButton];
    
    //5. Watch Trailer button setup
    self.watchTrailerButton = [[UIButton alloc] init];
    [self.watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    [self.watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.watchTrailerButton];
    
    //6. Share button
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.shareButton];
    
    //7. Productiond etail textview setup
    self.productionDetailTextView = [[UITextView alloc] init];
    self.productionDetailTextView.text = self.production.detailDescription;
    /*self.productionDetailTextView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel neque interdum quam auctor ultricies. Donec eget scelerisque leo, sed commodo nibh. Suspendisse potenti. Morbi vitae est ac ipsum mollis vulputate eget commodo elit. Donec magna justo, semper sit amet libero eget, tempus condimentum ipsum. Aenean lobortis eget justo sed mattis. Suspendisse eget libero eget est imperdiet dignissim vel quis erat.";*/
    self.productionDetailTextView.textColor = [UIColor whiteColor];
    self.productionDetailTextView.backgroundColor = [UIColor clearColor];
    self.productionDetailTextView.font = [UIFont systemFontOfSize:17.0];
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
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 650.0, 450.0);
    
    //Set subviews frame
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 25.0, 0.0, 25.0, 25.0);
    self.backgroundImageView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height/2 + 50.0);
    self.opaqueView.frame = self.backgroundImageView.frame;
    self.smallProductionImageView.frame = CGRectMake(30.0, 30.0, 120.0, 185.0);
    self.productionNameLabel.frame = CGRectMake(170.0, 25.0, self.view.bounds.size.width - 180.0, 30.0);
    self.rateButton.frame = CGRectMake(330.0, 60.0, 140.0, 35.0);
    self.watchTrailerButton.frame = CGRectMake(170.0, 100.0, 140.0, 35.0);
    self.shareButton.frame = CGRectMake(330.0, 100.0, 140.0, 35.0);
    self.productionDetailTextView.frame = CGRectMake(170.0, 150.0, 450.0, 100.0);
    self.recommendedProductionsLabel.frame = CGRectMake(30.0, 280.0, 250.0, 30.0);
    self.collectionView.frame = CGRectMake(0.0, 310.0, self.view.bounds.size.width, self.view.bounds.size.height - 310.0);
}

#pragma mark - Actions 

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
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    [imageView setImageWithURL:[NSURL URLWithString:self.recommendedProductions[indexPath.item][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:imageView];
    return cell;
}

#pragma  mark - UICollectionViewDelegate 

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100.0, 120.0);
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
