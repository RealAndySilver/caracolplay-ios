//
//  MovieDetailsViewController.m
//  CaracolPlay
//
//  Created by Developer on 4/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MovieDetailsPadViewController.h"

NSString *const moviesCellIdentifier = @"CellIdentifier";

@interface MovieDetailsPadViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *opaqueView;
@property (strong, nonatomic) UIImageView *smallProductionImageView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) UIButton *watchTrailerButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UITextView *productionDetailTextView;
@property (strong, nonatomic) UILabel *recommendedProductionsLabel;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;
@end

@implementation MovieDetailsPadViewController

-(void)UISetup {
    //1. Dismiss button
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //2. Background image view
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MentirasPerfectas2.jpg"]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //3. add a UIView to opaque the background view
    self.opaqueView = [[UIView alloc] init];
    self.opaqueView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.backgroundImageView addSubview:self.opaqueView];
    
    //3. small production image view
    self.smallProductionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MentirasPerfectas.jpg"]];
    self.smallProductionImageView.clipsToBounds = YES;
    self.smallProductionImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.smallProductionImageView];
    
    //4. Production name label setup
    self.productionNameLabel = [[UILabel alloc] init];
    self.productionNameLabel.text = @"Mentiras Perfectas";
    self.productionNameLabel.textColor = [UIColor whiteColor];
    self.productionNameLabel.font = [UIFont boldSystemFontOfSize:25.0];
    [self.view addSubview:self.productionNameLabel];
    
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
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.shareButton];
    
    //7. Productiond etail textview setup
    self.productionDetailTextView = [[UITextView alloc] init];
    self.productionDetailTextView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel neque interdum quam auctor ultricies. Donec eget scelerisque leo, sed commodo nibh. Suspendisse potenti. Morbi vitae est ac ipsum mollis vulputate eget commodo elit. Donec magna justo, semper sit amet libero eget, tempus condimentum ipsum. Aenean lobortis eget justo sed mattis. Suspendisse eget libero eget est imperdiet dignissim vel quis erat.";
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
    self.watchTrailerButton.frame = CGRectMake(170.0, 90.0, 140.0, 35.0);
    self.shareButton.frame = CGRectMake(330.0, 90.0, 140.0, 35.0);
    self.productionDetailTextView.frame = CGRectMake(170.0, 150.0, 450.0, 100.0);
    self.recommendedProductionsLabel.frame = CGRectMake(30.0, 280.0, 250.0, 30.0);
    self.collectionView.frame = CGRectMake(0.0, 310.0, self.view.bounds.size.width, self.view.bounds.size.height - 310.0);
    [self createStarsImageViewsWithGoldStarsNumber:5];
}

#pragma mark - Custom Methods

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    
    for (int i = 1; i < 6; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(150 + 20.0*i, 60.0, 20.0, 20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars > i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:starImageView];
    }
}

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource 
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:moviesCellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
    imageView.image = [UIImage imageNamed:@"MentirasPerfectas.jpg"];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:imageView];
    return cell;
}

#pragma  mark - UICollectionViewDelegate 

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100.0, 120.0);
}

@end
