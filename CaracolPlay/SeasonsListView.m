//
//  SeasonsListView.m
//  CaracolPlay
//
//  Created by Developer on 24/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "SeasonsListView.h"
#import "MyUtilities.h"

@interface SeasonsListView() <UITableViewDataSource, UITableViewDelegate>
@end

@implementation SeasonsListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [MyUtilities addParallaxEffectWithMovementRange:20.0 inView:self];
        
        self.alpha = 0.0;
        self.backgroundColor = [UIColor blackColor];
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.layer.cornerRadius = 5.0;
        self.clipsToBounds = YES;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, frame.size.width, 30.0)];
        titleLabel.text = @"Listado de Temporadas";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        //Table view setup
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 50.0, frame.size.width, frame.size.height - 50.0)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        tableView.separatorColor = [UIColor blackColor];
        [self addSubview:tableView];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 58.0, -30.0, 88.0, 88.0)];
        [closeButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hiddeViewWithAnimation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        [self animateView];
    }
    return self;
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.textLabel.text = @"Temporada 1";
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate seasonsListView:self didSelectSeasonAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate seasonsListWillDisappear:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self.delegate seasonsListDidDisappear:self];
                     }];
}

#pragma mark - Custom Methods

-(void)hiddeViewWithAnimation {
    [self.delegate seasonsListWillDisappear:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self.delegate seasonsListDidDisappear:self];
                     }];
}

-(void)animateView {
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished){}];
}

@end
