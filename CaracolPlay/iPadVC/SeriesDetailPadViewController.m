//
//  SeriesDetailPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SeriesDetailPadViewController.h"
#import "EpisodesPadTableViewCell.h"
#import <Social/Social.h>

@interface SeriesDetailPadViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *opacityPatternView;
@property (strong, nonatomic) UIImageView *smallProductionImageView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) UIButton *watchTrailerButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UITextView *productionDetailTextView;
@property (strong, nonatomic) UITableView *seasonsTableView;
@property (strong, nonatomic) UITableView *chaptersTableView;
@end

@implementation SeriesDetailPadViewController

-(void)UISetup {
    //1. dismiss buton setup
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
    
    //2. backgroun image view setup
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.image = [UIImage imageNamed:@"Escobar.jpg"];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
    //Set the opacity pattern view
    self.opacityPatternView = [[UIView alloc] init];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"SeriesOpacityPatternPad.png"];
    self.opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [self.backgroundImageView addSubview:self.opacityPatternView];
    
    //3. Small production image view setup
    self.smallProductionImageView = [[UIImageView alloc] init];
    self.smallProductionImageView.image = [UIImage imageNamed:@"Escobar.jpg"];
    self.smallProductionImageView.clipsToBounds = YES;
    self.smallProductionImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.smallProductionImageView];
    
    //4. production name label setup
    self.productionNameLabel = [[UILabel alloc] init];
    self.productionNameLabel.text = @"Escobar, el patrón del mal";
    self.productionNameLabel.textColor = [UIColor whiteColor];
    self.productionNameLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [self.view addSubview:self.productionNameLabel];
    
    //5. Watch Trailer button setup
    self.watchTrailerButton = [[UIButton alloc] init];
    [self.watchTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    [self.watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    self.watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.watchTrailerButton];
    
    //6. Share button setup
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
    
    //7. Production detail text view
    self.productionDetailTextView = [[UITextView alloc] init];
    self.productionDetailTextView.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel neque interdum quam auctor ultricies. Donec eget scelerisque leo, sed commodo nibh. Suspendisse potenti. Morbi vitae est ac ipsum mollis vulputate eget commodo elit. Donec magna justo, semper sit amet libero eget, tempus condimentum ipsum. Aenean lobortis eget justo sed mattis. Suspendisse eget libero eget est imperdiet dignissim vel quis erat.";
    self.productionDetailTextView.textColor = [UIColor whiteColor];
    self.productionDetailTextView.backgroundColor = [UIColor clearColor];
    self.productionDetailTextView.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.productionDetailTextView];
    
    //8. Seasons table view setup
    self.seasonsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.seasonsTableView.delegate = self;
    self.seasonsTableView.dataSource = self;
    self.seasonsTableView.tag = 1;
    self.seasonsTableView.backgroundColor = [UIColor clearColor];
    self.seasonsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.seasonsTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    [self.view addSubview:self.seasonsTableView];
    
    //9. Chapters table view setup
    self.chaptersTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.chaptersTableView.delegate = self;
    self.chaptersTableView.dataSource = self;
    self.chaptersTableView.tag = 2;
    self.chaptersTableView.backgroundColor = [UIColor darkGrayColor];
    self.chaptersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chaptersTableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:self.chaptersTableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 646.0, 616.0);
    
    //Set subviews frame
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 25.0, 0.0, 25.0, 25.0);
    self.backgroundImageView.frame = self.view.bounds;
    self.opacityPatternView.frame = self.backgroundImageView.frame;
    self.smallProductionImageView.frame = CGRectMake(30.0, 30.0, 128.0, 194.0);
    self.productionNameLabel.frame = CGRectMake(180.0, 30.0, self.view.bounds.size.width - 180.0, 30.0);
    self.watchTrailerButton.frame = CGRectMake(180.0, 100.0, 140.0, 35.0);
    self.shareButton.frame = CGRectMake(340.0, 100.0, 140.0, 35.0);
    self.productionDetailTextView.frame = CGRectMake(180.0, 150.0, self.view.bounds.size.width - 150.0, 100.0);
    self.seasonsTableView.frame = CGRectMake(30.0, 280.0, 128.0, self.view.bounds.size.height - 250.0);
    self.chaptersTableView.frame = CGRectMake(180.0, 280.0, self.view.bounds.size.width - 180.0 - 30.0, self.view.bounds.size.height - 280.0 - 30.0);
    [self createStarsImageViewsWithGoldStarsNumber:3];
}

#pragma mark - Custom Methods

-(void)createStarsImageViewsWithGoldStarsNumber:(int)goldStars {
    
    for (int i = 1; i < 6; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(160 + 20.0*i, 60.0, 20.0, 20.0)];
        starImageView.image = [[UIImage imageNamed:@"Estrella.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (goldStars >= i) {
            starImageView.tintColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:0.0 alpha:1.0];
        }
        starImageView.clipsToBounds = YES;
        starImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:starImageView];
    }
}

#pragma mark - Actions

-(void)shareProduction {
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Volver" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", nil] showInView:self.view];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        return 5;
    } else {
        return 12;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        cell.textLabel.text = @"Temporada 1";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        return cell;
    } else {
        EpisodesPadTableViewCell *cell = (EpisodesPadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[EpisodesPadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
        cell.episodeNameLabel.text = @"Pablo escobar llega a New York";
        cell.episodeNumberLabel.text = @"50";
        return cell;
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate 

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Facebook
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [facebookViewController setInitialText:@"El patrón del mal, la historia del capo de capos."];
            [self presentViewController:facebookViewController animated:YES completion:nil];
        } else {
            //Tell te user that facebook is not configured on the device
            [[[UIAlertView alloc] initWithTitle:nil message:@"Facebook no está configurado en tu dispositivo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if (buttonIndex == 1) {
        //Twitter
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [twitterViewController setInitialText:@"El patrón del mal, la historia del capo de capos."];
            [self presentViewController:twitterViewController animated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Twitter no está configurado en tu dispositivo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

@end
