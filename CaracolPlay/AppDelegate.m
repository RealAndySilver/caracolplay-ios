//
//  AppDelegate.m
//  CaracolPlay
//
//  Created by Andres Abril on 20/01/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "AppDelegate.h"
#import "CPIAPHelper.h"
#import "UserInfo.h"
#import "UserDefaultsSaver.h"
#import "MBProgressHUD.h"
#import "ServerCommunicator.h"
#import "UIColor+AppColors.h"

@interface AppDelegate() <UIAlertViewDelegate, ServerCommunicatorDelegate>
@property (assign, nonatomic) NSUInteger currentPurchaseType; //0 - subscription  1 - rent
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CPIAPHelper sharedInstance];
    [UserInfo sharedInstance];
    // Override point for customization after application launch.
    [UITabBar appearance].barTintColor = [UIColor caracolMediumBlueColor];
    //[UITabBar appearance].translucent = NO;
    [UITabBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = [UIColor blackColor];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} forState:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{
                                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                 }];
    //[UIView appearance].tintColor = [UIColor whiteColor];
    self.currentPurchaseType = -1;
    [self performSelector:@selector(checkIfThereArePurchasesPending) withObject:nil afterDelay:3.0];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)windo
{
    NSUInteger orientations = UIInterfaceOrientationMaskAllButUpsideDown;
    if (self.window.rootViewController) {
        UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
        orientations = [presentedViewController supportedInterfaceOrientations];
    }
    return orientations;
}*/

-(void)checkIfThereArePurchasesPending {
    NSLog(@"Entre al purchases pending");
    
    if ([UserDefaultsSaver pendingPurchaseDicExists]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Hay una compra pendiente. Se intentará completar la compra." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alert.tag = 10;
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        
        //Check if the purchase is a subscription or a rent
        NSString *purchaseType = [UserDefaultsSaver getPurchaseDic][@"purchaseType"];
        if ([purchaseType isEqualToString:@"subscription"]) {
            self.currentPurchaseType = 0;
            [self completeSubscriptionInServer];
            
        } else if ([purchaseType isEqualToString:@"rent"]) {
            self.currentPurchaseType = 1;
            [self completeRentInServer];
        }
    
    } else if (alertView.tag == 1) {
        [self completeSubscriptionInServer];
    
    } else if (alertView.tag == 2) {
        [self completeRentInServer];
    }
}

-(void)completeSubscriptionInServer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.labelText = @"Comprando...";
    
    NSString *transactionId = [UserDefaultsSaver getPurchaseDic][@"transactionId"];
    NSString *userInfo = [UserDefaultsSaver getPurchaseDic][@"userInfo"];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameter = [NSString stringWithFormat:@"user_info=%@", userInfo];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", transactionId] andParameter:parameter httpMethod:@"POST"];
}

-(void)completeRentInServer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.labelText = @"Comprando...";
    
    NSString *transactionId = [UserDefaultsSaver getPurchaseDic][@"transactionId"];
    NSString *userInfo = [UserDefaultsSaver getPurchaseDic][@"userInfo"];
    NSString *productId = [UserDefaultsSaver getPurchaseDic][@"productId"];
    
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    NSString *parameters = [NSString stringWithFormat:@"user_info=%@", userInfo];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", transactionId, productId] andParameter:parameters httpMethod:@"POST"];
}

#pragma mark - ServerCommunicatorDelegate

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
    NSString *transactionId = [UserDefaultsSaver getPurchaseDic][@"transactionId"];
    NSString *productId = [UserDefaultsSaver getPurchaseDic][@"productId"];
    
    if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@", @"SubscribeUser", transactionId]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                [UserDefaultsSaver deletePurchaseDics];
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Tu suscripción se ha completado correctamente. Ya puedes ingresar con tu usuario y comenzar a disfrutar de CaracolPlay" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
            } else {
                NSLog(@"error en la compra: %@", dictionary);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
            }
            
        } else {
            NSLog(@"error en la compra: %@", dictionary);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
            alert.tag = 1;
            [alert show];
        }
    
    } else if ([methodName isEqualToString:[NSString stringWithFormat:@"%@/%@/%@", @"RentContent", transactionId, productId]]) {
        if (dictionary) {
            if ([dictionary[@"status"] boolValue]) {
                [UserDefaultsSaver deletePurchaseDics];
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Tu alquiler se ha completado correctamente. Ya puedes ingresar con tu usuario y comenzar a disfrutar de CaracolPlay" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
            } else {
                NSLog(@"error en la compra: %@", dictionary);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
                alert.tag = 2;
                [alert show];
            }
            
        } else {
            NSLog(@"error en la compra: %@", dictionary);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
            alert.tag = 2;
            [alert show];
        }
    }
}

-(void)serverError:(NSError *)error {
    if (self.currentPurchaseType == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
        
    } else if (self.currentPurchaseType == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ocurrió un error al crear el usuario en CaracolPlay. Por favor revisa que estés conectado a internet e intenta de nuevo hasta que se complete la compra. No cierres la app" delegate:self cancelButtonTitle:@"Reintentar" otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
    }
}

@end
