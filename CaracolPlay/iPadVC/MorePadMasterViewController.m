//
//  MoreViewController.m
//  CaracolPlay
//
//  Created by Developer on 17/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "MorePadMasterViewController.h"
#import "TermsAndConditionsPadViewController.h"
#import "MyAccountDetailPadViewController.h"
#import <MessageUI/MessageUI.h>
#import "UIColor+AppColors.h"

@interface MorePadMasterViewController () <UIBarPositioningDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) NSArray *menuOptionsArray;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation MorePadMasterViewController

#pragma mark - Lazy Instantiation

-(NSArray *)menuOptionsArray {
    if (!_menuOptionsArray) {
        _menuOptionsArray = @[@"Mi Cuenta", @"Reporte de errores", @"Términos y condiciones", @"Políticas de privacidad"];
    }
    return _menuOptionsArray;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [self UISetup];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // Set subviews frame
    self.navigationBar.frame = CGRectMake(0.0, 20.0, self.view.bounds.size.width, 44.0);
    self.headerImageView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, 75.0);
    self.tableView.frame = CGRectMake(0.0, self.headerImageView.frame.origin.y + self.headerImageView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.headerImageView.frame.origin.y + self.headerImageView.frame.size.height));
}

#pragma mark - UISetup & Initialization stuff

-(void)UISetup {
    // 1. Create a navigation bar
    self.navigationBar = [[UINavigationBar alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"SplitNavBarMaster.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.delegate = self;
    [self.view addSubview:self.navigationBar];
    
    //Header image
    self.headerImageView = [[UIImageView alloc] init];
    self.headerImageView.image = [UIImage imageNamed:@"MoreSectionHeader.png"];
    [self.view addSubview:self.headerImageView];
    
    // 2. Table view setup
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor caracolLightGrayColor];
    //self.tableView.separatorColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuOptionsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        /*UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height)];
        selectedView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
        cell.selectedBackgroundView = selectedView;*/

    }
    cell.textLabel.text = self.menuOptionsArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        //Mi cuenta
        MyAccountDetailPadViewController *myAccountDetailPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAccountDetailPad"];
        NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:self.splitViewController.viewControllers];
        [viewControllersArray replaceObjectAtIndex:1 withObject:myAccountDetailPadVC];
        self.splitViewController.viewControllers = viewControllersArray;
        
    } else if (indexPath.row == 1) {
        //Reportar un problema
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            [mailComposeViewController setToRecipients:@[@"soporte@caracolplay.com"]];
            [mailComposeViewController setSubject:@"Reporte de errores CaracolPlay"];
            mailComposeViewController.mailComposeDelegate = self;
            mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Tu dispositivo no está configurado para enviar corre electrónico." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
    }   else if (indexPath.row == 2) {
        TermsAndConditionsPadViewController *termsConditionsPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsPad"];
        termsConditionsPadVC.showTerms = YES;
        NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:self.splitViewController.viewControllers];
        [viewControllersArray replaceObjectAtIndex:1 withObject:termsConditionsPadVC];
        self.splitViewController.viewControllers = viewControllersArray;
    
    } else if (indexPath.row == 3) {
        TermsAndConditionsPadViewController *termsConditionsPadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditionsPad"];
        termsConditionsPadVC.showPrivacy = YES;
        NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:self.splitViewController.viewControllers];
        [viewControllersArray replaceObjectAtIndex:1 withObject:termsConditionsPadVC];
        self.splitViewController.viewControllers = viewControllersArray;
    }
}

#pragma mark - MFMailComposeViewController 

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIBarPositioningDelegate 

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


@end
