//
//  CPIAPHelper.m
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CPIAPHelper.h"
#import "IAPProduct.h"

@interface CPIAPHelper()
@property (strong, nonatomic) NSString *productoComprado;
@end

@implementation CPIAPHelper

-(instancetype)init {
    //IAPProduct *suscriptionProduct = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.CaracolPlay.testsuscription"];
    //IAPProduct *rentedProduct = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.CaracolPlay.testrentedproduction"];
    //NSMutableDictionary *products = [@{suscriptionProduct.productIdentifier : suscriptionProduct, rentedProduct.productIdentifier : rentedProduct} mutableCopy];
    IAPProduct *colombiaEventProduct = [[IAPProduct alloc] initWithProductIdentifier:@"net.icck.CaracolPlay.Colombia.event1"];
    IAPProduct *colombiaRentedProduct = [[IAPProduct alloc] initWithProductIdentifier:@"net.icck.CaracolPlay.Colombia.rent1"];
    IAPProduct *colombiaSuscriptionProduct = [[IAPProduct alloc] initWithProductIdentifier:@"net.icck.CaracolPlay.Colombia.subscription"];
    IAPProduct *restOfWorldEventProduct = [[IAPProduct alloc] initWithProductIdentifier:@"net.icck.CaracolPlay.RM.event1"];
    IAPProduct *restOfWorldRentedProduct = [[IAPProduct alloc] initWithProductIdentifier:@"net.icck.CaracolPlay.RM.rent1"];
    IAPProduct *restOfWorldSuscriptionProduct = [[IAPProduct alloc] initWithProductIdentifier:@"net.icck.CaracolPlay.RM.subscription"];
    NSMutableDictionary *products = [@{colombiaEventProduct.productIdentifier : colombiaEventProduct,
                                       colombiaRentedProduct.productIdentifier : colombiaRentedProduct,
                                       colombiaSuscriptionProduct.productIdentifier : colombiaSuscriptionProduct,
                                       restOfWorldEventProduct.productIdentifier : restOfWorldEventProduct,
                                       restOfWorldRentedProduct.productIdentifier : restOfWorldRentedProduct,
                                       restOfWorldSuscriptionProduct.productIdentifier : restOfWorldSuscriptionProduct
                                       } mutableCopy];
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

/*- (void)notifyStatusForProduct:(IAPProduct *)product
                        string:(NSString *)string {
    NSString * message = [NSString stringWithFormat:@"%@: %@",
                          product.skProduct.localizedTitle, string];
    if ([product.productIdentifier isEqualToString:@"com.iamstudio.CaracolPlay.testsuscription"]) {
        self.productoComprado = @"suscripcion";
    } else {
        self.productoComprado = @"alquiler";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidSuscribe" object:nil userInfo:@{@"TypeOfProduct": self.productoComprado}];
}*/

- (void)notifyStatusForProduct:(IAPProduct *)product
                 transactionID:(NSString *)transactionID
                        string:(NSString *)string {
    /*NSString * message = [NSString stringWithFormat:@"%@: %@",
                          product.skProduct.localizedTitle, string];*/
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidSuscribe" object:nil userInfo:@{@"TransactionID": transactionID}];
}

@end
