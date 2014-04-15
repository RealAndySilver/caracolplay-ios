//
//  MyListsViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsViewController.h"
#import "MyListsDetailsViewController.h"
#import "CreateListView.h"
#import "ServerCommunicator.h"
#import "Episode.h"
#import "List.h"
#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"
#import "MBProgressHUD.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface MyListsViewController () <UITableViewDataSource, UITableViewDelegate, CreateListViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *unparsedUserListsArray;
@property (strong, nonatomic) NSMutableArray *parsedUserListsArray;
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation MyListsViewController

#pragma mark - Setters & Getters 

-(void)setUnparsedUserListsArray:(NSArray *)unparsedUserListsArray {
    NSLog(@"entré al setter");
    _unparsedUserListsArray = unparsedUserListsArray;
    //NSArray *unparsedUserListsWithoutNulls = [_unparsedUserListsArray arrayByReplacingNullsWithBlanks];
    self.parsedUserListsArray = [self parseUserListsArrayWithArray:unparsedUserListsArray];
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

#pragma mark - UISetup & Initialization Stuff

-(void)UISetup {
    NSLog(@"entré al setup");
    //1. Create a segmented control to choose my lists or the recommended lists
    /*UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Mis Listas", @"Recomendadas"]];
    segmentedControl.frame = CGRectMake(40.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 10.0, self.view.frame.size.width - 80.0, 29.0);
    segmentedControl.tintColor = [UIColor whiteColor];
    [self.view addSubview:segmentedControl];*/
    
    //1. Create a bar button item to create lists
    /*UIBarButtonItem *createListBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                             target:self
                                                                                             action:@selector(createList)];
    self.navigationItem.leftBarButtonItem = createListBarButtonItem;*/
    
    //2. Create a table view to display the user's lists
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 44.0) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self getUserLists];
    //[self parseLists];
    //[self UISetup];
    
    //Create a bar button item to reload the table view
    UIBarButtonItem *reloadBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                         target:self
                                                                                         action:@selector(getUserLists)];
    self.navigationItem.rightBarButtonItem = reloadBarButtonItem;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Mis Listas";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.parsedUserListsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    List *list = self.parsedUserListsArray[indexPath.row];
    cell.textLabel.text = list.listName;
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //TODO: terminar este método
    MyListsDetailsViewController *myListsDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsDetail"];
    List *list = self.parsedUserListsArray[indexPath.row];
    myListsDetailsVC.episodes = list.episodes;
    myListsDetailsVC.navigationBarTitle = list.listName;
    [self.navigationController pushViewController:myListsDetailsVC animated:YES];
}

#pragma mark - Actions 

-(void)createList {
    self.opacityView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.tabBarController.view addSubview:self.opacityView];
    
    CreateListView *createListView = [[CreateListView alloc] initWithFrame:CGRectMake(30.0, self.view.frame.size.height/2 - 30.0, self.view.frame.size.width - 60.0, 150.0)];
    createListView.delegate = self;
    [self.tabBarController.view addSubview:createListView];
}

#pragma mark - Custom Methods

-(void)addNewListWithName:(NSString *)listName {
    /*NSDictionary *newListDic = @{@"list_name": listName, @"list_id" : @"235345"};
    List *newList = [[List alloc] initWithDictionary:newListDic];
    [self.parsedUserListsArray addObject:newList];
    [self.tableView reloadData];*/
}

#pragma mark - Server Stuff

/*-(void)createListWithName:(NSString *)listName userID:(NSInteger)userID {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Creando..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    NSString *parameter = [NSString stringWithFormat:@"%@/%d", listName, userID];
    [serverCommunicator callServerWithGETMethod:@"CreateList" andParameter:parameter];
}*/

-(void)getUserLists {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetUserLists" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"recibí info del server");
    
    if ([methodName isEqualToString:@"GetUserLists"]) {
        if (!responseDictionary) {
             [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No fue posible acceder a tus listas. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            self.unparsedUserListsArray = responseDictionary[@"user_lists"];
        }
        
    } else if ([methodName isEqualToString:@"CreateList"]) {
        if (!responseDictionary) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No fue posible crear la lista. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            NSLog(@"llegó la respuesta de la creación de la lista: %@", responseDictionary);
        }
        
    } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"server error: %@, %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No fue posible conectarse con el servidor. Por favor intenta de nuevo en un momento." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - CreateListViewDelegate

/*-(void)createButtonPressedInCreateListView:(CreateListView *)createListView withListName:(NSString *)listName {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
    NSLog(@"cree la lista");
    [self createListWithName:listName userID:554];
    //[self addNewListWithName:listName];
}

-(void)cancelButtonPressedInCreateListView:(CreateListView *)createListView {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

-(void)hiddeAnimationDidEndInCreateListView:(CreateListView *)createListView {
    [createListView removeFromSuperview];
    createListView = nil;
}*/

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
