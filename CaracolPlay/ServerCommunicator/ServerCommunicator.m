//
//  ServerCommunicator.m
//  WebConsumer
//
//  Created by Andres Abril on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerCommunicator.h"
//#define ENDPOINT @"http://caracol.aws.af.cm/"
//#define ENDPOINT @"http://10.0.1.9:8080"
//#define ENDPOINT @"http://iamstudio-sweetwater.herokuapp.com/"
//#define ENDPOINT @"http://sweetwater.jit.su"
#define ENDPOINT @"http://appsdev.caracolplay.com"
//#define ENDPOINT @"http://apps.caracolplay.com"

#import "IAmCoder.h"
#import "UserInfo.h"

@implementation ServerCommunicator
@synthesize tag,delegate;
-(id)init {
    self = [super init];
    if (self)
    {
        tag = 0;
    }
    return self;
}
-(void)callServerWithGETMethod:(NSString*)method andParameter:(NSString*)parameter{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    parameter = [parameter stringByAppendingString:@"?player_br=aim"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",ENDPOINT,method,parameter]];
    NSLog(@"URL : %@", [url description]);
	//NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableURLRequest *theRequest = [self getHeaderForUrl:url];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = 60.0;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                        if(error == nil){
                                                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                            [self.delegate receivedDataFromServer:dictionary
                                                                                   withMethodName:method];
                                                        }
                                                        else{
                                                            [self.delegate serverError:error];
                                                        }
                                                    }];
    [dataTask resume];
}

-(void)callServerWithPOSTMethod:(NSString *)method andParameter:(NSString *)parameter httpMethod:(NSString *)httpMethod{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    //parameter = [parameter stringByAppendingString:@"?player_br=aim"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ENDPOINT,method]];
	//NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSMutableURLRequest *theRequest = [self getHeaderForUrl:url];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:httpMethod];
    NSData *data=[NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
    [theRequest setHTTPBody: data];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = 60.0;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                        if(error == nil){
                                                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                            [self.delegate receivedDataFromServer:dictionary
                                                                                   withMethodName:method];
                                                        }
                                                        else{
                                                            [self.delegate serverError:error];
                                                        }
                                                    }];
    [dataTask resume];
    NSLog(@"URL : %@ \n Body: %@", [url description],[[NSString alloc] initWithData:[theRequest HTTPBody] encoding:NSUTF8StringEncoding]);

}
//usuario:satinramiro pass: caracol11
//auth-> doble vez encodeado en base 64 usuario:password:session
//TS70-> tiempo desde 1970
//token-> tiempo+llave -> base 64

#pragma mark - http header
-(NSMutableURLRequest*)getHeaderForUrl:(NSURL*)url{
    /*NSString *key=@"lop+2dzuioa/000mojijiaop";
    NSString *time=[IAmCoder dateString];
    NSString *encoded=[NSString stringWithFormat:@"%@",[IAmCoder sha256:[NSString stringWithFormat:@"%@%@",key,time]]];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [theRequest setValue:[NSString stringWithFormat:@"%@",[IAmCoder base64String:key]] forHTTPHeaderField:@"C99-RSA"];
    [theRequest setValue:[NSString stringWithFormat:@"%@",[IAmCoder base64String:time]] forHTTPHeaderField:@"SSL"];
    [theRequest setValue:encoded forHTTPHeaderField:@"token"];
    NSLog(@"Header %@\nTime %@",theRequest.allHTTPHeaderFields,time);
    return theRequest;*/
 
    NSString *privateKey = @"aREwKMVVmjA81aea0mVNFh";
    NSString *time = [IAmCoder dateString];
    NSString *authString = [NSString stringWithFormat:@"%@:%@", [UserInfo sharedInstance].userName, [UserInfo sharedInstance].password];

    //NSMutableString *authString = [[NSMutableString alloc] init];
    /*if ([[UserInfo sharedInstance].session length] > 0) {
        authString = [NSMutableString stringWithFormat:@"%@:%@:%@", [UserInfo sharedInstance].userName, [UserInfo sharedInstance].password, [UserInfo sharedInstance].session];
    } else {
        authString = [NSMutableString stringWithFormat:@"%@:%@", [UserInfo sharedInstance].userName, [UserInfo sharedInstance].password];
    }*/
    NSLog(@"authstring: %@", authString);
    //NSString *authEncoded = [IAmCoder base64EncodeString:authString];
    NSString *authEncoded = [[authString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    //NSString *authDoubleEncoded = [IAmCoder base64EncodeString:authEncoded];
    NSString *authDoubleEncoded = [[authEncoded dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *token = [time stringByAppendingString:privateKey];
    //NSString *tokenEncoded = [IAmCoder base64EncodeString:token];
    NSString *tokenEncoded = [[token dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSLog(@"auth: %@", authDoubleEncoded);
    NSLog(@"TS70: %@", time);
    NSLog(@"token: %@", tokenEncoded);
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    //[theRequest setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [theRequest setValue:authDoubleEncoded forHTTPHeaderField:@"auth"];
    [theRequest setValue:time forHTTPHeaderField:@"TS70"];
    [theRequest setValue:tokenEncoded forHTTPHeaderField:@"token"];
    return theRequest;
}

@end
