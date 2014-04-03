//
//  MyAccountDetailViewController.m
//  CaracolPlay
//
//  Created by Developer on 20/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MyAccountDetailPadViewController.h"
#import "FileSaver.h"

@interface MyAccountDetailPadViewController () <UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *suscriptionInfoTableViewTitles;
@property (strong, nonatomic) NSArray *suscriptionInfoTableViewSecondaryInfo;
@property (strong, nonatomic) NSArray *personalInfoTableViewTitles;
@property (strong, nonatomic) NSArray *personalInfoTableViewSecondaryInfo;
@end

@implementation MyAccountDetailPadViewController

#pragma mark - Lazy Instantiations

-(NSArray *)suscriptionInfoTableViewTitles {
    if (!_suscriptionInfoTableViewTitles) {
        _suscriptionInfoTableViewTitles = @[@"Tipo de Suscripción", @"Fecha de Vencimiento"];
    }
    return _suscriptionInfoTableViewTitles;
}

-(NSArray *)suscriptionInfoTableViewSecondaryInfo {
    if (!_suscriptionInfoTableViewSecondaryInfo) {
        _suscriptionInfoTableViewSecondaryInfo = @[@"Normal", @"15/10/2015"];
    }
    return _suscriptionInfoTableViewSecondaryInfo;
}

-(NSArray *)personalInfoTableViewTitles {
    if (!_personalInfoTableViewTitles) {
        _personalInfoTableViewTitles = @[@"Nombres", @"Apellidos", @"Fecha de Nacimiento", @"Género", @"Alias", @"Mail"];
    }
    return _personalInfoTableViewTitles;
}

