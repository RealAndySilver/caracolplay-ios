//
//  HomeViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "HomeViewController.h"
@interface HomeViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation HomeViewController

#pragma mark - UI Setup

-(void)UISetup {
    UIImageView *CaracolPlayLogo = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(self.navigationController.navigationBar.frame.size.width/ 2 - 70.0,
                                               self.navigationController.navigationBar.frame.size.height/2 - 20.0,
                                               140.0,
                                               40.0)];
    CaracolPlayLogo.image = [UIImage imageNamed:@"CaracolPlayLogo.png"];
    CaracolPlayLogo.clipsToBounds = YES;
    CaracolPlayLogo.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = CaracolPlayLogo;
    
    /*-----------------------------------------------------------*/
    //1. Create a ScrollView to display the main images
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,
                                                                     self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height) - 44.0)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    int numberOfPages;
    for (int i = 0; i < 8; i++) {
        [self createPageAtPosition:i pageImage:[UIImage imageNamed:@"MentirasPerfectas.jpg"] pageInfo:nil];
        numberOfPages = i + 1;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*numberOfPages, self.scrollView.frame.size.height);
    [self.view addSubview:self.scrollView];
    
    /*-------------------------------------------------------------*/
    //2. Create a PageControl to display the current page
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50.0,
                                                                       self.view.frame.size.height/1.17,
                                                                       100.0,
                                                                       30.0)];
    self.pageControl.numberOfPages = numberOfPages;
    [self.view addSubview:self.pageControl];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
}

#pragma mark - Custom Methods

-(void)createPageAtPosition:(int)pagePosition pageImage:(UIImage *)image pageInfo:(NSDictionary *)info {
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
    pageImageView.image = image;
    [page addSubview:pageImageView];
    
    //2. Label to display the type of video (Series, movie, tv show...)
    UILabel *videoTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0,
                                                                        self.scrollView.frame.size.height / 1.28,
                                                                        self.scrollView.frame.size.width - 70.0,
                                                                        30.0)];
    videoTypeLabel.text = @"Series";
    videoTypeLabel.textAlignment = NSTextAlignmentLeft;
    videoTypeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15.0];
    videoTypeLabel.textColor = [UIColor whiteColor];
    [page addSubview:videoTypeLabel];
    
    //3. Label to display the video name (La selección, Mentiras Perfectas ...)
    UILabel *videoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0,
                                                                        self.scrollView.frame.size.height / 1.22,
                                                                        self.scrollView.frame.size.width - 70.0,
                                                                        30.0)];
    videoNameLabel.text = @"Mentiras Perfectas";
    videoNameLabel.textColor = [UIColor whiteColor];
    videoNameLabel.textAlignment = NSTextAlignmentLeft;
    videoNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [page addSubview:videoNameLabel];
    
    //4. Label to display the season and episode of the video (Temporada 3, episodio 4...)
    UILabel *videoInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0,
                                                                        self.scrollView.frame.size.height / 1.16,
                                                                        self.scrollView.frame.size.width - 70.0,
                                                                        30.0)];
    videoInfoLabel.text = @"Temporada 3 / Episodio 4";
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
    self.pageControl.currentPage = page;
}

@end

