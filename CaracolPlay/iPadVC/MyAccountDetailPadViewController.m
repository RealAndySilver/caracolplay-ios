//
//  MyAccountDetailViewController.m
//  CaracolPlay
//
//  Created by Developer on 20/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyAccountDetailPadViewController.h"
#import "TermsAndConditionsPadViewController.h"
#import "FileSaver.h"
#import "ServerCommunicator.h"
#import "NSDictionary+NullReplacement.h"
#import "UserInfo.h"
#import "SeriesDetailPadViewController.h"
#import "MovieDetailsPadViewController.h"
#import "UIColor+AppColors.h"

@interface MyAccountDetailPadViewController () <UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *suscriptionInfoTableViewTitles;
@property (strong, nonatomic) NSMutableArray *suscriptionInfoTableViewSecondaryInfo;
@property (strong, nonatomic) NSArray *personalInfoTableViewTitles;
@property (strong, nonatomic) NSMutableArray *personalInfoTableViewSecondaryInfo;
@property (strong, nonatomic) NSDictionary *personalInfo;
@property (strong, nonatomic) NSDictionary *suscriptionDic;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSArray *rentedProductions;
@property (strong, nonatomic) UIImageView *opacityView;
@property (strong, nonatomic) UITableView *personalInfoTableView;
@property (strong, nonatomic) UITableView *rentedTableView;
@property (strong, nonatomic) UITextView *informativeTextLabel;
@property (strong, nonatomic) UITableView *suscriptionInfoTableView;
@property (strong, nonatomic) UILabel *suscriptionLabel;
@end

@implementation MyAccountDetailPadViewController

#pragma mark - Lazy Instantiations

-(UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.frame = CGRectMake(350 - 20.0, 384.0 - 20.0, 40.0, 40.0);
    }
    return _spinner;
}

-(NSArray *)suscriptionInfoTableViewTitles {
    if (!_suscriptionInfoTableViewTitles) {
        _suscriptionInfoTableViewTitles = @[@"Tipo de Suscripción", @"Fecha de Vencimiento"];
    }
    return _suscriptionInfoTableViewTitles;
}

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
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeOpacityView)
                                                 name:@"RemoveOpacityView"
                                               object:nil];
    [self.view addSubview:self.spinner];
    [self getUser];
    //[self UISetup];
}

