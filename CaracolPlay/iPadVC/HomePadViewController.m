//
//  HomePadViewController.m
//  CaracolPlay
//
//  Created by Developer on 3/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "HomePadViewController.h"
#import "iCarousel.h"

@interface HomePadViewController () <iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) iCarousel *carousel;
@end

@implementation HomePadViewController

-(void)UISetup {
    //1. background image setup
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HomeScreenBackgroundPad.png"]];
    [self.view addSubview:self.backgroundImageView];
    
    //2. Carousel setup
    self.carousel = [[iCarousel alloc] init];
    self.carousel.type = iCarouselTypeRotary;
    self.carousel.scrollSpeed = 0.5;
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    [self.view addSubview:self.carousel];
}

#pragma  mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //Set subviews frame
    self.backgroundImageView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0);
    self.carousel.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0);
}

#pragma mark - iCarouselDataSource

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return 6;
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 500.0, 500.0)];
        
        //Main Image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.frame];
        imageView.image = [UIImage imageNamed:@"MentirasPerfectas2.jpg"];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:imageView];
        
        //Type of production label
        UILabel *productionTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 400.0, 100.0, 30.0)];
        productionTypeLabel.text = @"Series";
        productionTypeLabel.textColor = [UIColor whiteColor];
        productionTypeLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [view addSubview:productionTypeLabel];
        
        //Production name label
        UILabel *productionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 430.0, 200.0, 30.0)];
        productionNameLabel.text = @"Mentiras Perfectas";
        productionNameLabel.textColor = [UIColor whiteColor];
        productionNameLabel.font = [UIFont boldSystemFontOfSize:20.0];
        [view addSubview:productionNameLabel];
        
        //production season/episode
        UILabel *seasonEpisodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 460.0, 200.0, 30.0)];
        seasonEpisodeLabel.text = @"Temporada 4 / Capítulo 8";
        seasonEpisodeLabel.textColor = [UIColor whiteColor];
        seasonEpisodeLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [view addSubview:seasonEpisodeLabel];
    }
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
            return 1.0;
            
        default:
            return value;
    }
}

@end