-(NSArray *)personalInfoTableViewSecondaryInfo {
    if (!_personalInfoTableViewSecondaryInfo) {
        _personalInfoTableViewSecondaryInfo = @[@"Diego Fernando", @"Vidal Illera", @"10/01/1991", @"Masculino", @"Dieluma", @"diefer_91@hotmail.com"];
    }
    return _personalInfoTableViewSecondaryInfo;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self UISetup];
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
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    
    //2. label 'Datos Personales'
    UILabel *personalInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 150.0, 30.0)];
    personalInfoLabel.text = @"DATOS PERSONALES:";
    personalInfoLabel.font = [UIFont systemFontOfSize:13.0];
    personalInfoLabel.textColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:personalInfoLabel];
    
    //3. Personal info table view
    UITableView *personalInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 40.0, self.view.frame.size.width, 264.0)
                                                                      style:UITableViewStylePlain];
    personalInfoTableView.delegate = self;
    personalInfoTableView.dataSource  = self;
    personalInfoTableView.userInteractionEnabled = NO;
    personalInfoTableView.tag = 1;
    personalInfoTableView.showsVerticalScrollIndicator = NO;
    personalInfoTableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    personalInfoTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    personalInfoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:personalInfoTableView];
    
    //4. Some informative text label
    NSMutableAttributedString *informativeString = [[NSMutableAttributedString alloc] initWithString:@"Tus datos no son editable en la versión móvil del sitio. Conéctate a www.caracolplay.com desde tu computador para poder modificar tus datos personales."];
    NSDictionary *firstAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSDictionary *secondAttributes = @{NSForegroundColorAttributeName: [UIColor orangeColor]};
    [informativeString setAttributes:secondAttributes range:NSMakeRange(69, 20)];
    [informativeString setAttributes:firstAttributes range:NSMakeRange(90, 61)];
    [informativeString setAttributes:firstAttributes range:NSMakeRange(0, 68)];
    
    UITextView *informativeTextLabel = [[UITextView alloc] initWithFrame:CGRectMake(0.0, personalInfoTableView.frame.origin.y + personalInfoTableView.frame.size.height, self.scrollView.frame.size.width, 40.0)];
    informativeTextLabel.attributedText = informativeString;
    informativeTextLabel.backgroundColor = [UIColor blackColor];
    informativeTextLabel.textAlignment = NSTextAlignmentJustified;
    informativeTextLabel.userInteractionEnabled = NO;
    informativeTextLabel.font = [UIFont systemFontOfSize:12.0];
    [self.scrollView addSubview:informativeTextLabel];
    
    //5. Suscription label
    UILabel *suscriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, informativeTextLabel.frame.origin.y + informativeTextLabel.frame.size.height + 10.0, 100.0, 30.0)];
    suscriptionLabel.text = @"SUSCRIPCIÓN:";
    suscriptionLabel.textColor = [UIColor lightGrayColor];
    suscriptionLabel.font = [UIFont systemFontOfSize:13.0];
    [self.scrollView addSubview:suscriptionLabel];
    
    //6. SuscriptionInfo table view
    UITableView *suscriptionInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, suscriptionLabel.frame.origin.y + suscriptionLabel.frame.size.height, self.view.frame.size.width, 88.0) style:UITableViewStylePlain];
    suscriptionInfoTableView.delegate = self;
    suscriptionInfoTableView.dataSource = self;
    suscriptionInfoTableView.tag = 2;
    suscriptionInfoTableView.showsVerticalScrollIndicator = NO;
    suscriptionInfoTableView.userInteractionEnabled = NO;
    suscriptionInfoTableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    suscriptionInfoTableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.scrollView addSubview:suscriptionInfoTableView];
    
    //7. 'Cerrar Sesión' button
    UIButton *closeSessionButton = [[UIButton alloc] initWithFrame:CGRectMake(80.0, suscriptionInfoTableView.frame.origin.y + suscriptionInfoTableView.frame.size.height + 30.0, self.scrollView.frame.size.width - 160.0, 40.0)];
    [closeSessionButton setTitle:@"Cerrar Sesión" forState:UIControlStateNormal];
    closeSessionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [closeSessionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeSessionButton setBackgroundImage:[UIImage imageNamed:@"BotonCerrarSesion"] forState:UIControlStateNormal];
    [closeSessionButton addTarget:self action:@selector(closeSession) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:closeSessionButton];
    
    //8. 'Terminos y condiciones' button
    UIButton *termsAndConditionsButton = [[UIButton alloc] initWithFrame:CGRectMake(50.0, closeSessionButton.frame.origin.y + closeSessionButton.frame.size.height + 20.0, self.scrollView.frame.size.width - 100.0, 30.0)];
    [termsAndConditionsButton setTitle:@"Términos y Condiciones" forState:UIControlStateNormal];
    [termsAndConditionsButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    termsAndConditionsButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [self.scrollView addSubview:termsAndConditionsButton];
    
    //9. 'Politicas del servicio' button
    UIButton *serviceTermsButton = [[UIButton alloc] initWithFrame:CGRectMake(50.0, termsAndConditionsButton.frame.origin.y + termsAndConditionsButton.frame.size.height + 10.0, self.scrollView.frame.size.width - 100.0, 30.0)];
    [serviceTermsButton setTitle:@"Politicas del Servicio" forState:UIControlStateNormal];
    [serviceTermsButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
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

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        return 6;
    } else {
        return 2;
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
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        
        UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(330.0, cell.contentView.frame.size.height/2 - 15.0, 160.0, 30.0)];
        secondaryLabel.text = self.personalInfoTableViewSecondaryInfo[indexPath.row];
        secondaryLabel.textAlignment = NSTextAlignmentRight;
        secondaryLabel.textColor = [UIColor lightGrayColor];
        secondaryLabel.font = [UIFont systemFontOfSize:14.0];
        [cell.contentView addSubview:secondaryLabel];
        
        return cell;
        
    } else {
        NSString *const suscriptionInfoCellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:suscriptionInfoCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:suscriptionInfoCellIdentifier];
        }
        cell.textLabel.text = self.suscriptionInfoTableViewTitles[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *secondaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(330.0, cell.contentView.frame.size.height/2 - 15.0, 160.0, 30.0)];
        secondaryLabel.text = self.suscriptionInfoTableViewSecondaryInfo[indexPath.row];
        secondaryLabel.textColor = [UIColor lightGrayColor];
        secondaryLabel.font = [UIFont systemFontOfSize:14.0];
        secondaryLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:secondaryLabel];
        
        return cell;
    }
}

#pragma mark - Actions 

-(void)closeSession {
    NSLog(@"Cerré Sesión");
    
    //Change our local key that indicates that the user has closed session
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserHasLoginKey": @NO} withKey:@"UserHasLoginDic"];
    //[MBHUDView hudWithBody:@"Salida exitosa" type:MBAlertViewHUDTypeCheckmark hidesAfter:2.0 show:YES];
    
    //Erase 'Mis listas' tab & 'Mas' tab
    NSMutableArray *tabViewControllers = [self.tabBarController.viewControllers mutableCopy];
    [tabViewControllers removeLastObject];
    [tabViewControllers removeLastObject];
    self.tabBarController.viewControllers = tabViewControllers;
    self.tabBarController.selectedIndex = 0;
    
    UINavigationController *navigationController = self.tabBarController.viewControllers[0];
    //HomeViewController *homeViewController = navigationController.viewControllers[0];
    [navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
