//
//  HomeViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "HomeViewController.h"
#import "Featured.h"
#import "JMImageCache.h"
#import "MoviesEventsDetailsViewController.h"
#import "TelenovelSeriesDetailViewController.h"
#import "MyUtilities.h"
#import "FileSaver.h"
#import "ServerCommunicator.h"
#import "NSDictionary+NullReplacement.h"
#import "MBProgressHUD.h"
#import "UIColor+AppColors.h"

@interface HomeViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *unparsedFeaturedProductionsInfo;
@property (strong, nonatomic) NSMutableArray *parsedFeaturedProductions; //Of Featured
@property (nonatomic) int numberOfPages;
@property (strong, nonatomic) NSTimer *automaticScrollTimer;
@property (nonatomic) NSInteger automaticCounter;
@property (assign, nonatomic) BOOL draggingScrollView;

@property (assign, nonatomic) BOOL firstTimeViewAppears;

@end

@implementation HomeViewController

#pragma mark - Setters 

-(void)setUnparsedFeaturedProductionsInfo:(NSArray *)unparsedFeaturedProductionsInfo {
    _unparsedFeaturedProductionsInfo = unparsedFeaturedProductionsInfo;
    [self parseFeaturedProductionsFromServer];
    [self UISetup];
    [self startScrollingTimer];
    self.automaticCounter = 2;
    self.firstTimeViewAppears = NO;
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

#pragma mark - UI Setup & Initilization Methods

-(void)UISetup {
    
    /*-----------------------------------------------------------*/
    //1. Create a ScrollView to display the main images
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    //Create two pages at the left and right limit of the scroll view, this is used to
    //make the effect of a circular scroll view.
    [self createPageAtPosition:0 withFeaturedProduction:[self.parsedFeaturedProductions lastObject]];
    [self createPageAtPosition:[self.parsedFeaturedProductions count]+1.0 withFeaturedProduction:[self.parsedFeaturedProductions firstObject]];
   
    for (int i = 1; i <= [self.parsedFeaturedProductions count]; i++) {
        Featured *featuredProduction = self.parsedFeaturedProductions[i - 1];
        [self createPageAtPosition:i withFeaturedProduction:featuredProduction];
        self.numberOfPages = i;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*(self.numberOfPages + 2), self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0.0);
    [self.view addSubview:self.scrollView];
    
    //Create a tap gesture and add it to the scroll view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFeaturedProduction:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    
    /*-------------------------------------------------------------*/
    //2. Create a PageControl to display the current page
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame =  CGRectMake(self.view.bounds.size.width/2 - 50.0, self.scrollView.frame.size.height/1.1, 100.0, 30.0);
    self.pageControl.numberOfPages = self.numberOfPages;
    [self.view addSubview:self.pageControl];
    
    /*--------------------------------------------------------------*/
    /*FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Inicio" style:UIBarButtonItemStylePlain target:self action:@selector(backToLogin)];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }*/
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.tabBarController) {
        NSLog(@"EXISTE EL TAB EN EL HOME");
    } else {
        NSLog(@"NO EXISTE EL TAB EN EL HOME");
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    self.firstTimeViewAppears = YES;
    
    //Create a bar button item to recall the getFeaturedProductsFromServer
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NewRefreshIcon"] style:UIBarButtonItemStylePlain
                                                                                          target:self
                                                                                          action:@selector(getFeaturedProductsFromServer)];
    self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
    
    //Start the counter in 2, because the first real page in the scroll view
    //is page 2 (page 1 is used to simulate the last page and make the circular
    //scroll view effect)
    self.automaticCounter = 2;
    [self getFeaturedProductsFromServer];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    //We don't need the timer anymore.
    [self.automaticScrollTimer invalidate];
    self.automaticScrollTimer = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NewNavigationBarBackground"]
                                                  forBarMetrics:UIBarMetricsDefault];
    //Start the automatic scrolling timer
    if (!self.firstTimeViewAppears) {
        [self startScrollingTimer];
    }
}

#pragma mark - Server

