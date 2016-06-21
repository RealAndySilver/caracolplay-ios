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

@end
