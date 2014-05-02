//
//  LargeProductionImageView.m
//  CaracolPlay
//
//  Created by Developer on 13/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "LargeProductionImageView.h"

@interface LargeProductionImageView() <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@end

@implementation LargeProductionImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        //Scroll view
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.minimumZoomScale = 0.5;
        self.scrollView.zoomScale = 1.0;
        self.scrollView.maximumZoomScale = 3.0;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        
        // 1. ImageView
        self.largeImageView = [[UIImageView alloc] init];
        self.largeImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.largeImageView.clipsToBounds = YES;
        [self.scrollView addSubview:self.largeImageView];
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
        [self addGestureRecognizer:self.tapGesture];
        
        // 2. Close button
        /*self.closeButton = [[UIButton alloc] init];
        [self.closeButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];*/
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = self.largeImageView.image.size;
    self.largeImageView.frame = CGRectMake(0.0, 0.0, self.largeImageView.image.size.width, self.largeImageView.image.size.height);
    self.largeImageView.center = CGPointMake(self.scrollView.frame.size.width/2.0, self.scrollView.frame.size.height/2.0);
    NSLog(@"large ima size: %@", NSStringFromCGSize(self.largeImageView.image.size));
    //self.closeButton.frame = CGRectMake(self.bounds.size.width - 30.0, 0.0, 30.0, 30.0);
    
    [self showView];
}

-(void)showView {
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished){}];
}

-(void)dismissView {
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.largeImageView;
}

@end