-(void)getFeaturedProductsFromServer {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    [serverCommunicator callServerWithGETMethod:@"GetFeatured" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([methodName isEqualToString:@"GetFeatured"]) {
        //NSLog(@"Si recibí info del server: %@", dictionary);
        if (!dictionary) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            //NSLog(@"info de getFeatured: %@", dictionary);
            self.unparsedFeaturedProductionsInfo = dictionary[@"featured"];
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error conectándose con el servidor. Por favor revisa que te encuentres conectado a una red Wi-Fi" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    NSLog(@"Server error: %@ %@", error, [error localizedDescription]);
}

#pragma mark - Custom Methods

-(void)backToLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)startScrollingTimer {
    [self.automaticScrollTimer invalidate];
    self.automaticScrollTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                                 target:self
                                                               selector:@selector(scrollFeaturedProductions)
                                                               userInfo:nil
                                                                repeats:YES];
}

-(void)tappedFeaturedProduction:(UITapGestureRecognizer *)tapGesture {
    
    // Invalidate the automatic scrolling timer
    [self.automaticScrollTimer invalidate];
    self.automaticScrollTimer = nil;
    
    Featured *featuredProduction = self.parsedFeaturedProductions[self.pageControl.currentPage];
    
    if (featuredProduction.isCampaign) {
        NSLog(@"el producto es campaña");
        //If the item is a campaign, we have to open a url externally
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:featuredProduction.campaignURL]]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"No se pudo abrir la URL. por favor intenta de nuevo."
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
        return;
    }
    
    if ([featuredProduction.type isEqualToString:@"Series"] || [featuredProduction.type isEqualToString:@"Telenovelas"] || [featuredProduction.type isEqualToString:@"Noticias"]) {
        //The production is a serie
        TelenovelSeriesDetailViewController *telenovelSeriesDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
        telenovelSeriesDetailVC.serieID = featuredProduction.identifier;
        [self.navigationController pushViewController:telenovelSeriesDetailVC animated:YES];
        
    } else if ([featuredProduction.type isEqualToString:@"Películas"] || [featuredProduction.type isEqualToString:@"Documentales"] || [featuredProduction.type isEqualToString:@"Eventos en vivo"]) {
        //The production is a movie, news or live event
        MoviesEventsDetailsViewController *movieEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
        movieEventDetailsVC.productionID = featuredProduction.identifier;
        [self.navigationController pushViewController:movieEventDetailsVC animated:YES];
    }
}

