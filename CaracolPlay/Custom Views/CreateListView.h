//
//  CreateListView.h
//  CaracolPlay
//
//  Created by Developer on 24/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CreateListView;

@protocol CreateListViewDelegate <NSObject>
@optional
-(void)createButtonPressedInCreateListView:(CreateListView *)createListView withListName:(NSString *)listName;
-(void)cancelButtonPressedInCreateListView:(CreateListView *)createListView;
-(void)hiddeAnimationDidEndInCreateListView:(CreateListView *)createListView;
@end

@interface CreateListView : UIView
@property (strong, nonatomic) id <CreateListViewDelegate> delegate;
@end
