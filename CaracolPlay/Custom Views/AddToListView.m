//
//  AddToListView.m
//  CaracolPlay
//
//  Created by Developer on 24/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "AddToListView.h"
#import "MyUtilities.h"

@interface AddToListView() <UITableViewDataSource, UITableViewDelegate>
@end

@implementation AddToListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        self.layer.cornerRadius = 5.0;
        self.clipsToBounds = YES;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [MyUtilities addParallaxEffectWithMovementRange:20.0 inView:self];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, frame.size.width - 40.0, 30.0)];
        titleLabel.text = @"Agregar a Lista";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:titleLabel];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 50.0, frame.size.width, frame.size.height - 120.0)];
        tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        tableView.separatorColor = [UIColor blackColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self addSubview:tableView];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(30.0, frame.size.height - 55.0, frame.size.width - 60.0, 40.0)];
        [closeButton setTitle:@"Cerrar" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(hiddeViewWithAnimation) forControlEvents:UIControlEventTouchUpInside];
        closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [self addSubview:closeButton];
        
        [self showViewWithAnimation];
    }
    return self;
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = @"Series Clásicas";
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate listWasSelectedAtIndex:indexPath.row inAddToListView:self];
    [self hiddeViewWithAnimation];
}

#pragma mark - Custom Methods

-(void)showViewWithAnimation {
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

-(void)hiddeViewWithAnimation {
    [self.delegate addToListViewWillDisappear:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self.delegate addToListViewDidDisappear:self];
                     }];
}

@end
