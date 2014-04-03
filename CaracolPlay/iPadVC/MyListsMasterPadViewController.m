//
//  MyListsMasterPadViewController.m
//  CaracolPlay
//
//  Created by Diego Vidal on 14/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsMasterPadViewController.h"
#import "MyListsDetailPadViewController.h"
#import "List.h"
#import "CreateListView.h"
#import "ServerCommunicator.h"
#import "Episode.h"
#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"

@interface MyListsMasterPadViewController () <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate, CreateListViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *unparsedUserListsArray;
@property (strong, nonatomic) NSMutableArray *parsedUserListsArray;
@property (strong, nonatomic) MyListsDetailPadViewController *myListsDetailVC;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIImageView *titleImageView;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation MyListsMasterPadViewController

#pragma mark - Setters & Getters

-(void)setUnparsedUserListsArray:(NSArray *)unparsedUserListsArray {
    NSLog(@"entré al setter");
    _unparsedUserListsArray = unparsedUserListsArray;
    self.parsedUserListsArray = [self parseUserListsArrayWithArray:unparsedUserListsArray];
    List *list = self.parsedUserListsArray[0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FirstUserListNotification" object:nil userInfo:@{@"FirstUserList": list.episodes}];
    
    NSLog(@"numero de listas parseadas: %d", [self.parsedUserListsArray count]);
    [self UISetup];
}

#pragma mark - Parsing Methods

-(NSMutableArray *)parseUserListsArrayWithArray:(NSArray *)unparsedArray {
    NSMutableArray *parsedArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [unparsedArray count]; i++) {
        NSLog(@"numero de lista: %d", [unparsedArray[i] count]);
        NSDictionary *unparsedListDic = unparsedArray[i];
        NSArray *episodesFromListArray = unparsedListDic[@"episodes"];
        NSMutableArray *parsedEpisodesFromList = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [episodesFromListArray count]; j++) {
            NSDictionary *dicWithoutNulls = [episodesFromListArray[j] dictionaryByReplacingNullWithBlanks];
            Episode *episode = [[Episode alloc] initWithDictionary:dicWithoutNulls];
            [parsedEpisodesFromList addObject:episode];
        }
        
        List *list = [[List alloc] initWithDictionary:unparsedListDic];
        list.episodes = parsedEpisodesFromList;
        
        [parsedArray addObject:list];
    }
    
    return parsedArray;
}

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(160.0 - 20.0, 384 - 20.0, 40.0, 40.0);
    }
    return _spinner;
}

-(void)UISetup {
    //1. categories list
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    
    //2. navigation Bar
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarMaster.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    self.navigationBar.items = @[navigationItem];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createList)];
    
    //3. Orange title image view
    self.titleImageView = [[UIImageView alloc] init];
    self.titleImageView.image = [UIImage imageNamed:@"MyListsOrangeTitle.png"];
    [self.view addSubview:self.titleImageView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.spinner];
    [self getUserLists];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"Bounds: %@", NSStringFromCGRect(self.view.bounds));
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.titleImageView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, 73.0);
    self.tableView.frame = CGRectMake(0.0, self.titleImageView.frame.origin.y + self.titleImageView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.titleImageView.frame.origin.y + self.titleImageView.frame.size.height));
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.parsedUserListsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    List *list = self.parsedUserListsArray[indexPath.row];
    cell.textLabel.text = list.listName;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.myListsDetailVC = self.splitViewController.viewControllers[1];
    
    List *list = self.parsedUserListsArray[indexPath.row];
    NSLog(@"list name: %@", list.listName);
    self.myListsDetailVC.episodes = [NSMutableArray arrayWithArray:list.episodes];
}

#pragma mark - Actions

-(void)createList {
    CGRect frame = self.tabBarController.view.bounds;
    
    self.opacityView = [[UIView alloc] initWithFrame:frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.tabBarController.view addSubview:self.opacityView];
    
    CreateListView *createListView = [[CreateListView alloc] initWithFrame:CGRectMake(frame.size.width/2 - 150.0, frame.size.height/2 - 75.0, 300.0, 150.0)];
    createListView.delegate = self;
    [self.tabBarController.view addSubview:createListView];
}

#pragma mark - Custom Methods

-(void)addNewListWithName:(NSString *)listName {
    NSDictionary *newListDic = @{@"list_name": listName, @"list_id" : @"235345", @"episodes" : @[]};
    List *newList = [[List alloc] initWithDictionary:newListDic];
    [self.parsedUserListsArray addObject:newList];
    [self.tableView reloadData];
}

#pragma mark - Server Stuff

-(void)getUserLists {
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetUserLists" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    if ([methodName isEqualToString:@"GetUserLists"] && responseDictionary) {
        self.unparsedUserListsArray = responseDictionary[@"user_lists"];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error al conectarse con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error accediendo al servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma  mark - CreateListViewDelegate

-(void)createButtonPressedInCreateListView:(CreateListView *)createListView withListName:(NSString *)listName {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
    [self addNewListWithName:listName];
}

-(void)cancelButtonPressedInCreateListView:(CreateListView *)createListView {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

-(void)hiddeAnimationDidEndInCreateListView:(CreateListView *)createListView {
    createListView = nil;
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
