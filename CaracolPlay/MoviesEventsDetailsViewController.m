//
//  MoviesEventsViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MoviesEventsDetailsViewController.h"
#import "Product.h"
#import "JMImageCache.h"
#import "RateView.h"
#import "LargeProductionImageView.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface MoviesEventsDetailsViewController () <UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, RateViewDelegate>
@property (strong, nonatomic) Product *production;
@property (strong, nonatomic) NSDictionary *productionInfo;
@property (strong, nonatomic) NSArray *recommendedProductions;
@property (strong, nonatomic) UIView *opacityView;
/*@property (strong, nonatomic) FXBlurView *blurView;
@property (strong, nonatomic) FXBlurView *tabBarBlurView;
@property (strong, nonatomic) FXBlurView *navigationBarBlurView;*/
@end

@implementation MoviesEventsDetailsViewController

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
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Series", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://www.eltiempo.com/entretenimiento/tv/IMAGEN/IMAGEN-8759821-2.png"},
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Series", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://www.bluradio.com/sites/default/files/la_voz_colombia.jpg"},
                                    
                                    @{@"name": @"Pedro el Escamoso",@"type": @"Series", @"id": @"90182734", @"rate": @3, @"category_id": @"823714",
                                      @"image_url": @"http://hispanic-tv.jumptv.com/images/2008/09/18/diaadiatucasa_2.png"}];
    }
    return _recommendedProductions;
}

-(void)parseProductionInfo {
    self.production = [[Product alloc] initWithDictionary:self.productionInfo];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self parseProductionInfo];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = self.production.name;
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    //self.navigationBarBlurView.frame = self.navigationController.navigationBar.bounds;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    /*[self.blurView removeFromSuperview];
    [self.navigationBarBlurView removeFromSuperview];
    [self.tabBarBlurView removeFromSuperview];*/
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
    
    //Create a tap gesture and add it to our secondary image view
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
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
    [self createStarsImageViewsWithGoldStarsNumber:[self.production.rate intValue]];
    
    //'calificar' button setup
    UIButton *rateButton = [[UIButton alloc] initWithFrame:CGRectMake(260.0, 112.0, 50.0, 30.0)];
    [rateButton setTitle:@"Calificar" forState:UIControlStateNormal];
    [rateButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [rateButton addTarget:self action:@selector(showRateView) forControlEvents:UIControlEventTouchUpInside];
    rateButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
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
    
    //8. Create a background view and set it's color to gray
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, detailTextView.frame.origin.y + detailTextView.frame.size.height + 20.0, self.view.frame.size.width, self.view.frame.size.height - (detailTextView.frame.origin.y + detailTextView.frame.size.height) - 44.0)];
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
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 30.0, grayView.frame.size.width, grayView.frame.size.height - 44.0 - 30.0) collectionViewLayout:collectionViewFlowLayout];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.dataSource = self;
    [collectionView registerClass:[RecommendedProdCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [grayView addSubview:collectionView];
    
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
    
    [cell.cellImageView setImageWithURL:[NSURL URLWithString:self.recommendedProductions[indexPath.row][@"image_url"]] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100.0, 130.0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MoviesEventsDetailsViewController *moviesEventDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
    [self.navigationController pushViewController:moviesEventDetail animated:YES];
}

#pragma mark - Custom Methods

-(void)imageTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    LargeProductionImageView *largeProdView = [[LargeProductionImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [largeProdView.largeImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL]
                                      placeholder:nil
                                  completionBlock:nil
                                     failureBlock:nil];
    [self.tabBarController.view addSubview:largeProdView];
}

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120 + (i*20),
                                                                                   110.0,
                                                                                   20.0,
                                                                                   20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars > i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        } else {
            starImageView.tintColor = [UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:starImageView];
        [self.view bringSubviewToFront:starImageView];
    }
}

-(void)showRateView {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.bounds];
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
