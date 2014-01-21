//
//  MoviesEventsViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MoviesEventsDetailsViewController.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface MoviesEventsDetailsViewController ()

@end

@implementation MoviesEventsDetailsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Mentiras Perfectas";
    [self UISetup];
}

-(void)UISetup {
    //1. Create the main image view of the movie/event
    UIImageView *movieEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                                     self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height,
                                                                                     self.view.frame.size.width,
                                                                                     self.view.frame.size.height/3)];
    movieEventImageView.clipsToBounds = YES;
    movieEventImageView.contentMode = UIViewContentModeScaleAspectFill;
    movieEventImageView.image = [UIImage imageNamed:@"MentirasPerfectas2.jpg"];
    [self.view addSubview:movieEventImageView];
    
    //Create a view with an opacity pattern to apply an opacity to the image
    UIView *opacityPatternView = [[UIView alloc] initWithFrame:movieEventImageView.frame];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"OpacityPattern.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, movieEventImageView.frame.size.height+5)];
    opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [self.view addSubview:opacityPatternView];
    
    //2. Create the secondary image of the movie/event
    UIImageView *secondaryMovieEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0,
                                                                                              self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0,
                                                                                              90.0,
                                                                                              140.0)];
    secondaryMovieEventImageView.clipsToBounds = YES;
    secondaryMovieEventImageView.contentMode = UIViewContentModeScaleAspectFill;
    secondaryMovieEventImageView.image = [UIImage imageNamed:@"MentirasPerfectas.jpg"];
    [self.view addSubview:secondaryMovieEventImageView];
    
    //3. Create the label to display the movie/event name
    UILabel *movieEventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                             self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20.0,
                                                                             self.view.frame.size.width - 50.0,
                                                                             30.0)];
    movieEventNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    movieEventNameLabel.text = @"Mentiras Perfectas";
    movieEventNameLabel.textColor = [UIColor whiteColor];
    movieEventNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:movieEventNameLabel];
    
    //4. Create the stars images
    [self createStarsImageViewsWithGoldStarsNumber:4];
    
    //5. Create a button to see the movie/event trailer
    UIButton *watchTrailerButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0,
                                                                              self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 90.0,
                                                                              100.0,
                                                                              30.0)];
    [watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    watchTrailerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [watchTrailerButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:watchTrailerButton];
    
    //6. Create a button to share the movie/event
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(secondaryMovieEventImageView.frame.origin.x + secondaryMovieEventImageView.frame.size.width + 20.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 120.0, 100.0, 30.0)];
    [shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:shareButton];
    
    //7. Create a text view to display the detail of the event/movie
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0, movieEventImageView.frame.origin.y + movieEventImageView.frame.size.height, self.view.frame.size.width - 20.0, 70.0)];
    
    detailTextView.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.";
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.textColor = [UIColor whiteColor];
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
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendedProdCollectionViewCell *cell = (RecommendedProdCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.cellImageView.image = [UIImage imageNamed:@"MentirasPerfectas.jpg"];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100.0, 130.0);
}
#pragma mark - Custom Methods

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(115.0 + (i*20),
                                                                                   self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 50.0,
                                                                                   20.0,
                                                                                   20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars > i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:starImageView];
    }
}

@end
