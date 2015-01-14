//
//  SeriesDetailPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 5/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SeriesDetailPadViewController.h"
#import "VideoPlayerPadViewController.h"
#import <Social/Social.h>
#import "Product.h"
#import "Episode.h"
#import "JMImageCache.h"
#import "LargeProductionImageView.h"
#import "RateView.h"
#import "StarsView.h"
#import "MyUtilities.h"
#import "Reachability.h"
#import "FileSaver.h"
#import "EpisodesPadTableViewCell.h"
#import "AddToListView.h"
#import "ServerCommunicator.h"
#import "Season.h"
#import "SuscriptionAlertPadViewController.h"
#import "Video.h"
#import "ContentNotAvailableForUserPadViewController.h"
#import "NSDictionary+NullReplacement.h"
#import "UserInfo.h"
#import "SinopsisView.h"
@import QuartzCore;

@interface SeriesDetailPadViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, RateViewDelegate, EpisodesPadTableViewCellDelegate, AddToListViewDelegate, ServerCommunicatorDelegate, UIAlertViewDelegate, SinopsisViewDelegate>
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *opacityPatternView;
@property (strong, nonatomic) UILabel *productionNameLabel;
@property (strong, nonatomic) UIButton *watchTrailerButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *rateButton;
@property (strong, nonatomic) UIButton *viewProductionButton;
@property (strong, nonatomic) UITextView *productionDetailTextView;
@property (strong, nonatomic) UITableView *seasonsTableView;
@property (strong, nonatomic) UITableView *chaptersTableView;

//@property (strong, nonatomic) NSArray *unparsedEpisodesInfo;
//@property (strong, nonatomic) NSDictionary *productionInfo;
//@property (strong, nonatomic) NSMutableArray *parsedEpisodesArray;
@property (strong, nonatomic) NSDictionary *unparsedProductionInfoDic;
@property (strong, nonatomic) Product *production;

@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) StarsView *starsView;
@property (assign, nonatomic) NSInteger selectedSeason;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSString *selectedEpisodeID;
@property (assign, nonatomic) NSUInteger lastEpisodeSeen;
@end

@implementation SeriesDetailPadViewController

#pragma mark - Setters & Getters

-(NSString *)selectedEpisodeID {
    if (!_selectedEpisodeID) {
        Season *firstSeason = self.production.seasonList[0];
        Episode *firstEpisode = firstSeason.episodes[0];
        _selectedEpisodeID = firstEpisode.identifier;
    }
    return _selectedEpisodeID;
}

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(335 - 20.0, 313.0 - 20.0, 40.0, 40.0);
    }
    return _spinner;
}

-(void)setUnparsedProductionInfoDic:(NSDictionary *)unparsedProductionInfoDic {
    _unparsedProductionInfoDic = unparsedProductionInfoDic;
    NSDictionary *parsedProductionInfoDic = [self dictionaryWithParsedProductionInfo:unparsedProductionInfoDic];
    self.production = [[Product alloc] initWithDictionary:parsedProductionInfoDic];
    [self UISetup];
}

-(NSDictionary *)dictionaryWithParsedProductionInfo:(NSDictionary *)unparsedDic {
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary:unparsedDic];
    
    //Check if the product has seasons
    if ([unparsedDic[@"has_seasons"] boolValue]) {
        //The product has seasons
        NSLog(@"Si tiene temporadas, no episodios sueltos");
        
        NSArray *unparsedSeasonsArray = [NSArray arrayWithArray:unparsedDic[@"season_list"]];
        NSLog(@"Numero de temporadas: %d", [unparsedSeasonsArray count]);
        NSMutableArray *parsedSeasonsArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [unparsedSeasonsArray count]; i++) {
            NSArray *unparsedEpisodesFromSeason = unparsedSeasonsArray[i][@"episodes"];
            NSLog(@"Numero de episodios en la temporada %d: %d", i+1, [unparsedEpisodesFromSeason count]);
            
            //Create a mutable array to store the Episodes objects that we are going to create
            NSMutableArray *parsedEpisodesFromSeason = [[NSMutableArray alloc] init];
            
            //Loop through all the season episodes.
            for (int i = 0; i < [unparsedEpisodesFromSeason count]; i++) {
                Episode *episode = [[Episode alloc] initWithDictionary:unparsedEpisodesFromSeason[i]];
                if (episode.lastChapter) {
                    self.lastEpisodeSeen = i;
                }
                [parsedEpisodesFromSeason addObject:episode];
            }
            
            Season *season = [[Season alloc] initWithDictionary:@{@"season_id": unparsedSeasonsArray[i][@"season_id"],
                                                                  @"season_name" : unparsedSeasonsArray[i][@"season_name"],
                                                                  @"episodes" : parsedEpisodesFromSeason}];
            [parsedSeasonsArray addObject:season];
        }
        [newDictionary setObject:parsedSeasonsArray forKey:@"season_list"];
        return newDictionary;
    }
    else {
        //The product has no seasons
        NSLog(@"El producto no tiene temporadas");
        NSArray *unparsedEpisodesArray = [NSArray arrayWithArray:unparsedDic[@"episodes"]];
        NSMutableArray *parsedEpisodesArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [unparsedEpisodesArray count]; i++) {
            Episode *episode = unparsedEpisodesArray[i];
            [parsedEpisodesArray addObject:episode];
        }
        [newDictionary setObject:parsedEpisodesArray forKey:@"episodes"];
        return newDictionary;
    }
}

