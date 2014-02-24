//
//  MyListsViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyListsViewController.h"
#import "List.h"
#import "MyListsDetailsViewController.h"
#import "CreateListView.h"

static NSString *const cellIdentifier = @"CellIdentifier";

@interface MyListsViewController () <UITableViewDataSource, UITableViewDelegate, CreateListViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *unparsedUserListsArray;
@property (strong, nonatomic) NSMutableArray *parsedUserListsArray;
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation MyListsViewController

#pragma mark - Lazy Instantiation 

-(NSArray *)unparsedUserListsArray {
    if (!_unparsedUserListsArray) {
        _unparsedUserListsArray = @[@{@"list_name": @"Series clásicas", @"list_id" : @"1223",
                                      @"episodes" : @[@{@"product_name": @"Pedro el Escamoso",
                                                        @"episode_name": @"Pedro regresa",
                                                        @"description": @"Pedro regresa después de un terrible incidente de...",
                                                        @"image_url": @"http://4.bp.blogspot.com/__dyzpfPCZVk/SGva2EeqlKI/AAAAAAAAALM/1ctbJwwRrw8/s400/telenovelas10d.jpg",
                                                        @"episode_number": @6,
                                                        @"id": @"1235435",
                                                        @"url": @"http://www.eldominio.com/laurldeestevideo.video",
                                                        @"trailer_url": @"http://www.eldominio.com/laurldeltrailerdeestevideo.video",
                                                        @"rate": @3,
                                                        @"views": @4231,//Número de veces visto
                                                        @"duration": @2750,//En segundos
                                                        @"category_id": @"7816234",
                                                        @"progress_sec": @1500,//Tiempo del progreso (cuanto ha sido visto por el usuario)
                                                        @"watched_on": @"2014-02-05",
                                                        @"is_3g": @NO},
                                                      
                                                      @{@"product_name": @"Mujeres al límite",
                                                        @"episode_name": @"Pedro regresa",
                                                        @"description": @"Las mujeres están al limite",
                                                        @"image_url": @"http://www.eldiario.com.co/uploads/userfiles/20100704/image/monica_alta%5B1%5D-copia.jpg",
                                                        @"episode_number": @8,
                                                        @"id": @"1235435",
                                                        @"url": @"http://www.eldominio.com/laurldeestevideo.video",
                                                        @"trailer_url": @"http://www.eldominio.com/laurldeltrailerdeestevideo.video",
                                                        @"rate": @3,
                                                        @"views": @4231,//Número de veces visto
                                                        @"duration": @2750,//En segundos
                                                        @"category_id": @"7816234",
                                                        @"progress_sec": @1500,//Tiempo del progreso (cuanto ha sido visto por el usuario)
                                                        @"watched_on": @"2014-02-05",
                                                        @"is_3g": @NO}
                                                      ]},
                                    
                                    @{@"list_name": @"Lo mejor de lo mejor", @"list_id" : @"1223",
                                      @"episodes" : @[@{@"product_name": @"Escobar el patrón del mal",
                                                        @"episode_name": @"Pedro regresa",
                                                        @"description": @"Escobar es el gran capo",
                                                        @"image_url": @"http://www.vanguardia.com/sites/default/files/imagecache/Noticia_600x400/foto_grandes_400x300_noticia/2012/06/26/27salud01a013_big_tp.jpg",
                                                        @"episode_number": @3,
                                                        @"id": @"1235435",
                                                        @"url": @"http://www.eldominio.com/laurldeestevideo.video",
                                                        @"trailer_url": @"http://www.eldominio.com/laurldeltrailerdeestevideo.video",
                                                        @"rate": @3,
                                                        @"views": @4231,//Número de veces visto
                                                        @"duration": @2750,//En segundos
                                                        @"category_id": @"7816234",
                                                        @"progress_sec": @1500,//Tiempo del progreso (cuanto ha sido visto por el usuario)
                                                        @"watched_on": @"2014-02-05",
                                                        @"is_3g": @NO},
                                                      
                                                      @{@"product_name": @"Mentiras perfectas",
                                                        @"episode_name": @"Pedro regresa",
                                                        @"description": @"Las mentiras de Carolina afectan a Carlos",
                                                        @"image_url": @"http://www.publimetro.co/_internal/gxml!0/r0dc21o2f3vste5s7ezej9x3a10rp3w$b3cmqcdhj94frubk4j04omkoakkg83r/mentiras-perfectas.jpeg",
                                                        @"episode_number": @5,
                                                        @"id": @"1235435",
                                                        @"url": @"http://www.eldominio.com/laurldeestevideo.video",
                                                        @"trailer_url": @"http://www.eldominio.com/laurldeltrailerdeestevideo.video",
                                                        @"rate": @3,
                                                        @"views": @4231,//Número de veces visto
                                                        @"duration": @2750,//En segundos
                                                        @"category_id": @"7816234",
                                                        @"progress_sec": @1500,//Tiempo del progreso (cuanto ha sido visto por el usuario)
                                                        @"watched_on": @"2014-02-05",
                                                        @"is_3g": @NO}
                                                      ]}];
    }
    return _unparsedUserListsArray;
}

-(NSMutableArray *)parsedUserListsArray {
    if (!_parsedUserListsArray) {
        _parsedUserListsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.unparsedUserListsArray count]; i++) {
            List *list = [[List alloc] initWithDictionary:self.unparsedUserListsArray[i]];
            [_parsedUserListsArray addObject:list];
        }
    }
    return _parsedUserListsArray;
}

/*-(void)parseUserLists {
    self.parsedUserListsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedUserListsArray count]; i++) {
        List *list = [[List alloc] initWithDictionary:self.unparsedUserListsArray[i]];
        [self.parsedUserListsArray addObject:list];
    }
}*/


#pragma mark - UISetup & Initialization Stuff

-(void)UISetup {
    //1. Create a segmented control to choose my lists or the recommended lists
    /*UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Mis Listas", @"Recomendadas"]];
    segmentedControl.frame = CGRectMake(40.0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 10.0, self.view.frame.size.width - 80.0, 29.0);
    segmentedControl.tintColor = [UIColor whiteColor];
    [self.view addSubview:segmentedControl];*/
    
    //1. Create a bar button item to create lists
    UIBarButtonItem *createListBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                             target:self
                                                                                             action:@selector(createList)];
    self.navigationItem.rightBarButtonItem = createListBarButtonItem;
    
    //2. Create a table view to display the user's lists
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 50.0)) style:UITableViewStylePlain];
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
    //[self parseLists];
    [self UISetup];
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
    cell.textLabel.text = ((List *)self.parsedUserListsArray[indexPath.row]).listName;
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyListsDetailsViewController *myListsDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyListsDetail"];
    List *list = self.parsedUserListsArray[indexPath.row];
    myListsDetailsVC.episodes = [NSMutableArray arrayWithArray:list.episodes];
    [self.navigationController pushViewController:myListsDetailsVC animated:YES];
}

#pragma mark - Actions 

-(void)createList {
    self.opacityView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.tabBarController.view addSubview:self.opacityView];
    
    CreateListView *createListView = [[CreateListView alloc] initWithFrame:CGRectMake(30.0, 200.0, self.view.frame.size.width - 60.0, 150.0)];
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

#pragma mark - CreateListViewDelegate

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
    [createListView removeFromSuperview];
    createListView = nil;
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
