//
//  MyAccountViewController.m
//  CaracolPlay
//
//  Created by Developer on 23/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "TermsAndConditionsViewController.h"
#import "MyAccountViewController.h"
#import <MessageUI/MessageUI.h>

NSString *const cellIdentifier = @"CellIdentifier";

@interface ConfigurationViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *menuItemsArray;
@end

@implementation ConfigurationViewController

-(void)UISetup {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height))];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Más";
    self.menuItemsArray = @[@"Mi Cuenta", @"Reporte de errores", @"Políticas de privacidad", @"Términos y condiciones"];
    [self UISetup];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"CaracolPlayHeader.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuItemsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.textLabel.text = self.menuItemsArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        MyAccountViewController *myAccountViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAccount"];
        [self.navigationController pushViewController:myAccountViewController animated:YES];
    } else if (indexPath.row == 1) {
        //Show Mail VC
        [self showMailVC];
    }
    
    else if ((indexPath.row == 2) || (indexPath.row == 3)) {
        TermsAndConditionsViewController *termsAndConditionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsAndConditions"];
        [self.navigationController pushViewController:termsAndConditionsVC animated:YES];
    }
}

#pragma mark - Actions 

-(void)showMailVC {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
        [mailComposeVC setToRecipients:[NSArray arrayWithObject:@"diefer_91@hotmail.com"]];
        [mailComposeVC setSubject:@"Reporte de errores CaracolPlay"];
        mailComposeVC.mailComposeDelegate = self;
        [self presentViewController:mailComposeVC animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Tu dispositivo no esta configurado para enviar correo electrónico" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - MFMailComposeDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Interface Orientation

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
