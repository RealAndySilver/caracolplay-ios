//
//  CategoriesMasterPadViewController.m
//  CaracolPlay
//
//  Created by Developer on 11/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CategoriesMasterPadViewController.h"
#import "CategoriesDetailPadViewController.h"
#import "ServerCommunicator.h"
#import "Categoria.h"

@interface CategoriesMasterPadViewController () <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *unparsedCategoriesList;
@property (strong, nonatomic) NSMutableArray *parsedCategoriesList;
@property (strong, nonatomic) CategoriesDetailPadViewController *categoriesDetailVC;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIImageView *titleImageView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation CategoriesMasterPadViewController

#pragma mark - Lazy Instantiation 

-(void)setUnparsedCategoriesList:(NSArray *)unparsedCategoriesList {
    _unparsedCategoriesList = unparsedCategoriesList;
    [self parseCategoriesListFromServer];
    //Post a notification with the first category ID and send this info to the CategoriesDetailController
    Categoria *firstCategory = self.parsedCategoriesList[0];
    NSLog(@"first category id: %@", firstCategory.identifier);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CategoryIDNotification" object:nil userInfo:@{@"CategoryID": firstCategory.identifier}];
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

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(50.0, self.view.bounds.size.height/2.0 - 20.0, 40.0, 40.0);
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
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.view addSubview:self.tableView];
    
    //2. navigation Bar
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarMaster.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    //3. Orange title image view
    self.titleImageView = [[UIImageView alloc] init];
    self.titleImageView.image = [UIImage imageNamed:@"CategoriesOrangeTitle.png"];
    [self.view addSubview:self.titleImageView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.spinner];
    [self getCategories];
    //[self UISetup];
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
    return [self.parsedCategoriesList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    Categoria *category = self.parsedCategoriesList[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = category.name;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Categoria *category = self.parsedCategoriesList[indexPath.row];
    self.categoriesDetailVC = self.splitViewController.viewControllers[1];
    self.categoriesDetailVC.categoryID = category.identifier;
}

#pragma mark - Server Stuff 

-(void)getCategories {
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetCategories" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)responseDictionary withMethodName:(NSString *)methodName {
    NSLog(@"llegó la respuesta del server");
    [self.spinner stopAnimating];
    if ([methodName isEqualToString:@"GetCategories"] && [responseDictionary[@"status"] boolValue]) {
        self.unparsedCategoriesList = responseDictionary[@"categories"];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error al conectarse con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error al conectarse con el servidor. Por favor intenta de nuevo en unos momentos" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
