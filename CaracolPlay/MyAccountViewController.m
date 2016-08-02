//
//  MyAccountViewController.m
//  CaracolPlay
//
//  Created by Developer on 31/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyAccountViewController.h"
#import "FileSaver.h"
#import "LoginViewController.h"
#import "MyNavigationController.h"
#import "HomeViewController.h"
#import "TermsAndConditionsViewController.h"
#import "UserInfo.h"
#import "ServerCommunicator.h"
#import "NSDictionary+NullReplacement.h"
#import "MBProgressHUD.h"
#import "TelenovelSeriesDetailViewController.h"
#import "MoviesEventsDetailsViewController.h"
#import "UIColor+AppColors.h"

@interface MyAccountViewController () <UITableViewDataSource, UITableViewDelegate,  ServerCommunicatorDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *personalInfoTableViewTitles;
@property (strong, nonatomic) NSMutableArray *personalInfoTableViewSecondaryInfo;
@property (strong, nonatomic) NSArray *suscriptionInfoTableViewTitles;
@property (strong, nonatomic) NSMutableArray *suscriptionInfoTableViewSecondaryInfo;
@property (strong, nonatomic) NSDictionary *personalInfo;
@property (strong, nonatomic) NSDictionary *suscriptionDic;
@property (strong, nonatomic) NSArray *rentedProductions;
@end

@implementation MyAccountViewController

#pragma mark - Lazy Instantiations 

-(NSArray *)suscriptionInfoTableViewTitles {
    if (!_suscriptionInfoTableViewTitles) {
        _suscriptionInfoTableViewTitles = @[@"Tipo de Suscripción", @"Fecha de Vencimiento"];
    }
    return _suscriptionInfoTableViewTitles;
}

/*-(NSArray *)suscriptionInfoTableViewSecondaryInfo {
    if (!_suscriptionInfoTableViewSecondaryInfo) {
        _suscriptionInfoTableViewSecondaryInfo = @[@"Normal", @"15/10/2015"];
    }
    return _suscriptionInfoTableViewSecondaryInfo;
}*/

-(NSArray *)personalInfoTableViewTitles {
    if (!_personalInfoTableViewTitles) {
        _personalInfoTableViewTitles = @[@"Nombres", @"Apellidos", @"Fecha de Nacimiento", @"Género", @"Alias", @"Mail"];
    }
    return _personalInfoTableViewTitles;
}

-(void)setPersonalInfo:(NSDictionary *)personalInfo {
    _personalInfo = personalInfo;
    self.personalInfoTableViewSecondaryInfo = [[NSMutableArray alloc] init];
    [self.personalInfoTableViewSecondaryInfo addObject:personalInfo[@"nombres"]];
    [self.personalInfoTableViewSecondaryInfo addObject:personalInfo[@"apellidos"]];
    [self.personalInfoTableViewSecondaryInfo addObject:personalInfo[@"fecha_de_nacimiento"]];
    [self.personalInfoTableViewSecondaryInfo addObject:personalInfo[@"genero"]];
    [self.personalInfoTableViewSecondaryInfo addObject:personalInfo[@"alias"]];
    [self.personalInfoTableViewSecondaryInfo addObject:personalInfo[@"mail"]];
    
    self.suscriptionInfoTableViewSecondaryInfo = [[NSMutableArray alloc] init];
    if ([self.suscriptionDic[@"is_suscription"] boolValue]) {
        [self.suscriptionInfoTableViewSecondaryInfo addObject:@"Normal"];
        [self.suscriptionInfoTableViewSecondaryInfo addObject:self.suscriptionDic[@"time_ends"]];
    } else {
        [self.suscriptionInfoTableViewSecondaryInfo addObject:@"-"];
        [self.suscriptionInfoTableViewSecondaryInfo addObject:@"-"];
    }
    
    [self UISetup];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Mi Cuenta";
    self.view.backgroundColor = [UIColor caracolLightGrayColor];
    [self getUser];
}

#pragma mark - UI Setup

