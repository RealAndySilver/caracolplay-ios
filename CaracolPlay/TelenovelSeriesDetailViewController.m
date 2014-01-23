//
//  TelenovelSeriesViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

static NSString *const cellIdentifier = @"CellIdentifier";

#import "TelenovelSeriesDetailViewController.h"

@interface TelenovelSeriesDetailViewController ()

@end

@implementation TelenovelSeriesDetailViewController

-(void)UISetup {
    //1. create an image view to show the production image
    UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, self.navigationController.navigationBar.frame.origin.x + self.navigationController.navigationBar.frame.size.height + 10.0, 80.0, 120.0)];
    mainImageView.clipsToBounds = YES;
    mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    mainImageView.image = [UIImage imageNamed:@"MentirasPerfectas.jpg"];
    [self.view addSubview:mainImageView];
    
    //2. create a textview to show de details of the production
    UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(mainImageView.frame.origin.x + mainImageView.frame.size.width + 10.0, mainImageView.frame.origin.y, 200.0, mainImageView.frame.size.height)];
    detailTextView.backgroundColor = [UIColor clearColor];
    detailTextView.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.";
    detailTextView.font = [UIFont systemFontOfSize:13.0];
    detailTextView.textAlignment = NSTextAlignmentJustified;
    detailTextView.textColor = [UIColor whiteColor];
    [self.view addSubview:detailTextView];
    
    //3. create a button to share the production
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 190.0, 80.0, 30.0)];
    [shareButton setTitle:@"Compartir" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:shareButton];
    
    //4. Create a button to show more info of the production
    UIButton *showMoreInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(100.0, shareButton.frame.origin.y, 80.0, 30.0)];
    [showMoreInfoButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [showMoreInfoButton setTitle:@"Mas Info" forState:UIControlStateNormal];
    showMoreInfoButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:showMoreInfoButton];
    
    //5. Create a button to watch the trailer of the production
    UIButton *showTrailerButton = [[UIButton alloc] initWithFrame:CGRectMake(200.0, shareButton.frame.origin.y, 80.0, 30.0)];
    [showTrailerButton setTitle:@"Ver Trailer" forState:UIControlStateNormal];
    [showTrailerButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    showTrailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.view addSubview:showTrailerButton];
    
    //6. Create a TableView to diaply the list of chapters
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 230.0, self.view.frame.size.width, self.view.frame.size.height - 220.0 - 44.0) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor blackColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    tableView.rowHeight = 50.0;
    [self.view addSubview:tableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Mentiras Perfectas";
    [self UISetup];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TelenovelSeriesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TelenovelSeriesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.chapterNumberLabel.text = @"1";
    cell.chapterNameLabel.text = @"Nombre del capítulo";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