-(void)createPageAtPosition:(int)pagePosition withFeaturedProduction:(Featured *)featuredProduction {
    //Method used to create the pages of the scroll view.
    
    UIView *page = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*pagePosition,
                                                            0.0,
                                                            self.scrollView.frame.size.width,
                                                            self.scrollView.frame.size.height)];
    /*-------------------------------------------------------------*/
    //1. ImageView to display the main image
    UIImageView *pageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                               0.0,
                                                                               self.scrollView.frame.size.width,
                                                                               self.scrollView.frame.size.width)];
    pageImageView.clipsToBounds = YES;
    pageImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSURL *pageImageURL = [NSURL URLWithString:featuredProduction.imageURL];
    [pageImageView setImageWithURL:pageImageURL key:nil placeholder:[UIImage imageNamed:@"HomeScreenPlaceholder.png"] completionBlock:nil failureBlock:nil];
    [page addSubview:pageImageView];
    
    //Create a view to add a pattern image to the main image view
    UIView *opacityPatternView = [[UIView alloc] init];
    UIImage *opacityPatternImage = nil;
    if (self.view.frame.size.height > 480) {
        opacityPatternView.frame = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        opacityPatternImage = [UIImage imageNamed:@"NewHomeOpacityPattern.png"];
        opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, self.scrollView.frame.size.height)];

    } else {
        opacityPatternView.frame = CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        opacityPatternImage = [UIImage imageNamed:@"iPhone4OpacityPattern.png"];
        opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, opacityPatternView.frame.size.height)];
    }
    opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [page addSubview:opacityPatternView];
    
    // image view for displaying the play icon
    /*UIImageView *playIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, self.scrollView.frame.size.height - 95.0, 55.0, 55)];
    playIconImageView.image = [UIImage imageNamed:@"PlayIconHomeScreen.png"];
    playIconImageView.clipsToBounds = YES;
    playIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [page addSubview:playIconImageView];*/
    
    //2. Label to display the type of video (Series, movie, tv show...)
    UILabel *videoTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0,
                                                                        self.scrollView.frame.size.height - 115.0,
                                                                        self.scrollView.frame.size.width - 30.0,
                                                                        30.0)];
    videoTypeLabel.text = featuredProduction.name.uppercaseString;
    videoTypeLabel.textAlignment = NSTextAlignmentLeft;
    videoTypeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:23.0];
    videoTypeLabel.textColor = [UIColor caracolMediumBlueColor];
    [page addSubview:videoTypeLabel];
    
    //3. Label to display the video name (La selección, Mentiras Perfectas ...)
    UILabel *videoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0,
                                                                        videoTypeLabel.frame.origin.y + 25.0,
                                                                        self.scrollView.frame.size.width - 30.0,
                                                                        30.0)];
    videoNameLabel.text = featuredProduction.type;
    videoNameLabel.textColor = [UIColor whiteColor];
    videoNameLabel.textAlignment = NSTextAlignmentLeft;
    videoNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [page addSubview:videoNameLabel];
    
    //4. Label to display the season and episode of the video (Temporada 3, episodio 4...)
    UILabel *videoInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0,
                                                                        videoTypeLabel.frame.origin.y + 45.0,
                                                                        self.scrollView.frame.size.width - 30.0,
                                                                        30.0)];
    videoInfoLabel.text = featuredProduction.featureText;
    videoInfoLabel.textAlignment = NSTextAlignmentLeft;
    videoInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0];
    videoInfoLabel.textColor = [UIColor lightGrayColor];
    [page addSubview:videoInfoLabel];
    
    [self.scrollView addSubview:page];
}

-(void)scrollFeaturedProductions {
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width*self.automaticCounter, 0.0) animated:YES];
    self.automaticCounter ++;
    NSLog(@"el contador está en %d", self.automaticCounter);
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"Offset: %f", scrollView.contentOffset.y);
    float pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lroundf(fractionalPage);
    self.pageControl.currentPage = page - 1;
    
    //NSLog(@"Content offset: %f", scrollView.contentOffset.y);
    if (self.draggingScrollView && scrollView.contentOffset.y != 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0.0) animated:NO];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"terminé de animarme");
    if (self.scrollView.contentOffset.x < self.view.bounds.size.width) {
        //the user scroll from page 1 to the left, so we have to set the content offset
        //of the scroll view to the last page
        [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width*self.numberOfPages, 0.0) animated:NO];
        self.pageControl.currentPage = [self.parsedFeaturedProductions count] - 1;
    } else if (self.scrollView.contentOffset.x >= self.view.bounds.size.width * (self.numberOfPages + 1)) {
        NSLog(@"llegué al final");
        [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, 0.0) animated:NO];
        self.pageControl.currentPage = 0;
        self.automaticCounter = 2;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"empezé a draggearme");
    [self.automaticScrollTimer invalidate];
    self.automaticScrollTimer = nil;
    self.draggingScrollView = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollView.contentOffset.x < self.view.bounds.size.width) {
        //the user scroll from page 1 to the left, so we have to set the content offset
        //of the scroll view to the last page
        [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width*self.numberOfPages, 0.0) animated:NO];
        self.pageControl.currentPage = [self.parsedFeaturedProductions count] - 1;
    } else if (self.scrollView.contentOffset.x >= self.view.bounds.size.width * (self.numberOfPages + 1)) {
        [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width, 0.0) animated:NO];
        self.pageControl.currentPage = 0;
    }
    NSLog(@"Estoy en la página %d", self.pageControl.currentPage);
    self.automaticCounter = self.pageControl.currentPage + 2;
    NSLog(@"el contador está en %d", self.automaticCounter);
    [self startScrollingTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.draggingScrollView = NO;
}

#pragma mark - Interface Orientation

- (NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end