#pragma mark - UISetup & Initialization stuff

-(void)UISetup {
  
    //2. background image view setup
    /*self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    self.backgroundImageView.clipsToBounds = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];*/
    
    //Free band image view
    if ([self.production.free isEqualToString:@"1"]) {
        UIImageView *freeBandImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 118.0, 0.0, 118.0, 86.0)];
        freeBandImageView.image = [UIImage imageNamed:@"FreeBandPad.png"];
        [self.view addSubview:freeBandImageView];
    }
    
    //Set the opacity pattern view
    /*self.opacityPatternView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImage *opacityPatternImage = [UIImage imageNamed:@"SeriesOpacityPatternPad.png"];
    opacityPatternImage = [MyUtilities imageWithName:opacityPatternImage ScaleToSize:CGSizeMake(1.0, 626.0)];
    self.opacityPatternView.clipsToBounds = YES;
    self.opacityPatternView.backgroundColor = [UIColor colorWithPatternImage:opacityPatternImage];
    [self.backgroundImageView addSubview:self.opacityPatternView];*/
    
    //3. Small production image view setup
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 30.0, 128.0, 194.0)];
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    shadowView.layer.shadowRadius = 6.0;
    shadowView.layer.shadowOpacity = 0.8;
    [self.view addSubview:shadowView];
    
    UIImageView *smallProductionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, shadowView.frame.size.width, shadowView.frame.size.height)];
    [smallProductionImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"SmallPlaceholder.png"] completionBlock:nil failureBlock:nil];
    smallProductionImageView.clipsToBounds = YES;
    smallProductionImageView.userInteractionEnabled = YES;
    smallProductionImageView.contentMode = UIViewContentModeScaleAspectFill;
    [shadowView addSubview:smallProductionImageView];
    
    //Add the play icon into the secondaty image view
    /*UIImageView *playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(smallProductionImageView.frame.size.width/2 - 25.0, smallProductionImageView.frame.size.height/2 - 25.0, 50.0, 50.0)];
    playIcon.clipsToBounds = YES;
    playIcon.contentMode = UIViewContentModeScaleAspectFit;
    playIcon.image = [UIImage imageNamed:@"PlayIconHomeScreen.png"];
    [smallProductionImageView addSubview:playIcon];*/
    
    //6. Share button setup
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(190.0, 100.0, 140.0, 35.0)];
    [self.shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.shareButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    self.shareButton.clipsToBounds = YES;
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"ShareButton.png"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(shareProduction) forControlEvents:UIControlEventTouchUpInside];
    self.shareButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shareButton.layer.shadowOpacity = 0.8;
    self.shareButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.shareButton.layer.shadowRadius = 5.0;
    [self.view addSubview:self.shareButton];

    
    if (![self.production.type isEqualToString:@"Noticias"]) {
        //Change 'compartir' button frame
        self.shareButton.frame = CGRectMake(340.0, 100.0, 140.0, 35.0);
        
        // Add the stars to the view
        self.starsView = [[StarsView alloc] initWithFrame:CGRectMake(180.0, 65.0, 100.0, 20.0) rate:[self.production.rate intValue]/20.0 + 1];
        [self.view addSubview:self.starsView];
        
        //Add a tap gesture to the star view. when the user touches the stars, show the rate view
        UITapGestureRecognizer *starsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRateView)];
        [self.starsView addGestureRecognizer:starsTapGesture];
        
        //5. Watch Trailer button setup
        self.watchTrailerButton = [[UIButton alloc] initWithFrame:CGRectMake(180.0, 100.0, 140.0, 35.0)];
        [self.watchTrailerButton setTitle:@"Ver Tráiler" forState:UIControlStateNormal];
        [self.watchTrailerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.watchTrailerButton setBackgroundImage:[UIImage imageNamed:@"OrangeButton.png"] forState:UIControlStateNormal];
        self.watchTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.watchTrailerButton addTarget:self action:@selector(watchTrailer) forControlEvents:UIControlEventTouchUpInside];
        self.watchTrailerButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
        self.watchTrailerButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.watchTrailerButton.layer.shadowOpacity = 0.8;
        self.watchTrailerButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
        self.watchTrailerButton.layer.shadowRadius = 5.0;
        
        [self.view addSubview:self.watchTrailerButton];
    }
    
    //Create a tap gesture and add it to the small image view, to display
    //a larger image when the user taps on it.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [smallProductionImageView addGestureRecognizer:tapGesture];
    
    //4. production name label setup
    self.productionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(180.0, 30.0, self.view.bounds.size.width - 180.0, 30.0)];
    self.productionNameLabel.text = self.production.name;
    self.productionNameLabel.textColor = [UIColor whiteColor];
    self.productionNameLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [self.view addSubview:self.productionNameLabel];
    
    //View production button (only if the user is log out)
    if ([self.production.free isEqualToString:@"0"]) {
        FileSaver *fileSaver = [[FileSaver alloc] init];
        if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue] || ![UserInfo sharedInstance].isSubscription) {
            if (!self.production.statusRent) {
                self.viewProductionButton = [[UIButton alloc] initWithFrame:CGRectMake(self.shareButton.frame.origin.x + self.shareButton.frame.size.width + 20.0, 100.0, 140.0, 35.0)];
                [self.viewProductionButton setTitle:@"Ver Producción" forState:UIControlStateNormal];
                [self.viewProductionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.viewProductionButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
                [self.viewProductionButton addTarget:self action:@selector(goToSuscriptionAlert) forControlEvents:UIControlEventTouchUpInside];
                [self.viewProductionButton setBackgroundImage:[UIImage imageNamed:@"OrangeButton.png"] forState:UIControlStateNormal];
                self.viewProductionButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
                self.viewProductionButton.layer.shadowColor = [UIColor blackColor].CGColor;
                self.viewProductionButton.layer.shadowOpacity = 0.8;
                self.viewProductionButton.layer.shadowOffset = CGSizeMake(5.0, 5.0);
                self.viewProductionButton.layer.shadowRadius = 5.0;
                [self.view addSubview:self.viewProductionButton];
            }
        }
    }
    
    //7. Production detail text view
    /*self.productionDetailTextView = [[UITextView alloc] initWithFrame:CGRectMake(180.0, 150.0, self.view.bounds.size.width - 190.0, 100.0)];
    self.productionDetailTextView.text = self.production.detailDescription;
    self.productionDetailTextView.userInteractionEnabled = NO;
    self.productionDetailTextView.textColor = [UIColor whiteColor];
    self.productionDetailTextView.backgroundColor = [UIColor clearColor];
    self.productionDetailTextView.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.productionDetailTextView];*/
    
    //Sinopsis webview
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(180.0, 150.0, self.view.bounds.size.width - 190.0, 70.0)];
    webView.opaque=NO;
    [webView setBackgroundColor:[UIColor clearColor]];
    webView.userInteractionEnabled = NO;
    NSString *str = [NSString stringWithFormat:@"<html><body style='background-color: transparent; color:white; font-family: helvetica;'>%@</body></html>",self.production.detailDescription];
    [webView loadHTMLString:str baseURL:nil];
    [self.view addSubview:webView];
    
    //"Ver mas" button
    UIButton *moreInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(180.0, 220.0, 70.0, 40.0)];
    [moreInfoButton setTitle:@"Ver más" forState:UIControlStateNormal];
    [moreInfoButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    moreInfoButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [moreInfoButton addTarget:self action:@selector(showMoreInfoView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreInfoButton];
    
    if (self.production.hasSeasons && [self.production.seasonList count] > 1) {
        //8. Seasons table view setup
        self.seasonsTableView = [[UITableView alloc] initWithFrame:CGRectMake(20.0, 280.0, 148.0, self.view.bounds.size.height - 280.0) style:UITableViewStylePlain];
        self.seasonsTableView.delegate = self;
        self.seasonsTableView.dataSource = self;
        self.seasonsTableView.backgroundColor = [UIColor clearColor];
        self.seasonsTableView.tag = 1;
        self.seasonsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.seasonsTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [self.view addSubview:self.seasonsTableView];
    }
    
    //9. Chapters table view setup
    self.chaptersTableView = [[UITableView alloc] initWithFrame:CGRectMake(180.0, 280.0, self.view.bounds.size.width - 180.0 - 30.0, self.view.bounds.size.height - 280.0 - 30.0) style:UITableViewStylePlain];
    self.chaptersTableView.delegate = self;
    self.chaptersTableView.dataSource = self;
    self.chaptersTableView.tag = 2;
    self.chaptersTableView.backgroundColor = [UIColor darkGrayColor];
    self.chaptersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chaptersTableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:self.chaptersTableView];
    [self animateTableViewToPosition:self.lastEpisodeSeen];
}

