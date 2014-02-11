//
//  HomeViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "HomeViewController.h"
#import "Featured.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "JMImageCache.h"

@interface HomeViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *unparsedFeaturedProductionsInfo;
@property (strong, nonatomic) NSMutableArray *parsedFeaturedProductions; //Of Featured
@property (nonatomic) int numberOfPages;
@end

@implementation HomeViewController

#pragma mark - Lazy Instantiation

-(NSArray *)unparsedFeaturedProductionsInfo {
    if (!_unparsedFeaturedProductionsInfo) {
        _unparsedFeaturedProductionsInfo = @[@{@"name": @"Mentiras Perfectas", @"type" : @"Series", @"feature_text": @"No te pierdas...", @"id": @"210",
                                        @"rate" : @3, @"category_id" : @"32224", @"image_url" : @"http://st.elespectador.co/files/imagecache/727x484/1933d136b94594f2db6f9145bbf0f72a.jpg", @"is_campaign" : @NO, @"campaign_url" : @""},
                                      
                                             @{@"name": @"Colombia's Next Top Model", @"type" : @"Series", @"feature_text": @"Las modelos...", @"id": @"211",
                                        @"rate" : @5, @"category_id" : @"3775", @"image_url" : @"http://esteeselpunto.com/wp-content/uploads/2013/02/Final-Colombia-Next-Top-Model-1024x871.png", @"is_campaign" : @NO, @"campaign_url" : @""},
                                             
                                             @{@"name": @"Yo me llamo", @"type" : @"Series", @"feature_text": @"Primer episodio", @"id": @"211",
                                               @"rate" : @5, @"category_id" : @"33275", @"image_url" : @"http://www.ecbloguer.com/diablog/wp-content/uploads/2012/01/Yo-me-llamo-DiabloG.jpg", @"is_campaign" : @NO, @"campaign_url" : @""},
                                             
                                             @{@"name": @"La ronca de oro", @"type" : @"Series", @"feature_text": @"Llega la ronca", @"id": @"211",
                                               @"rate" : @5, @"category_id" : @"33275", @"image_url" : @"http://2.bp.blogspot.com/-q96yFMADKm8/Urt_ZYchqWI/AAAAAAAADY0/Oe6F-0PQdRc/s1600/caracol%2B-%2Bla%2Bronca%2Bde%2Boro.png", @"is_campaign" : @NO, @"campaign_url" : @""}];
    }
    return _unparsedFeaturedProductionsInfo;
}

#pragma mark - UI Setup & Initilization Methods

-(void)parseFeaturedInfo {
    self.parsedFeaturedProductions = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedFeaturedProductionsInfo count]; i++) {
        Featured *featuredProduction = [[Featured alloc] initWithDictionary:self.unparsedFeaturedProductionsInfo[i]];
        [self.parsedFeaturedProductions addObject:featuredProduction];
    }
}

-(void)UISetup {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeaderWithLogo.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    /*-----------------------------------------------------------*/
    //1. Create a ScrollView to display the main images
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height - 64 - 44);
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self createPageAtPosition:0 withFeaturedProduction:[self.parsedFeaturedProductions lastObject]];
    [self createPageAtPosition:[self.parsedFeaturedProductions count]+1 withFeaturedProduction:[self.parsedFeaturedProductions firstObject]];
   
    for (int i = 1; i <= [self.parsedFeaturedProductions count]; i++) {
        Featured *featuredProduction = self.parsedFeaturedProductions[i - 1];
        [self createPageAtPosition:i withFeaturedProduction:featuredProduction];
        self.numberOfPages = i;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*(self.numberOfPages + 2), self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(320.0, 0.0);
    [self.view addSubview:self.scrollView];
    
    /*-------------------------------------------------------------*/
    //2. Create a PageControl to display the current page
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame =  CGRectMake(self.view.bounds.size.width/2 - 50.0, self.scrollView.frame.size.height/1.1, 100.0, 30.0);
    self.pageControl.numberOfPages = self.numberOfPages;
    [self.view addSubview:self.pageControl];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self parseFeaturedInfo];
    [self UISetup];
}

