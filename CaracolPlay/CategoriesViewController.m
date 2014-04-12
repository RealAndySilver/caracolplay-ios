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
#import "MBHUDView.h"

static NSString *CellIdentifier = @"CellIdentifier";

@interface CategoriesViewController () <ServerCommunicatorDelegate>
@property (strong, nonatomic) NSArray *unparsedCategoriesList;
@property (strong, nonatomic) NSMutableArray *parsedCategoriesList;
@end

@implementation CategoriesViewController

#pragma mark - Lazy Instantiation 

/*-(NSArray *)unparsedCategoriesList {
    if (!_unparsedCategoriesList) {
        _unparsedCategoriesList = @[@{@"name": @"Vistos Recientemente", @"id" : @"23556"},
                                    @{@"name": @"Mis Redimidos", @"id" : @"23532"},
                                    @{@"name": @"Mis Alquilados", @"id" : @"22133"},
                                    @{@"name": @"Telenovelas", @"id" : @"64556"},
                                    @{@"name": @"Películas", @"id" : @"64556"},
                                    @{@"name": @"Noticias", @"id" : @"23456"},
                                    @{@"name": @"Eventos en vivo", @"id" : @"63656"}];
    }
    return _unparsedCategoriesList;
}*/

#pragma mark - UISetup & Initialization stuff

/*-(void)parseCategoriesList {
    self.parsedCategoriesList = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedCategoriesList count]; i++) {
        Categoria *category = [[Categoria alloc] initWithDictionary:self.unparsedCategoriesList[i]];
        [self.parsedCategoriesList addObject:category];
    }
    NSLog(@"parse count: %d", [self.parsedCategoriesList count]);
}*/

-(void)setUnparsedCategoriesList:(NSArray *)unparsedCategoriesList {
    _unparsedCategoriesList = unparsedCategoriesList;
    [self parseCategoriesListFromServer];
    [self UISetup];
}

-(void)parseCategoriesListFromServer {
    self.parsedCategoriesList = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.unparsedCategoriesList count]; i++) {
        Categoria *category = [[Categoria alloc] initWithDictionary:self.unparsedCategoriesList[i]];
        [self.parsedCategoriesList addObject:category];
    }
    NSLog(@"Numero de categorias: %d", [self.parsedCategoriesList count]);
}

-(void)UISetup {
    
    
    //1. Create a TableView to display the categories
    UITableView *categoriesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                                     0.0,
                                                                                     self.view.bounds.size.width,
                                                                                     self.view.bounds.size.height -  44.0)
                                                                    style:UITableViewStylePlain];
    categoriesTableView.delegate = self;
    categoriesTableView.dataSource = self;
    categoriesTableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    categoriesTableView.rowHeight = 50.0;
    categoriesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    categoriesTableView.separatorColor = [UIColor blackColor];
    [self.view addSubview:categoriesTableView];
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
    
    //[self parseCategoriesList];
    //[self UISetup];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Server Stuff

-(void)getCategoriesFromServer {
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [MBHUDView hudWithBody:@"Cargando" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:100 show:YES];
    [serverCommunicator callServerWithGETMethod:@"GetCategories" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    [MBHUDView dismissCurrentHUD];
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
    [MBHUDView dismissCurrentHUD];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Se produjo un error al conectarse con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
