//
//  HomePadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "HomePadViewController.h"
#import "iCarousel.h"
#import "MyUtilities.h"
#import "Featured.h"
#import "JMImageCache.h"
#import "MovieDetailsPadViewController.h"
#import "SeriesDetailPadViewController.h"
#import "FileSaver.h"

@interface HomePadViewController () <iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *unparsedFeaturedProductionsInfo;
@property (strong, nonatomic) NSMutableArray *parsedFeaturedProductions;
@property (strong, nonatomic) NSTimer *carouselScrollingTimer;
@property (strong, nonatomic) iCarousel *carousel;
@end

@implementation HomePadViewController

#define SCREEN_WIDTH 1024.0
#define SCREEN_HEIGHT 768.0

#pragma mark - Lazy Instantiation

-(NSArray *)unparsedFeaturedProductionsInfo {
    if (!_unparsedFeaturedProductionsInfo) {
        _unparsedFeaturedProductionsInfo = @[@{@"name": @"Mentiras Perfectas", @"type" : @"Series", @"feature_text": @"No te pierdas...", @"id": @"210",
                                               @"rate" : @3, @"category_id" : @"32224", @"image_url" : @"http://st.elespectador.co/files/imagecache/727x484/1933d136b94594f2db6f9145bbf0f72a.jpg", @"is_campaign" : @YES, @"campaign_url" : @"http://www.caracoltv.com/programas/realities-y-concursos/colombia-next-top-model-2014/presentador/carolina-cruz"},
                                             
                                             @{@"name": @"Colombia's Next Top Model", @"type" : @"Series", @"feature_text": @"Las modelos...", @"id": @"211",
                                               @"rate" : @5, @"category_id" : @"3775", @"image_url" : @"http://esteeselpunto.com/wp-content/uploads/2013/02/Final-Colombia-Next-Top-Model-1024x871.png", @"is_campaign" : @NO, @"campaign_url" : @"http://www.caracoltv.com/programas/realities-y-concursos/colombia-next-top-model-2014/presentador/carolina-cruz"},
                                             
                                             @{@"name": @"Yo me llamo", @"type" : @"Series", @"feature_text": @"Primer episodio", @"id": @"211",
                                               @"rate" : @5, @"category_id" : @"33275", @"image_url" : @"http://www.ecbloguer.com/diablog/wp-content/uploads/2012/01/Yo-me-llamo-DiabloG.jpg", @"is_campaign" : @NO, @"campaign_url" : @"http://www.caracoltv.com/programas/realities-y-concursos/colombia-next-top-model-2014/presentador/carolina-cruz"},
                                             
                                             @{@"name": @"La ronca de oro", @"type" : @"Peliculas", @"feature_text": @"Llega la ronca", @"id": @"211",
                                               @"rate" : @5, @"category_id" : @"33275", @"image_url" : @"http://2.bp.blogspot.com/-q96yFMADKm8/Urt_ZYchqWI/AAAAAAAADY0/Oe6F-0PQdRc/s1600/caracol%2B-%2Bla%2Bronca%2Bde%2Boro.png", @"is_campaign" : @NO, @"campaign_url" : @"http://www.caracoltv.com/programas/realities-y-concursos/colombia-next-top-model-2014/presentador/carolina-cruz"},
                                             
                                             @{@"name": @"Tu Voz Estéreo", @"type" : @"Series", @"feature_text": @"Los últimos casos...", @"id": @"211",
                                               @"rate" : @5, @"category_id" : @"33275", @"image_url" : @"http://static.canalcaracol.com/sites/caracoltv.com/files/imgs_12801024/fdb9f15a1610815e39b2dcbb298e223f.jpg", @"is_campaign" : @NO, @"campaign_url" : @"http://www.caracoltv.com/programas/realities-y-concursos/colombia-next-top-model-2014/presentador/carolina-cruz"}];
    }
    return _unparsedFeaturedProductionsInfo;
}

#pragma mark - UI Setup & Initilization Methods

-(void)setupAutomaticCarouselScrolling {
    self.carouselScrollingTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(scrollCarousel) userInfo:nil repeats:YES];
}

-(void)parseFeaturedInfo {
    self.parsedFeaturedProductions = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedFeaturedProductionsInfo count]; i++) {
        Featured *featuredProduction = [[Featured alloc] initWithDictionary:self.unparsedFeaturedProductionsInfo[i]];
        [self.parsedFeaturedProductions addObject:featuredProduction];
    }
}


