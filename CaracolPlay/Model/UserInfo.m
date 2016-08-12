//
//  UserInfo.m
//  CaracolPlay
//
//  Created by Developer on 8/04/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "UserInfo.h"
#import "FileSaver.h"

@implementation UserInfo

+(UserInfo *)sharedInstance {
    static UserInfo *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[UserInfo alloc] init];
        });
    }
    return shared;
}

-(void)persistUserLists {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSMutableDictionary *userDict = [fileSaver getDictionary:@"UserHasLoginDic"].mutableCopy;
    userDict[@"MyLists"] = self.myListIds;
    [fileSaver setDictionary:userDict withKey:@"UserHasLoginDic"];
}

-(void)setAuthCookieForWebView {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:self.sessionKey forKey:NSHTTPCookieName];
    [cookieProperties setObject:self.session forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"premium.icck.net" forKey:NSHTTPCookieDomain];
    //[cookieProperties setObject:@"http://www.caracolplay.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    // set expiration to one month from now or any NSDate of your choosing
    // this makes the cookie sessionless and it will persist across web sessions and app launches
    /// if you want the cookie to be destroyed when your app exits, don't set this
    [cookieProperties setObject:self.session_expires forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    NSLog(@"UserInfo: the cookie has been set: SessionKey: %@, Session: %@", self.sessionKey, self.session);
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        NSLog(@"Cookieeesssss: %@", cookie.description);
    }
}

@end
