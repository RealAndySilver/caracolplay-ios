//
//  TermsAndConditionsPadViewController.h
//  CaracolPlay
//
//  Created by Developer on 20/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsAndConditionsPadViewController : UIViewController
@property (assign, nonatomic) BOOL controllerWasPresentedInFormSheet;
@property (assign, nonatomic) BOOL showTerms;
@property (assign, nonatomic) BOOL showPrivacy;
@property (strong, nonatomic) NSString *mainTitle;
@end
