//
//  CategoriesViewController.m
//  CaracolPlay
//
//  Created by Developer on 21/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Categoria.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "FileSaver.h"

static NSString *CellIdentifier = @"CellIdentifier";

@interface CategoriesViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) NSArray *unparsedCategoriesList;
@property (strong, nonatomic) NSMutableArray *parsedCategoriesList;
@property (strong, nonatomic) Categoria *lastSeenCategory;
@property (strong, nonatomic) UITableView *categoriesTableView;
@end

@implementation CategoriesViewController

#pragma mark - Setters & Getters

-(void)setUnparsedCategoriesList:(NSArray *)unparsedCategoriesList {
    _unparsedCategoriesList = unparsedCategoriesList;
    [self parseCategoriesListFromServer];
    [self UISetup];
}

-(void)parseCategoriesListFromServer {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    BOOL userIsLoggedIn = [[fileSaver getDictionary:@"UserHasLoginDic"][@"UserHasLoginKey"] boolValue];
    
    self.parsedCategoriesList = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedCategoriesList count]; i++) {
        Categoria *category = [[Categoria alloc] initWithDictionary:self.unparsedCategoriesList[i]];
        [self.parsedCategoriesList addObject:category];
        if ([category.identifier isEqualToString:@"1"] && !userIsLoggedIn) {
            self.lastSeenCategory = category;
            [self.parsedCategoriesList removeObject:category];
        }
    }
    NSLog(@"Numero de categorias: %d", [self.parsedCategoriesList count]);
}

#pragma mark - UISetup

-(void)UISetup {
    
    
    //1. Create a TableView to display the categories
    self.categoriesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                                     0.0,
                                                                                     self.view.bounds.size.width,
                                                                                     self.view.bounds.size.height -  44.0)
                                                                    style:UITableViewStylePlain];
    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
    self.categoriesTableView.backgroundColor = [UIColor blackColor];
    self.categoriesTableView.rowHeight = 50.0;
    self.categoriesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.categoriesTableView.separatorColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self.view addSubview:self.categoriesTableView];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Categorías";
    [self getCategoriesFromServer];
    
    //Create a bar button item to recall the getCategoriesFromServer method
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                          target:self
                                                                                          action:@selector(getCategoriesFromServer)];
    self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createLastSeenCategory)
                                                 name:@"CreateLastSeenCategory"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eraseLastSeenCategory)
                                                 name:@"EraseLastSeenCategory"
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.parsedCategoriesList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height)];
        selectedView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        cell.selectedBackgroundView = selectedView;
    }
    
    Categoria *category = self.parsedCategoriesList[indexPath.row];
    cell.textLabel.text = category.name;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Categoria *category = self.parsedCategoriesList[indexPath.row];
    ProductionsListViewController *productionListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Movies"];
    productionListVC.categoryID = category.identifier;
    productionListVC.navigationBarTitle = category.name;
    [self.navigationController pushViewController:productionListVC animated:YES];
}

#pragma mark - Server Stuff

-(void)getCategoriesFromServer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Cargando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetCategories" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Recibí una respuesta del server");
    if ([methodName isEqualToString:@"GetCategories"] && responseDictionary) {
        NSLog(@"la petición fue exitosa. results dic: %@", responseDictionary);
        self.unparsedCategoriesList = responseDictionary[@"categories"];
    } else {
        NSLog(@"error: %@", responseDictionary);
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Se produjo un error en el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Se produjo un error al conectarse con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Notification Handlers

-(void)createLastSeenCategory {
    //[self.parsedCategoriesList insertObject:self.lastSeenCategory atIndex:0];
    //[self.categoriesTableView reloadData];
}

-(void)eraseLastSeenCategory {
    for (Categoria *category in self.parsedCategoriesList) {
        if ([category.identifier isEqualToString:@"1"]) {
            [self.parsedCategoriesList removeObject:category];
            break;
        }
    }
    [self.categoriesTableView reloadData];
}

- (NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
