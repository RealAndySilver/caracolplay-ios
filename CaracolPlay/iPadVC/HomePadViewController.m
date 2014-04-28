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
#import "ServerCommunicator.h"
#import "NSDictionary+NullReplacement.h"
#import "MyListsDetailPadViewController.h"
#import "MyListsMasterPadViewController.h"
#import "MorePadMasterViewController.h"
#import "MyAccountDetailPadViewController.h"

@interface HomePadViewController () <iCarouselDataSource, iCarouselDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *unparsedFeaturedProductionsInfo;
@property (strong, nonatomic) NSMutableArray *parsedFeaturedProductions;
@property (strong, nonatomic) NSTimer *carouselScrollingTimer;
@property (strong, nonatomic) iCarousel *carousel;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIImageView *opacityView;
@end

@implementation HomePadViewController

#define SCREEN_WIDTH 1024.0
#define SCREEN_HEIGHT 768.0

#pragma mark - Setters & Getters

-(void)setUnparsedFeaturedProductionsInfo:(NSArray *)unparsedFeaturedProductionsInfo {
    _unparsedFeaturedProductionsInfo = unparsedFeaturedProductionsInfo;
    [self parseFeaturedProductionsFromServer];
    [self UISetup];
}

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(SCREEN_WIDTH/2.0 - 20.0, SCREEN_HEIGHT/2.0 - 20.0, 40.0, 40.0);
    }
    return _spinner;
}

#pragma mark - UI Setup & Initilization Methods

-(void)setupAutomaticCarouselScrolling {
    self.carouselScrollingTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(scrollCarousel) userInfo:nil repeats:YES];
}

-(void)parseFeaturedProductionsFromServer {
    self.parsedFeaturedProductions = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedFeaturedProductionsInfo count]; i++) {
        NSDictionary *featuredProdDicWithNulls = self.unparsedFeaturedProductionsInfo[i];
        NSDictionary *featuredProdDicWithoutNulls = [featuredProdDicWithNulls dictionaryByReplacingNullWithBlanks];
        Featured *featuredProduction = [[Featured alloc] initWithDictionary:featuredProdDicWithoutNulls];
        [self.parsedFeaturedProductions addObject:featuredProduction];
    }
    NSLog(@"Numero de producciones destacas: %lu", (unsigned long)[self.parsedFeaturedProductions count]);
}

-(void)UISetup {
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
}

#pragma  mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.spinner];
    
    //Add as an observer of the notification center to create the
    //the aditional tabs of the tab bar controller when neccesaty
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createAditionalTabs)
                                                 name:@"CreateAditionalTabsNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeOpacityView)
                                                 name:@"RemoveOpacityView"
                                               object:nil];
    
    //1. background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HomeScreenBackgroundPad.png"]];
    self.backgroundImageView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT - 44.0);
    [self.view addSubview:self.backgroundImageView];
    
    //Create a reload button
    UIButton *reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(800.0, 35.0, 44.0, 44.0)];
    [reloadButton setBackgroundImage:[UIImage imageNamed:@"RefreshIcon.png"] forState:UIControlStateNormal];
    [reloadButton addTarget:self action:@selector(getFeaturedFromServer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reloadButton];
    
    //Call server
    [self getFeaturedFromServer];
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

-(void)scrollCarousel {
    [self.carousel scrollByNumberOfItems:1 duration:1.0];
}

#pragma mark - Server stuff

-(void)getFeaturedFromServer {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetFeatured" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    
    //NSLog(@"Recibí info del servidor: %@", responseDictionary);
    if ([methodName isEqualToString:@"GetFeatured"] && responseDictionary) {
        self.unparsedFeaturedProductionsInfo = responseDictionary[@"featured"];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"En este momento no es posible acceder a las producciones destacadas. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    
    NSLog(@"server error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"En este momento no es posible acceder a las producciones destacadas. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handlers 

-(void)removeOpacityView {
    [self.opacityView removeFromSuperview];
}

-(void)createAditionalTabs {
    NSLog(@"crearé los tabs adicionale");
    //This method create the two aditional tab bars in the tab bar. this is neccesary because
    //when the user is logout, we activate just three tabs, but when the user is log in, we activate
    //the five tabs.
    
    //4. MyLists View
    UISplitViewController *myListsSplitViewController = [[UISplitViewController alloc] init];
    MyListsMasterPadViewController *myListsMasterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsMaster"];
    MyListsDetailPadViewController *myListsDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsDetail"];
    myListsSplitViewController.viewControllers = @[myListsMasterVC, myListsDetailVC];
    myListsSplitViewController.tabBarItem.title = @"Mis Listas";
    myListsSplitViewController.tabBarItem.image = [UIImage imageNamed:@"MyListsTabBarIcon.png"];
    myListsSplitViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"MyListsTabBarIconSelected.png"];
    
    //5 'Mas' splitview controller
    UISplitViewController *moreSplitViewController = [[UISplitViewController alloc] init];
    MorePadMasterViewController *morePadViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MorePadMaster"];
    MyAccountDetailPadViewController *myAccountDetailPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAccountDetailPad"];
    moreSplitViewController.viewControllers = @[morePadViewController, myAccountDetailPadVC];
    moreSplitViewController.tabBarItem.title = @"Más";
    moreSplitViewController.tabBarItem.image = [UIImage imageNamed:@"MoreTabBarIcon.png"];
    moreSplitViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"MoreTabBarIconSelected.png"];
    
    NSMutableArray *viewControllersArray = [self.tabBarController.viewControllers mutableCopy];
    [viewControllersArray addObject:myListsSplitViewController];
    [viewControllersArray addObject:moreSplitViewController];
    self.tabBarController.viewControllers = viewControllersArray;
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
    UIView *opacityPatternView = [[UIView alloc] initWithFrame:CGRectMake(0.0, view.bounds.size.height - 150.0, view.bounds.size.width, 150.0)];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"OpacityPattern.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, 150.0)];
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
    self.opacityView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.opacityView.image = [UIImage imageNamed:@"OpacityBackground.png"];
    self.opacityView.alpha = 0.7;
    [self.tabBarController.view addSubview:self.opacityView];
    
    //Stop the automatic scrolling of the carousel
    [self.carouselScrollingTimer invalidate];
    self.carouselScrollingTimer = nil;
    Featured *selectedProduction = self.parsedFeaturedProductions[index];
    
    if (selectedProduction.isCampaign) {
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:((Featured *)self.parsedFeaturedProductions[index]).campaignURL]]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Error abriendo la URL. Por favor intenta de nuevo" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        return;
    }
    
    if ([selectedProduction.type isEqualToString:@"Series"] || [selectedProduction.type isEqualToString:@"Telenovelas"] || [selectedProduction.type isEqualToString:@"Noticias"]) {
        SeriesDetailPadViewController *seriesDetailPad = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
        seriesDetailPad.modalPresentationStyle = UIModalPresentationPageSheet;
        seriesDetailPad.productID = selectedProduction.identifier;
        [self presentViewController:seriesDetailPad animated:YES completion:nil];
        
    } else if ([selectedProduction.type isEqualToString:@"Películas"] || [selectedProduction.type isEqualToString:@"Eventos en vivo"]) {
        MovieDetailsPadViewController *movieDetailPad = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
        movieDetailPad.modalPresentationStyle = UIModalPresentationPageSheet;
        movieDetailPad.productID = selectedProduction.identifier;
        [self presentViewController:movieDetailPad animated:YES completion:nil];
    }
}

@end
