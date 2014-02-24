//
//  AddToListView.h
//  CaracolPlay
//
//  Created by Developer on 24/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddToListView;

@protocol AddToListViewDelegate <NSObject>
@optional
-(void)listWasSelectedAtIndex:(NSUInteger)index inAddToListView:(AddToListView *)addToListView;
-(void)addToListViewWillDisappear:(AddToListView *)addToListView;
-(void)addToListViewDidDisappear:(AddToListView *)addToListView;
@end

@interface AddToListView : UIView
@property (strong, nonatomic) id <AddToListViewDelegate> delegate;
@end