#pragma mark - Custom Methods

-(void)createPageAtPosition:(int)pagePosition withFeaturedProduction:(Featured *)featuredProduction {
    UIView *page = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*pagePosition,
                                                            0.0,
                                                            self.scrollView.frame.size.width,
                                                            self.scrollView.frame.size.height)];
    /*-------------------------------------------------------------*/
    //1. ImageView to display the main image
    UIImageView *pageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                               0.0,
                                                                               self.scrollView.frame.size.width,
                                                                               self.scrollView.frame.size.height)];
    pageImageView.clipsToBounds = YES;
    pageImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSURL *pageImageURL = [NSURL URLWithString:featuredProduction.imageURL];
    [pageImageView setImageWithURL:pageImageURL key:nil placeholder:[UIImage imageNamed:@"HomeScreenPlaceholder.png"] completionBlock:nil failureBlock:nil];
    [page addSubview:pageImageView];
    
    //Create a view to add a pattern image to the main image view
    UIView *opacityPatternView = [[UIView alloc] initWithFrame:pageImageView.frame];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"OpacityPattern.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, pageImageView.frame.size.height)];
    opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [page addSubview:opacityPatternView];
    
    //2. Label to display the type of video (Series, movie, tv show...)
    UILabel *videoTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0,
                                                                        self.scrollView.frame.size.height / 1.28,
                                                                        self.scrollView.frame.size.width - 70.0,
                                                                        30.0)];
    videoTypeLabel.text = featuredProduction.type;
    videoTypeLabel.textAlignment = NSTextAlignmentLeft;
    videoTypeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0];
    videoTypeLabel.textColor = [UIColor whiteColor];
    [page addSubview:videoTypeLabel];
    
    //3. Label to display the video name (La selección, Mentiras Perfectas ...)
    UILabel *videoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0,
                                                                        self.scrollView.frame.size.height / 1.22,
                                                                        self.scrollView.frame.size.width - 70.0,
                                                                        30.0)];
    videoNameLabel.text = featuredProduction.name;
    videoNameLabel.textColor = [UIColor whiteColor];
    videoNameLabel.textAlignment = NSTextAlignmentLeft;
    videoNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [page addSubview:videoNameLabel];
    
    //4. Label to display the season and episode of the video (Temporada 3, episodio 4...)
    UILabel *videoInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0,
                                                                        self.scrollView.frame.size.height / 1.16,
                                                                        self.scrollView.frame.size.width - 70.0,
                                                                        30.0)];
    videoInfoLabel.text = featuredProduction.featureText;
    videoInfoLabel.textAlignment = NSTextAlignmentLeft;
    videoInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0];
    videoInfoLabel.textColor = [UIColor whiteColor];
    [page addSubview:videoInfoLabel];
    
    [self.scrollView addSubview:page];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lroundf(fractionalPage);
    self.pageControl.currentPage = page - 1;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"Estoy en la página %d", self.pageControl.currentPage);
    if (self.scrollView.contentOffset.x < 320.0) {
        //the user scroll from page 1 to the left, so we have to set the content offset
        //of the scroll view to the last page
        [self.scrollView setContentOffset:CGPointMake(320.0*self.numberOfPages, 0.0) animated:NO];
    } else if (self.scrollView.contentOffset.x >= 320 * (self.numberOfPages + 1)) {
        [self.scrollView setContentOffset:CGPointMake(320.0, 0.0) animated:NO];
    }
}

- (NSUInteger) supportedInterfaceOrientations{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSLog(@"Iphone");
        return UIInterfaceOrientationMaskPortrait;
    } else {
        NSLog(@"iPad");
        return UIInterfaceOrientationMaskLandscape;
    }
}

@end

