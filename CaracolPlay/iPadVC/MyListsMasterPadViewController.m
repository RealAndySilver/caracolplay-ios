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

@interface MyListsMasterPadViewController () <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate, CreateListViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *unparsedUserListsArray;
@property (strong, nonatomic) NSMutableArray *parsedUserListsArray;
@property (strong, nonatomic) MyListsDetailPadViewController *myListsDetailVC;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIImageView *titleImageView;
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation MyListsMasterPadViewController

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
                                                        @"is_3g": @NO}
                                                      ]},
                                    
                                    @{@"list_name": @"Lo mejor de lo mejor", @"list_id" : @"1223",
                                      @"episodes" : @[@{@"product_name": @"Escobar el patrón del mal",
                                                        @"episode_name": @"Pedro regresa",
                                                        @"description": @"Escobar es el gran capo",
                                                        @"image_url": @"http://www.vanguardia.com/sites/default/files/imagecache/Noticia_600x400/foto_grandes_400x300_noticia/2012/06/26/27salud01a013_big_tp.jpg",
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
                                                      
                                                      @{@"product_name": @"Mentiras perfectas",
                                                        @"episode_name": @"Pedro regresa",
                                                        @"description": @"Las mentiras de Carolina afectan a Carlos",
                                                        @"image_url": @"http://www.publimetro.co/_internal/gxml!0/r0dc21o2f3vste5s7ezej9x3a10rp3w$b3cmqcdhj94frubk4j04omkoakkg83r/mentiras-perfectas.jpeg",
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
                                                        @"is_3g": @NO}
                                                      ]}];
    }
    return _unparsedUserListsArray;
}

-(void)parseUserLists {
    self.parsedUserListsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedUserListsArray count]; i++) {
        List *list = [[List alloc] initWithDictionary:self.unparsedUserListsArray[i]];
        [self.parsedUserListsArray addObject:list];
    }
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
    [self parseUserLists];
    [self UISetup];
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
