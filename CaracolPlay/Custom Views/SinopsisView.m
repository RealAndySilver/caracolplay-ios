//
//  SinopsisView.m
//  CaracolPlay
//
//  Created by Developer on 19/08/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SinopsisView.h"
#import "UIColor+AppColors.h"

@interface SinopsisView()
@property (strong, nonatomic) UIWebView *sinopsisWebView;
@end

@implementation SinopsisView

#pragma mark - Setters & Getters 

-(void)setSinopsisString:(NSString *)sinopsisString {
    _sinopsisString = sinopsisString;
    NSString *str = [NSString stringWithFormat:@"<html><body style='background-color: transparent; color:black; font-family: helvetica;'>%@</body></html>", sinopsisString];
    [self.sinopsisWebView loadHTMLString:str baseURL:nil];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor caracolLightGrayColor];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 53.0, -27.0, 80.0, 80.0)];
        [closeButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        //Main Title
        self.mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 40.0, frame.size.width, 40.0)];
        self.mainTitle.font = [UIFont boldSystemFontOfSize:25.0];
        self.mainTitle.textColor = [UIColor caracolMediumBlueColor];
        self.mainTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.mainTitle];
        
        //WebView
        self.sinopsisWebView = [[UIWebView alloc] initWithFrame:CGRectMake(20.0, 130.0, frame.size.width - 40.0, frame.size.height - 160.0 - 20.0)];
        self.sinopsisWebView.backgroundColor = [UIColor clearColor];
        self.sinopsisWebView.opaque = NO;
        [self addSubview:self.sinopsisWebView];
    }
    return self;
}

-(void)showInView:(UIView *)view {
    [view addSubview:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished){}];
}

#pragma mark - Actions 

-(void)closeView {
    [self.delegate closeButtonPressedInSinopsisView:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self.delegate sinopsisViewDidDissapear:self];
                     }];
}

@end
