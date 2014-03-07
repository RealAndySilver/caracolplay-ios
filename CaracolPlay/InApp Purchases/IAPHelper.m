//
//  IAPHelper.m
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IAPHelper.h"
#import "IAPProduct.h"
#import <StoreKit/StoreKit.h>

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (strong, nonatomic) SKProductsRequest *productsRequest;
@end

@implementation IAPHelper {
    RequestProductsCompletionHandler _completionHandler;
}

-(instancetype)initWithProducts:(NSMutableDictionary *)products {
    if (self = [super init]) {
        _products = products;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    _completionHandler = [completionHandler copy];
    NSMutableSet *productIdentifiers = [NSMutableSet setWithCapacity:[self.products count]];
    for (IAPProduct *product in [self.products allValues]) {
        product.availableForPurchase = NO;
        NSLog(@"identificador del producto: %@", product.productIdentifier);
        [productIdentifiers addObject:product.productIdentifier];
    }
    
    NSLog(@"numero de identificadores: %d", [productIdentifiers count]);
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

-(void)buyProduct:(IAPProduct *)product {
    //NSAssert(product.allowedToPurchase, @"This product isn't allowed to purchase");
    if (!product.allowedToPurchase) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"En este momento no se puede comprar el producto. intenta en un momento" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    NSLog(@"Comprando: %@", product.productIdentifier);
    product.purchaseInProgress = YES;
    SKPayment *payment = [SKPayment paymentWithProduct:product.skProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate 

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    self.productsRequest = nil;
    NSArray *skProducts = response.products;
    NSLog(@"cantidad de productos recibidos: %d", [skProducts count]);
    for (SKProduct *skProduct in skProducts) {
        IAPProduct *product = self.products[skProduct.productIdentifier];
        product.skProduct = skProduct;
        product.availableForPurchase = YES;
    }
    
    for (NSString *invalidProductidentifier in response.invalidProductIdentifiers) {
        IAPProduct *product = self.products[invalidProductidentifier];
        product.availableForPurchase = NO;
        NSLog(@"Invalid product identifier: %@", invalidProductidentifier);
    }
    
    NSMutableArray *availableProducts = [[NSMutableArray alloc] init];
    for (IAPProduct *product in [self.products allValues]) {
        if (product.availableForPurchase) {
            [availableProducts addObject:product];
        }
    }
    
    _completionHandler(YES, availableProducts);
    _completionHandler = nil;
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load products: %@", error.localizedDescription);
    self.productsRequest = nil;
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

#pragma mark - SKPaymenttransactionObserver 

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    [self provideContentForTransaction:transaction
                     productIdentifier:transaction.payment.productIdentifier];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    [self provideContentForTransaction:transaction
                     productIdentifier:
     transaction.originalTransaction.payment.productIdentifier];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@",
              transaction.error.localizedDescription);
    }
    IAPProduct * product =
    _products[transaction.payment.productIdentifier];
    /*[self notifyStatusForProductIdentifier:
     transaction.payment.productIdentifier
                                    string:@"La compra no se realizó"];*/
    product.purchaseInProgress = NO;
    [[SKPaymentQueue defaultQueue]
     finishTransaction: transaction];
}

- (void)notifyStatusForProductIdentifier:
(NSString *)productIdentifier string:(NSString *)string {
    IAPProduct * product = _products[productIdentifier];
    [self notifyStatusForProduct:product string:string];
}

- (void)notifyStatusForProduct:(IAPProduct *)product
                        string:(NSString *)string {
}

- (void)provideContentForTransaction:(SKPaymentTransaction *)transaction
                   productIdentifier:(NSString *)productIdentifier {
    [self provideContentForProductIdentifier:productIdentifier
                                      notify:YES];
    [[SKPaymentQueue defaultQueue]
     finishTransaction:transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)
productIdentifier notify:(BOOL)notify {
    IAPProduct * product = _products[productIdentifier];
    //[self provideContentForProductIdentifier:productIdentifier];
    if (notify) {
        [self notifyStatusForProductIdentifier:productIdentifier
                                        string:@"Compra realizada con éxito!"];
    }
    product.purchaseInProgress = NO;
}
/*- (void)provideContentForProductIdentifier:
(NSString *)productIdentifier {
}*/

@end