-(void)animateTableViewToPosition:(NSUInteger)position {
    [self.chaptersTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //Add as an oberver of the VideoShoulBeDisplayed notification. when this notification
    //is received, the video controller should be presented automaticly
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoShouldBeDisplayedReceived)
                                                 name:@"Video"
                                               object:nil];
    
    //Add the spinner to the view inmediatly
    [self.view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    
    //Start the view with season 1
    self.selectedSeason = 0;
    
    //Call Server
    [self getProductionInfoWithID:self.productID];

    //Create the dismiss button. It's neccesary to create te button here, because
    //if there's a server error, the UISetup method won't get called, and nothing will
    //load, so the user won't be able to dismiss the view
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dismissButton];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0.0, 0.0, 670.0, 626.0);
    self.dismissButton.frame = CGRectMake(self.view.bounds.size.width - 57.0, -30.0, 88.0, 88.0);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"la vista apreció");
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"reload table viewwwww");
    if (tableView.tag == 1) {
        //Seasons table view
        return [self.production.seasonList count];
    } else {
        //Episodes table view
        if (self.production.hasSeasons) {
            //The product has seasons
            Season *season = self.production.seasonList[self.selectedSeason];
            return [season.episodes count];
        } else {
            //The product doesn't have episodes
            return [self.production.episodes count];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        //Seasons table view
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
            UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height)];
            selectedView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
            cell.selectedBackgroundView = selectedView;
        }
        
        /*if (self.selectedSeason == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }*/
        
        if ([self.production.type isEqualToString:@"Series"] || [self.production.type isEqualToString:@"Telenovelas"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"Temporada %d", indexPath.row + 1];
        } else {
            Season *season = self.production.seasonList[indexPath.row];
            cell.textLabel.text = season.seasonName;
        }
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        return cell;
        
    } else {
        //Episodes table view
        EpisodesPadTableViewCell *cell = (EpisodesPadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
        if (!cell) {
            cell = [[EpisodesPadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
            UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height)];
            selectedView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
            cell.selectedBackgroundView = selectedView;
        }
        cell.delegate = self;
        
        if (indexPath.row == self.lastEpisodeSeen) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        if (self.production.hasSeasons) {
            //The product has seasons
            Season *season = self.production.seasonList[self.selectedSeason];
            Episode *episode = season.episodes[indexPath.row];
            cell.episodeNameLabel.text = episode.episodeName;
            cell.episodeNumberLabel.text = [episode.episodeNumber description];
            return cell;
        } else {
            //the product doesn't have seasons
            Episode *episode = self.production.episodes[indexPath.row];
            cell.episodeNameLabel.text = episode.episodeName;
            cell.episodeNumberLabel.text = [episode.episodeNumber description];
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    static int prev = 0;
    if (tableView.tag == 1) {
        //Seasons table view
        //self.selectedSeason = indexPath.row;
        //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType==UITableViewCellAccessoryNone)
        {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            if (prev!=indexPath.row) {
                cell=[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prev inSection:0]];
                cell.accessoryType=UITableViewCellAccessoryNone;
                prev=indexPath.row;
            }
        }
        else{
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
        self.selectedSeason = indexPath.row;
        [self.chaptersTableView reloadData];
    }
    
    if (tableView.tag == 2) {
        //Episodes table view
        FileSaver *fileSaver = [[FileSaver alloc] init];
        if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
            if (self.production.hasSeasons) {
                Season *currentSeason = self.production.seasonList[self.selectedSeason];
                Episode *episode = currentSeason.episodes[indexPath.row];
                self.selectedEpisodeID = episode.identifier;
                
            } else {
                Episode *episode = self.production.episodes[indexPath.row];
                self.selectedEpisodeID = episode.identifier;
            }
            
            //If the user isn't logged in, he can't watch the video
            NSLog(@"Entré acáaaaaa");
            SuscriptionAlertPadViewController *suscriptionAlertPadVC =
            [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlertPad"];
            suscriptionAlertPadVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            suscriptionAlertPadVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            suscriptionAlertPadVC.productID = self.selectedEpisodeID;
            suscriptionAlertPadVC.productType = self.production.type;
            suscriptionAlertPadVC.productName = self.production.name;
            suscriptionAlertPadVC.viewType = self.production.viewType;
            [self presentViewController:suscriptionAlertPadVC animated:YES completion:nil];
            
        } else {
            //The user is already logged in, so check if the video is available
            if (self.production.hasSeasons) {
                Season *currentSeason = self.production.seasonList[self.selectedSeason];
                Episode *episode = currentSeason.episodes[indexPath.row];
                self.selectedEpisodeID = episode.identifier;
                [self getIsContentAvailableForUserWithID:episode.identifier];
                NSLog(@"el identificador del capítulo es: %@", episode.identifier);
                
            } else {
                Episode *episode = self.production.episodes[indexPath.row];
                self.selectedEpisodeID = episode.identifier;
                NSLog(@"el dientifcador del episodio es %@", self.selectedEpisodeID);
                [self getIsContentAvailableForUserWithID:episode.identifier];
            }
        }
    }
}

#pragma mark - Actions

-(void)showMoreInfoView {
    SinopsisView *sinopsisView = [[SinopsisView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    sinopsisView.delegate = self;
    sinopsisView.mainTitle.text = self.production.name;
    sinopsisView.sinopsisString = self.production.detailDescription;
    [sinopsisView showInView:self.view];
}

-(void)goToSuscriptionAlert {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        ContentNotAvailableForUserPadViewController *contentNotAvailableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUserPad"];
        contentNotAvailableVC.productID = self.selectedEpisodeID;
        contentNotAvailableVC.productName = self.production.name;
        contentNotAvailableVC.productType = self.production.type;
        contentNotAvailableVC.viewType = self.production.viewType;
        contentNotAvailableVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        contentNotAvailableVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:contentNotAvailableVC animated:YES completion:nil];
        
    } else {
        SuscriptionAlertPadViewController *suscriptionAlertPadVC =
        [self.storyboard instantiateViewControllerWithIdentifier:@"SuscriptionAlertPad"];
        suscriptionAlertPadVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        suscriptionAlertPadVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        suscriptionAlertPadVC.productID = self.selectedEpisodeID;
        suscriptionAlertPadVC.productType = self.production.type;
        suscriptionAlertPadVC.viewType = self.production.viewType;
        suscriptionAlertPadVC.productName = self.production.name;
        [self presentViewController:suscriptionAlertPadVC animated:YES completion:nil];
    }
}

-(void)watchTrailer {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para ver el trailer de esta producción debes estar conectado a internet." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    } else {
        VideoPlayerPadViewController *videoPlayerPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
        videoPlayerPadVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        videoPlayerPadVC.embedCode = self.production.trailerURL;
        videoPlayerPadVC.isWatchingTrailer = YES;
        [self presentViewController:videoPlayerPadVC animated:YES completion:nil];
    }
}

-(void)showRateView {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.6;
    [self.view addSubview:self.opacityView];
    RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100.0, self.view.frame.size.height/2 - 50.0, 200.0, 120.0) goldStars:[self.production.rate  intValue]/20.0 + 1];
    rateView.delegate = self;
    [self.view addSubview:rateView];
}

