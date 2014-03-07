//
//  SeasonsListView.h
//  CaracolPlay
//
//  Created by Developer on 24/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SeasonsListView;

@protocol SeasonListViewDelegate <NSObject>
@optional
-(void)seasonsListView:(SeasonsListView *)seasonListView didSelectSeasonAtIndex:(NSUInteger)index;
-(void)seasonsListWillDisappear:(SeasonsListView *)seasonsListView;
-(void)seasonsListDidDisappear:(SeasonsListView *)seasonsListView;
@end

@interface SeasonsListView : UIView
@property (strong, nonatomic) id <SeasonListViewDelegate> delegate;
@end