-(void)UISetup {
    // Navigation bar setup
    CGRect screenFrame = CGRectMake(0.0, 0.0, 703, 768.0);
    
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.delegate = self;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarDetail.png"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.navigationBar];
    
    //1. Scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(80.0, 64.0, screenFrame.size.width - 160.0, screenFrame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height) - 44.0)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    //2. label 'Datos Personales'
    UILabel *personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 150.0, 30.0)];
    personalInfoLabel.text = @"DATOS PERSONALES:";
    personalInfoLabel.font = [UIFont systemFontOfSize:13.0];
    personalInfoLabel.textColor = [UIColor blackColor];
    [self.scrollView addSubview:personalInfoLabel];
    
    //3. Personal info table view
    self.personalInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 40.0, self.view.frame.size.width, 262.0) style:UITableViewStylePlain];
    self.personalInfoTableView.delegate = self;
    self.personalInfoTableView.dataSource  = self;
    self.personalInfoTableView.userInteractionEnabled = NO;
    self.personalInfoTableView.tag = 1;
    self.personalInfoTableView.showsVerticalScrollIndicator = NO;
    self.personalInfoTableView.backgroundColor = [UIColor whiteColor];
    //personalInfoTableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.personalInfoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:self.personalInfoTableView];
    
    //4. Some informative text label
    NSMutableAttributedString *informativeString = [[NSMutableAttributedString alloc] initWithString:@"Tus datos no son editables en la versión móvil del sitio. Conéctate a www.caracolplay.com desde tu computador para poder modificar tus datos personales."];
    NSDictionary *firstAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    NSDictionary *secondAttributes = @{NSForegroundColorAttributeName: [UIColor caracolMediumBlueColor]};
    [informativeString setAttributes:secondAttributes range:NSMakeRange(69, 19)];
    [informativeString setAttributes:firstAttributes range:NSMakeRange(89, 61)];
    [informativeString setAttributes:firstAttributes range:NSMakeRange(0, 68)];
    
    self.informativeTextLabel = [[UITextView alloc] initWithFrame:CGRectMake(2.0, self.personalInfoTableView.frame.origin.y + self.personalInfoTableView.frame.size.height, self.scrollView.frame.size.width - 4.0, 40.0)];
    self.informativeTextLabel.attributedText = informativeString;
    self.informativeTextLabel.backgroundColor = [UIColor clearColor];
    self.informativeTextLabel.textAlignment = NSTextAlignmentJustified;
    self.informativeTextLabel.userInteractionEnabled = NO;
    self.informativeTextLabel.font = [UIFont systemFontOfSize:12.0];
    [self.scrollView addSubview:self.informativeTextLabel];
    
    //'Mis Alquilados'
    UILabel *rentedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.informativeTextLabel.frame.origin.y + self.informativeTextLabel.frame.size.height + 20.0, 200.0, 30.0)];
    rentedLabel.text = @"MIS ALQUILADOS";
    rentedLabel.font = [UIFont systemFontOfSize:13.0];
    rentedLabel.textColor = [UIColor blackColor];
    [self.scrollView addSubview:rentedLabel];
    
    //4. 'Mis alquilados' table view
    self.rentedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, self.informativeTextLabel.frame.origin.y + self.informativeTextLabel.frame.size.height + 50.0, self.view.frame.size.width, 160.0) style:UITableViewStylePlain];
    self.rentedTableView.delegate = self;
    self.rentedTableView.dataSource = self;
    self.rentedTableView.tag = 3;
    self.rentedTableView.backgroundColor = [UIColor whiteColor];
    //rentedTableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.rentedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:self.rentedTableView];

    
    //5. Suscription label
    self.suscriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.rentedTableView.frame.origin.y + self.rentedTableView.frame.size.height + 10.0, 100.0, 30.0)];
    self.suscriptionLabel.text = @"SUSCRIPCIÓN:";
    self.suscriptionLabel.textColor = [UIColor blackColor];
    self.suscriptionLabel.font = [UIFont systemFontOfSize:13.0];
    [self.scrollView addSubview:self.suscriptionLabel];
    
    //6. SuscriptionInfo table view
    self.suscriptionInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, self.suscriptionLabel.frame.origin.y + self.suscriptionLabel.frame.size.height, self.view.frame.size.width, 86.0) style:UITableViewStylePlain];
    self.suscriptionInfoTableView.delegate = self;
    self.suscriptionInfoTableView.dataSource = self;
    self.suscriptionInfoTableView.tag = 2;
    self.suscriptionInfoTableView.showsVerticalScrollIndicator = NO;
    self.suscriptionInfoTableView.userInteractionEnabled = NO;
    //suscriptionInfoTableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.suscriptionInfoTableView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.suscriptionInfoTableView];
    
    //7. 'Cerrar Sesión' button
    UIButton *closeSessionButton = [[UIButton alloc] initWithFrame:CGRectMake(80.0, self.suscriptionInfoTableView.frame.origin.y + self.suscriptionInfoTableView.frame.size.height + 30.0, self.scrollView.frame.size.width - 160.0, 40.0)];
    [closeSessionButton setTitle:@"Cerrar Sesión" forState:UIControlStateNormal];
    closeSessionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [closeSessionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeSessionButton.backgroundColor = [UIColor caracolMediumBlueColor];
    //[closeSessionButton setBackgroundImage:[UIImage imageNamed:@"BotonCerrarSesion"] forState:UIControlStateNormal];
    [closeSessionButton addTarget:self action:@selector(closeSession) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:closeSessionButton];
    
    //8. 'Terminos y condiciones' button
    UIButton *termsAndConditionsButton = [[UIButton alloc] initWithFrame:CGRectMake(50.0, closeSessionButton.frame.origin.y + closeSessionButton.frame.size.height + 20.0, self.scrollView.frame.size.width - 100.0, 30.0)];
    [termsAndConditionsButton setTitle:@"Términos y Condiciones" forState:UIControlStateNormal];
    [termsAndConditionsButton setTitleColor:[UIColor caracolMediumBlueColor] forState:UIControlStateNormal];
    [termsAndConditionsButton addTarget:self action:@selector(goToConditionsTerms) forControlEvents:UIControlEventTouchUpInside];
    termsAndConditionsButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.scrollView addSubview:termsAndConditionsButton];
    
    //9. 'Politicas del servicio' button
    UIButton *serviceTermsButton = [[UIButton alloc] initWithFrame:CGRectMake(50.0, termsAndConditionsButton.frame.origin.y + termsAndConditionsButton.frame.size.height + 10.0, self.scrollView.frame.size.width - 100.0, 30.0)];
    [serviceTermsButton setTitle:@"Políticas de privacidad" forState:UIControlStateNormal];
    [serviceTermsButton setTitleColor:[UIColor caracolMediumBlueColor] forState:UIControlStateNormal];
    [serviceTermsButton addTarget:self action:@selector(goToPrivacyTerms) forControlEvents:UIControlEventTouchUpInside];
    serviceTermsButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.scrollView addSubview:serviceTermsButton];
    
    
    //10. App version label
    UILabel *appVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, serviceTermsButton.frame.origin.y + serviceTermsButton.frame.size.height + 10.0, self.scrollView.frame.size.width - 100.0, 30.0)];
    appVersionLabel.textAlignment = NSTextAlignmentCenter;
    appVersionLabel.text = @"Caracol Play Versión 1.5";
    appVersionLabel.textColor = [UIColor lightGrayColor];
    appVersionLabel.font = [UIFont boldSystemFontOfSize:11.0];
    [self.scrollView addSubview:appVersionLabel];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, appVersionLabel.frame.origin.y + appVersionLabel.frame.size.height + 80.0);
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"bounds: %@", NSStringFromCGRect(self.view.bounds));
    //Set subviews frame
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.personalInfoTableView.frame = CGRectMake(0.0, 40.0, self.view.frame.size.width, 262.0);
    self.rentedTableView.frame = CGRectMake(0.0, self.informativeTextLabel.frame.origin.y + self.informativeTextLabel.frame.size.height + 50.0, self.view.frame.size.width, 160.0);
    self.suscriptionInfoTableView.frame = CGRectMake(0.0, self.suscriptionLabel.frame.origin.y + self.suscriptionLabel.frame.size.height, self.view.frame.size.width, 86.0);
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
        
        UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(300.0, cell.contentView.frame.size.height/2 - 15.0, 220.0, 30.0)];
        secondaryLabel.text = self.personalInfoTableViewSecondaryInfo[indexPath.row];
        secondaryLabel.textAlignment = NSTextAlignmentRight;
        secondaryLabel.textColor = [UIColor lightGrayColor];
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
        
        UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(330.0, cell.contentView.frame.size.height/2 - 15.0, 160.0, 30.0)];
        secondaryLabel.text = self.suscriptionInfoTableViewSecondaryInfo[indexPath.row];
        secondaryLabel.textColor = [UIColor lightGrayColor];
        secondaryLabel.font = [UIFont systemFontOfSize:14.0];
        secondaryLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:secondaryLabel];
        
        return cell;
        
    }  else {
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
            [self showOpacityView];
            
            //The production is a serie
            SeriesDetailPadViewController *telenovelSeriesDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SeriesDetailPad"];
            telenovelSeriesDetailVC.productID = productID;
            telenovelSeriesDetailVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:telenovelSeriesDetailVC animated:YES completion:nil];
            
        } else if ([rentedProductionInfo[@"type"] isEqualToString:@"Películas"] || [rentedProductionInfo[@"type"] isEqualToString:@"Documentales"] || [rentedProductionInfo[@"type"] isEqualToString:@"Eventos en vivo"]) {
            [self showOpacityView];
            
            //The production is a movie, news or live event
            MovieDetailsPadViewController *movieEventDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetails"];
            movieEventDetailsVC.productID = productID;
            movieEventDetailsVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:movieEventDetailsVC animated:YES completion:nil];
        }
    }
}