-(void)imageTapped:(UITapGestureRecognizer *)tapGesture {
    LargeProductionImageView *largeProdView = [[LargeProductionImageView alloc] initWithFrame:self.view.bounds];
    [largeProdView.largeImageView setImageWithURL:[NSURL URLWithString:self.production.imageURL] placeholder:[UIImage imageNamed:@"HomeScreenPlaceholder.png"] completionBlock:nil failureBlock:nil];
    [self.view addSubview:largeProdView];
    [self.view bringSubviewToFront:largeProdView];
}

-(void)shareProduction {
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Volver" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", nil] showInView:self.view];
}

-(void)dismissVC {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveOpacityView" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Methods

-(void)checkVideoAvailability:(Video *)video {
    if (video.status) {
        //The video is available for the user, so check the network connection to decide
        //if the user can pass to watch it or not.
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status = [reachability currentReachabilityStatus];
        if (status == NotReachable) {
            //The user can't watch the video
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No te encuentras conectado a internet. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        } else if (status == ReachableViaWWAN) {
            if (video.is3G) {
                //The user can watch it with 3g
                [[[UIAlertView alloc] initWithTitle:nil message:@"Para una mejor experiencia conéctate a nua red Wi-Fi." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
                videoPlayer.modalPresentationStyle = UIModalPresentationOverFullScreen;
                videoPlayer.embedCode = video.embedHD;
                videoPlayer.isWatchingTrailer = NO;
                videoPlayer.progressSec = video.progressSec;
                videoPlayer.productID = self.productID;
                videoPlayer.episodeID = self.selectedEpisodeID;
                [self presentViewController:videoPlayer animated:YES completion:nil];
                
            } else {
                //The user can't watch the video because the connection is to slow
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tu conexión a internet es muy lenta. Por favor conéctate a una red Wi-Fi para poder ver el video." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
        } else if (status == ReachableViaWiFi) {
            //The user can watch the video
            VideoPlayerPadViewController *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayer"];
            videoPlayer.modalPresentationStyle = UIModalPresentationOverFullScreen;
            videoPlayer.embedCode = video.embedHD;
            videoPlayer.isWatchingTrailer = NO;
            videoPlayer.progressSec = video.progressSec;
            videoPlayer.productID = self.productID;
            videoPlayer.episodeID = self.selectedEpisodeID;
            [self presentViewController:videoPlayer animated:YES completion:nil];
        }
        
    } else {
        //The video is not available for the user, so pass to the
        //Content not available for user
        //TODO: definir que se hará cuando el video no esté disponible para el usuario
        NSLog(@"el contenido no está disponible para el usuario");
        ContentNotAvailableForUserPadViewController *contentNotAvailableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNotAvailableForUserPad"];
        contentNotAvailableVC.productID = self.selectedEpisodeID;
        contentNotAvailableVC.productName = self.production.name;
        contentNotAvailableVC.productType = self.production.type;
        contentNotAvailableVC.viewType = self.production.viewType;
        contentNotAvailableVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        contentNotAvailableVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:contentNotAvailableVC animated:YES completion:nil];
    }
}

#pragma mark - Notification Handlers

-(void)videoShouldBeDisplayedReceived {
    NSLog(@"llegó la notificación: video");
    [self.viewProductionButton removeFromSuperview];
    [self getIsContentAvailableForUserWithID:self.selectedEpisodeID];
}

#pragma mark - ServerCommunicator

-(void)getIsContentAvailableForUserWithID:(NSString *)episodeID {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"IsContentAvailableForUser" andParameter:[NSString stringWithFormat:@"%@?player_br=aim", episodeID]];
}

-(void)updateUserFeedbackForProductWithRate:(NSInteger)rate {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"%@/%@/%d", @"produccion",self.production.identifier, rate];
    [serverCommunicator callServerWithGETMethod:@"UpdateUserFeedbackForProduct" andParameter:parameters];
}

-(void)getProductionInfoWithID:(NSString *)productID {
    //Start animating the spinner
    [self.spinner startAnimating];
    
    //Communicate with the server
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:[NSString stringWithFormat:@"%@/%@?player_br=aim", productID, @"0"]];
    } else {
        NSString *userID = [UserInfo sharedInstance].userID;
        [serverCommunicator callServerWithGETMethod:@"GetProductWithID" andParameter:[NSString stringWithFormat:@"%@/%@?player_br=aim", productID, userID]];
    }
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    //Stop the spinner
    [self.spinner stopAnimating];
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //Responses: GetProductWithID
    if ([methodName isEqualToString:@"GetProductWithID"] && responseDictionary) {
        //FIXME: la posición en la cual llega la info de la producción no será la que se está usando
        //en este momento.
        if (![responseDictionary[@"products"][@"status"] boolValue]) {
            NSLog(@"El producto no está disponible");
            //Hubo algún problema y no se pudo acceder al producto
            if (responseDictionary[@"products"][@"response"]) {
                //Existe un mensaje de respuesta en el server, así que lo usamos en nuestra alerta
                NSString *alertMessage = responseDictionary[@"products"][@"response"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
            } else {
                //No existía un mensaje de respuesta en el servidor, entonces usamos un mensaje genérico.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No se pudo acceder al contenido. Por favor inténtalo de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
            }
        } else {
            //El producto si está disponible
            NSLog(@"info del producto: %@", responseDictionary);
            self.unparsedProductionInfoDic = responseDictionary[@"products"][@"0"][0];
        }
    
    //Response:UpdateUserFeedbackForProduct
    } else if ([methodName isEqualToString:@"UpdateUserFeedbackForProduct"]) {
        NSLog(@"recibí respuesta de UpdateUserFeedbackForProduct: %@", responseDictionary);
        
    //Response: IsContentAvailableForUser
    } else if ([methodName isEqualToString:@"IsContentAvailableForUser"] && [responseDictionary[@"status"] boolValue]) {
        NSLog(@"info del video: %@", responseDictionary);
        NSDictionary *videoDicWithNulls = responseDictionary[@"video"];
        NSDictionary *videoDicWithoutNulls = [videoDicWithNulls dictionaryByReplacingNullWithBlanks];
        Video *video = [[Video alloc] initWithDictionary:videoDicWithoutNulls];
        [self checkVideoAvailability:video];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un problema conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
    }
}

