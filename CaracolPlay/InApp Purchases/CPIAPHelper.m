//
//  CPIAPHelper.m
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CPIAPHelper.h"
#import "IAPProduct.h"

@interface CPIAPHelper() <UIAlertViewDelegate>

@end

@implementation CPIAPHelper

-(instancetype)init {
    IAPProduct *suscriptionProduct = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.CaracolPlay.testsuscription"];
    IAPProduct *rentedProduct = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.CaracolPlay.testrentedproduction"];
    NSMutableDictionary *products = [@{suscriptionProduct.productIdentifier : suscriptionProduct, rentedProduct.productIdentifier : rentedProduct} mutableCopy];
    if (self = [super initWithProducts:products]) {
        
    }
    return self;
}

+(CPIAPHelper *)sharedInstance {
    static CPIAPHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)notifyStatusForProduct:(IAPProduct *)product
                        string:(NSString *)string {
    NSString * message = [NSString stringWithFormat:@"%@: %@",
                          product.skProduct.localizedTitle, string];
    [[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - UIAlertViewDelegate 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidSuscribe" object:nil];
}

@end