#pragma mark - Actions 

-(void)removeOpacityView {
    [self.opacityView removeFromSuperview];
}

-(void)showOpacityView {
    self.opacityView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 768.0)];
    //self.opacityView.image = [UIImage imageNamed:@"OpacityBackground.png"];
    self.opacityView.backgroundColor = [UIColor whiteColor];
    self.opacityView.alpha = 0.3;
    [self.tabBarController.view addSubview:self.opacityView];
}

-(void)goToPrivacyTerms {
    TermsAndConditionsPadViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsPad"];
    termsAndConditionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    termsAndConditionsVC.showPrivacy = YES;
    termsAndConditionsVC.controllerWasPresentedInFormSheet = YES;
    [self presentViewController:termsAndConditionsVC animated:YES completion:nil];
}

-(void)goToConditionsTerms {
    TermsAndConditionsPadViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsPad"];
    termsAndConditionsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    termsAndConditionsVC.controllerWasPresentedInFormSheet = YES;
    termsAndConditionsVC.showTerms = YES;
    [self presentViewController:termsAndConditionsVC animated:YES completion:nil];
}

-(void)closeSession {
    NSLog(@"Cerré Sesión");
    
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
    [UserInfo sharedInstance].sessionKey = @"";
    [UserInfo sharedInstance].session_expires = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EraseLastSeenCategory"
                                                        object:nil
                                                      userInfo:nil];
    
    //Erase 'Mis listas' tab & 'Mas' tab
    NSMutableArray *tabViewControllers = [self.tabBarController.viewControllers mutableCopy];
    [tabViewControllers removeLastObject];
    self.tabBarController.viewControllers = tabViewControllers;
    self.tabBarController.selectedIndex = 0;
    
    UINavigationController *navigationController = self.tabBarController.viewControllers[0];
    //HomeViewController *homeViewController = navigationController.viewControllers[0];
    [navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Server Stuff

-(void)getUser {
    [self.spinner startAnimating];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithGETMethod:@"GetUser" andParameter:@""];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [self.spinner stopAnimating];
    if ([methodName isEqualToString:@"GetUser"] && [dictionary[@"status"] boolValue]) {
        //NSLog(@"Peticio GetUser exitosa: %@", dictionary);
        NSDictionary *dicWithoutNulls = [dictionary dictionaryByReplacingNullWithBlanks];
        self.suscriptionDic = dicWithoutNulls[@"user"][@"suscription"];
        self.personalInfo = dicWithoutNulls[@"user"][@"data"];
        self.rentedProductions = dicWithoutNulls[@"user"][@"rented"];

    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error accediendo a tu información personal. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)serverError:(NSError *)error {
    [self.spinner stopAnimating];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error en el servidor. Por favor intenta de nuevo en unos momentos." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