-(void)serverError:(NSError *)error {
    //Stop the spinner
    [self.spinner stopAnimating];
    
    NSLog(@"server error: %@, %@", error, [error localizedDescription]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    alert.tag = 1;
    [alert show];
}

#pragma mark - EpisodesPadTableViewCellDelegate

-(void)addButtonWasSelectedInCell:(EpisodesPadTableViewCell *)cell {
    NSLog(@"me llamé");
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Para poder crear listas de reproducción y añadir producciones debes ingresar con tu usuario." delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Ingresar", nil] show];
        return;
    }
    
    self.opacityView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.view addSubview:self.opacityView];
    
    AddToListView *addToListView = [[AddToListView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 200.0, self.view.bounds.size.height/2.0 - 150.0, 400.0, 300.0)];
    NSLog(@"add to list view frame: %@", NSStringFromCGRect(addToListView.frame));
    addToListView.delegate = self;
    [self.view addSubview:addToListView];
}

#pragma mark - AddToListViewDelegate 

-(void)listWasSelectedAtIndex:(NSUInteger)index inAddToListView:(AddToListView *)addToListView {
    NSLog(@"Me agregaron a la lista que estaba en el index %d", index);
    [[[UIAlertView alloc] initWithTitle:nil message:@"Agregado correctamente a tu lista!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)addToListViewDidDisappear:(AddToListView *)addToListView {
    [addToListView removeFromSuperview];
    addToListView = nil;
}

-(void)addToListViewWillDisappear:(AddToListView *)addToListView {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

#pragma mark - RateViewDelegate

-(void)rateButtonWasTappedInRateView:(RateView *)rateView withRate:(int)rate {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
    self.starsView.rate = rate;
    [self updateUserFeedbackForProductWithRate:rate*20];
}

-(void)cancelButtonWasTappedInRateView:(RateView *)rateView {
    self.opacityView.alpha = 0.0;
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

#pragma mark - UIActionSheetDelegate 

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Facebook
        SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *message = [NSString stringWithFormat:@"Estoy viendo %@ en CaracolPlay %@", self.production.name, @"https://itunes.apple.com/app/id714489424"];
        [facebookViewController setInitialText:message];
        [self presentViewController:facebookViewController animated:YES completion:nil];
      
    } else if (buttonIndex == 1) {
        //Twitter
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *message = [NSString stringWithFormat:@"Estoy viendo %@ en CaracolPlay %@", self.production.name, @"https://itunes.apple.com/app/id714489424"];
        [twitterViewController setInitialText:message];
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - SinopsisViewDelegate

-(void)closeButtonPressedInSinopsisView:(SinopsisView *)sinopsisView {
    
}

-(void)sinopsisViewDidDissapear:(SinopsisView *)sinopsisView {
    sinopsisView = nil;
}

@end