-(void)UISetup {
    //1. background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HomeScreenBackgroundPad.png"]];
    self.backgroundImageView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT - 44.0);
    [self.view addSubview:self.backgroundImageView];
    
    //2. Carousel setup
    self.carousel = [[iCarousel alloc] init];
    self.carousel.type = iCarouselTypeRotary;
    self.carousel.scrollSpeed = 0.5;
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    [self.view addSubview:self.carousel];
    
    //3. page control setup
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = [self.parsedFeaturedProductions count];
    [self.view addSubview:self.pageControl];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, 30.0, 100.0, 44.0)];
        [backButton setTitle:@"◀︎Volver" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backButton];
    }
}

#pragma  mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self parseFeaturedInfo];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupAutomaticCarouselScrolling];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.carouselScrollingTimer invalidate];
    self.carouselScrollingTimer = nil;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.pageControl.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height - 100.0, 300.0, 30.0);
    self.carousel.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0);
    NSLog(@"carousel frame: %@", NSStringFromCGRect(self.carousel.frame));
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)scrollCarousel {
    [self.carousel scrollByNumberOfItems:1 duration:1.0];
}

#pragma mark - iCarouselDataSource

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.parsedFeaturedProductions count];
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
    if (!view) {
        view = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 500.0, 500.0)];
    }
    Featured *featuredProduction = self.parsedFeaturedProductions[index];
    
    //Main Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.frame];
    [imageView setImageWithURL:[NSURL URLWithString:featuredProduction.imageURL] placeholder:[UIImage imageNamed:@"HomeScreenPlaceholder.png"] completionBlock:nil failureBlock:nil];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [view addSubview:imageView];
    
    //Add an opacity pattern to the view to be able to read everything
    UIView *opacityPatternView = [[UIView alloc] initWithFrame:view.bounds];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"OpacityPattern.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, view.bounds.size.height)];
    opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [view addSubview:opacityPatternView];
    
    //Add the play icon
    UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, view.frame.size.height - 120.0, 100.0, 100.0)];
    playIcon.image = [UIImage imageNamed:@"PlayIconHomeScreenPad.png"];
    playIcon.clipsToBounds = YES;
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:playIcon];
    
    //Type of production label
    UILabel *productionTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 380.0, 100.0, 30.0)];
    productionTypeLabel.text = featuredProduction.type;
    productionTypeLabel.textColor = [UIColor whiteColor];
    productionTypeLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [view addSubview:productionTypeLabel];
    
    //Production name label
    UILabel *productionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 410.0, 300.0, 30.0)];
    productionNameLabel.text = featuredProduction.name;
    productionNameLabel.textColor = [UIColor whiteColor];
    productionNameLabel.font = [UIFont boldSystemFontOfSize:22.0];
    [view addSubview:productionNameLabel];
    
    //production season/episode
    UILabel *seasonEpisodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 440.0, 300.0, 30.0)];
    seasonEpisodeLabel.text = featuredProduction.featureText;
    seasonEpisodeLabel.textColor = [UIColor whiteColor];
    seasonEpisodeLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [view addSubview:seasonEpisodeLabel];

    return view;
}

-(CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionFadeMin:
            return -0.2;
            
        case iCarouselOptionFadeMax:
            return 0.2;
            
        case iCarouselOptionFadeRange:
            return 1.0;
            
            /*case iCarouselOptionFadeMinAlpha:
             return 0.2;*/
            
        case iCarouselOptionSpacing:
            return 0.5;
            
        default:
            return value;
    }
}

#pragma mark - UICarouselDelegate

-(void)carouselWillBeginDragging:(iCarousel *)carousel {
    NSLog(@"me empezaron a draggear");
    [self.carouselScrollingTimer invalidate];
    self.carouselScrollingTimer = nil;
}

-(void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    NSLog(@"me terminaron de draggear");
    [self setupAutomaticCarouselScrolling];
}

-(void)carouselDidScroll:(iCarousel *)carousel {
    self.pageControl.currentPage = carousel.currentItemIndex;
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    //Stop the automatic scrolling of the carousel
    [self.carouselScrollingTimer invalidate];
    self.carouselScrollingTimer = nil;
    
    if (((Featured *)self.parsedFeaturedProductions[index]).isCampaign) {
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:((Featured *)self.parsedFeaturedProductions[index]).campaignURL]]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Error abriendo la URL. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        return;
    }
    
    if ([((Featured *)self.parsedFeaturedProductions[index]).type isEqualToString:@"Series"]) {
        SeriesDetailPadViewController *seriesDetailPad = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
        seriesDetailPad.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:seriesDetailPad animated:YES completion:nil];
    } else if ([((Featured *)self.parsedFeaturedProductions[index]).type isEqualToString:@"Peliculas"]) {
        MovieDetailsPadViewController *movieDetailPad = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
        movieDetailPad.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:movieDetailPad animated:YES completion:nil];
    }
}

@end