-(void)UISetup {
    
    //1. Scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 50.0)];
    self.scrollView.backgroundColor = [UIColor caracolLightGrayColor];
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    
    //2. label 'Datos Personales'
    UILabel *personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 150.0, 30.0)];
    personalInfoLabel.text = @"DATOS PERSONALES";
    personalInfoLabel.font = [UIFont systemFontOfSize:13.0];
    personalInfoLabel.textColor = [UIColor blackColor];
    [self.scrollView addSubview:personalInfoLabel];
    
    //3. Personal info table view
    UITableView *personalInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 40.0, self.view.frame.size.width, 262.0)
                                                                      style:UITableViewStylePlain];
    personalInfoTableView.delegate = self;
    personalInfoTableView.dataSource  = self;
    personalInfoTableView.userInteractionEnabled = NO;
    personalInfoTableView.tag = 1;
    personalInfoTableView.backgroundColor = [UIColor whiteColor];
    personalInfoTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    personalInfoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:personalInfoTableView];
    
    //4. Some informative text label
    NSMutableAttributedString *informativeString = [[NSMutableAttributedString alloc] initWithString:@"Tus datos no son editables en la versión móvil del sitio. Conéctate a www.caracolplay.com desde tu computador para poder modificar tus datos personales."];
    NSDictionary *firstAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    NSDictionary *secondAttributes = @{NSForegroundColorAttributeName: [UIColor caracolMediumBlueColor]};
    [informativeString setAttributes:secondAttributes range:NSMakeRange(69, 20)];
    [informativeString setAttributes:firstAttributes range:NSMakeRange(90, 61)];
    [informativeString setAttributes:firstAttributes range:NSMakeRange(0, 69)];
    
    UITextView *informativeTextLabel = [[UITextView alloc] initWithFrame:CGRectMake(10.0, personalInfoTableView.frame.origin.y + personalInfoTableView.frame.size.height, self.view.frame.size.width-20, 64.0)];
    informativeTextLabel.attributedText = informativeString;
    informativeTextLabel.backgroundColor = [UIColor clearColor];
    informativeTextLabel.userInteractionEnabled = NO;
    informativeTextLabel.font = [UIFont systemFontOfSize:12.0];
    [self.scrollView addSubview:informativeTextLabel];
    
    //'Mis Alquilados'
    UILabel *rentedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, informativeTextLabel.frame.origin.y + informativeTextLabel.frame.size.height + 20.0, 200.0, 30.0)];
    rentedLabel.text = @"MIS ALQUILADOS";
    rentedLabel.font = [UIFont systemFontOfSize:13.0];
    rentedLabel.textColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:rentedLabel];
    
    //4. 'Mis alquilados' table view
    UITableView *rentedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, informativeTextLabel.frame.origin.y + informativeTextLabel.frame.size.height + 50.0, self.view.frame.size.width, 160.0) style:UITableViewStylePlain];
    rentedTableView.delegate = self;
    rentedTableView.dataSource = self;
    rentedTableView.tag = 3;
    rentedTableView.backgroundColor = [UIColor whiteColor];
    //rentedTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    rentedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:rentedTableView];
    
    //5. Suscription label
    UILabel *suscriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, rentedTableView.frame.origin.y + rentedTableView.frame.size.height + 10.0, 100.0, 30.0)];
    suscriptionLabel.text = @"SUSCRIPCIÓN:";
    suscriptionLabel.textColor = [UIColor lightGrayColor];
    suscriptionLabel.font = [UIFont systemFontOfSize:13.0];
    [self.scrollView addSubview:suscriptionLabel];
    
    //6. SuscriptionInfo table view
    UITableView *suscriptionInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, suscriptionLabel.frame.origin.y + suscriptionLabel.frame.size.height, self.view.frame.size.width, 86.0) style:UITableViewStylePlain];
    suscriptionInfoTableView.delegate = self;
    suscriptionInfoTableView.dataSource = self;
    suscriptionInfoTableView.tag = 2;
    suscriptionInfoTableView.userInteractionEnabled = NO;
    suscriptionInfoTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    suscriptionInfoTableView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:suscriptionInfoTableView];
    
    //7. 'Cerrar Sesión' button
    UIButton *closeSessionButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, suscriptionInfoTableView.frame.origin.y + suscriptionInfoTableView.frame.size.height + 30.0, self.view.frame.size.width - 60.0, 40.0)];
    [closeSessionButton setTitle:@"Cerrar Sesión" forState:UIControlStateNormal];
    closeSessionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [closeSessionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeSessionButton setBackgroundColor:[UIColor caracolMediumBlueColor]];
    closeSessionButton.layer.cornerRadius = 5.0;
    //[closeSessionButton setBackgroundImage:[UIImage imageNamed:@"BotonCerrarSesion"] forState:UIControlStateNormal];
    [closeSessionButton addTarget:self action:@selector(closeSession) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:closeSessionButton];
    
    //8. 'Terminos y condiciones' button
    UIButton *termsAndConditionsButton = [[UIButton alloc] initWithFrame:CGRectMake(50.0, closeSessionButton.frame.origin.y + closeSessionButton.frame.size.height + 20.0, self.view.frame.size.width - 100.0, 30.0)];
    [termsAndConditionsButton setTitle:@"Términos y Condiciones" forState:UIControlStateNormal];
    [termsAndConditionsButton setTitleColor:[UIColor caracolMediumBlueColor] forState:UIControlStateNormal];
    [termsAndConditionsButton addTarget:self action:@selector(goToConditionsTerms) forControlEvents:UIControlEventTouchUpInside];
    termsAndConditionsButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.scrollView addSubview:termsAndConditionsButton];
    
    //9. 'Politicas del servicio' button
    UIButton *serviceTermsButton = [[UIButton alloc] initWithFrame:CGRectMake(50.0, termsAndConditionsButton.frame.origin.y + termsAndConditionsButton.frame.size.height + 10.0, self.view.frame.size.width - 100.0, 30.0)];
    [serviceTermsButton setTitle:@"Políticas de privacidad" forState:UIControlStateNormal];
    [serviceTermsButton setTitleColor:[UIColor caracolMediumBlueColor] forState:UIControlStateNormal];
    [serviceTermsButton addTarget:self action:@selector(goToPrivacyTerms) forControlEvents:UIControlEventTouchUpInside];
    serviceTermsButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.scrollView addSubview:serviceTermsButton];
    
    
    //10. App version label
    UILabel *appVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, serviceTermsButton.frame.origin.y + serviceTermsButton.frame.size.height + 10.0, self.view.frame.size.width - 100.0, 30.0)];
    appVersionLabel.textAlignment = NSTextAlignmentCenter;
    appVersionLabel.text = @"Caracol Play Versión 1.0";
    appVersionLabel.textColor = [UIColor lightGrayColor];
    appVersionLabel.font = [UIFont boldSystemFontOfSize:11.0];
    [self.scrollView addSubview:appVersionLabel];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, appVersionLabel.frame.origin.y + appVersionLabel.frame.size.height + 20.0);
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        return 6;
    } else if (tableView.tag == 2) {
        return 2;
    } else {
        return [self.rentedProductions count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        NSString *const personalInfoCellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:personalInfoCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:personalInfoCellIdentifier];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = self.personalInfoTableViewTitles[indexPath.row];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        
        UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(150.0, cell.contentView.frame.size.height/2 - 15.0, 160.0, 30.0)];
        secondaryLabel.text = self.personalInfoTableViewSecondaryInfo[indexPath.row];
        secondaryLabel.textAlignment = NSTextAlignmentRight;
        secondaryLabel.textColor = [UIColor darkGrayColor];
        secondaryLabel.font = [UIFont systemFontOfSize:14.0];
        [cell.contentView addSubview:secondaryLabel];
        
        return cell;
        
    } else if (tableView.tag == 2) {
        NSString *const suscriptionInfoCellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:suscriptionInfoCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:suscriptionInfoCellIdentifier];
        }
        cell.textLabel.text = self.suscriptionInfoTableViewTitles[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(150.0, cell.contentView.frame.size.height/2 - 15.0, 160.0, 30.0)];
        secondaryLabel.text = self.suscriptionInfoTableViewSecondaryInfo[indexPath.row];
        secondaryLabel.textColor = [UIColor darkGrayColor];
        secondaryLabel.font = [UIFont systemFontOfSize:14.0];
        secondaryLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:secondaryLabel];
        
        return cell;
        
    } else {
        NSString *const suscriptionInfoCellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:suscriptionInfoCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:suscriptionInfoCellIdentifier];
            /*UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
            selectedView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
            cell.selectedBackgroundView = selectedView;*/
        }
        
        NSDictionary *rentedProductionInfo = self.rentedProductions[indexPath.row][0][0];
        cell.textLabel.text = rentedProductionInfo[@"name"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.backgroundColor = [UIColor clearColor];

        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 3) {
        NSDictionary *rentedProductionInfo = self.rentedProductions[indexPath.row][0][0];
        NSString *productID = rentedProductionInfo[@"id"];
        
        if ([rentedProductionInfo[@"type"] isEqualToString:@"Series"] || [rentedProductionInfo[@"type"] isEqualToString:@"Telenovelas"] || [rentedProductionInfo[@"type"] isEqualToString:@"Noticias"]) {
            //The production is a serie
            TelenovelSeriesDetailViewController *telenovelSeriesDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TelenovelSeries"];
            telenovelSeriesDetailVC.serieID = productID;
            [self.navigationController pushViewController:telenovelSeriesDetailVC animated:YES];
            
        } else if ([rentedProductionInfo[@"type"] isEqualToString:@"Películas"] || [rentedProductionInfo[@"type"] isEqualToString:@"Documentales"] || [rentedProductionInfo[@"type"] isEqualToString:@"Eventos en vivo"]) {
            //The production is a movie, news or live event
            MoviesEventsDetailsViewController *movieEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieEventDetails"];
            movieEventDetailsVC.productionID = productID;
            [self.navigationController pushViewController:movieEventDetailsVC animated:YES];
        }
    }
}

#pragma mark - Actions

-(void)goToConditionsTerms {
    TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
    termsAndConditionsVC.showTerms = YES;
    termsAndConditionsVC.mainTitle = @"Términos y Condiciones";
    [self.navigationController pushViewController:termsAndConditionsVC animated:YES];
}

-(void)goToPrivacyTerms {
    TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
    termsAndConditionsVC.showPrivacy = YES;
    termsAndConditionsVC.mainTitle = @"Políticas de Privacidad";
    [self.navigationController pushViewController:termsAndConditionsVC animated:YES];
}

-(void)closeSession {
    NSLog(@"Cerré Sesión");
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Salida Exitosa";
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:1.0];
    
    //Post a notification to erase the 'Ultimos vistos' tab in 'Categorias'
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EraseLastSeenCategory"
                                                        object:nil
                                                      userInfo:nil];
    
    //Change our local key that indicates that the user has closed session
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserHasLoginKey": @NO,
                               @"UserName" : @"",
                               @"Password" : @"",
                               @"UserID" : @"",
                               @"IsSuscription" : @NO
                               } withKey:@"UserHasLoginDic"];
    
    //Erase user data from our user info singleton
    [UserInfo sharedInstance].userName = @"";
    [UserInfo sharedInstance].password = @"";
    [UserInfo sharedInstance].session = @"";
    [UserInfo sharedInstance].userID = @"";
    [UserInfo sharedInstance].isSubscription = NO;
    
    //Erase 'Mis listas' tab & 'Mas' tab
    if (self.tabBarController) {
        NSLog(@"SI EXISTE EL TAB BAR");
    } else {
        NSLog(@"NO EXISTE EL TAB BAR");
    }
    
    NSMutableArray *tabViewControllers = [self.tabBarController.viewControllers mutableCopy];
    NSLog(@"NUMERO DE CONTROLADORES EN EL TAB: %lu", (unsigned long)[self.tabBarController.viewControllers count]);
    [tabViewControllers removeLastObject];
    //[tabViewControllers removeLastObject];
    self.tabBarController.viewControllers = tabViewControllers;
    NSLog(@"NUMERO DE CONTROLADORES DESPUES DE BORRAR: %lu", (unsigned long)[self.tabBarController.viewControllers count]);
    self.tabBarController.selectedIndex = 0;
    
    MyNavigationController *navigationController = (MyNavigationController *)self.tabBarController.viewControllers[0];
    //HomeViewController *homeViewController = navigationController.viewControllers[0];
    [navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Server Stuff

-(void)getUser {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Conectando...";
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([methodName isEqualToString:@"GetUser"] && [dictionary[@"status"] boolValue]) {
        //NSLog(@"Peticio GetUser exitosa: %@", dictionary);
        NSDictionary *dicWithoutNulls = [dictionary dictionaryByReplacingNullWithBlanks];
        self.suscriptionDic = dicWithoutNulls[@"user"][@"suscription"];
        self.personalInfo = dicWithoutNulls[@"user"][@"data"];
        self.rentedProductions = dicWithoutNulls[@"user"][@"rented"];
        
    } else {
        //NSLog(@"Dic %@ ",dictionary);
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error conectándose con el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
