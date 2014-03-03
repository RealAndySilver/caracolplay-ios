//
//  CreateListView.m
//  CaracolPlay
//
//  Created by Developer on 24/02/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CreateListView.h"
#import "MyUtilities.h"

@interface CreateListView() <UITextFieldDelegate>
@property (strong, nonatomic) UITextField *listNameTextfield;
@end

@implementation CreateListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        self.layer.cornerRadius = 5.0;
        [MyUtilities addParallaxEffectWithMovementRange:20.0 inView:self];
        
        //Title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 - 50.0, 20.0, 100.0, 30.0)];
        titleLabel.text = @"Crear Lista";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:titleLabel];
        
        //'Nombre' label
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, frame.size.height/2 - 15.0, 50.0, 30.0)];
        nameLabel.text = @"Nombre";
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [self addSubview:nameLabel];
        
        //list name textfield
        self.listNameTextfield = [[UITextField alloc] initWithFrame:CGRectMake(90.0, frame.size.height/2 - 25.0, 150.0, 40.0)];
        self.listNameTextfield.textColor = [UIColor whiteColor];
        self.listNameTextfield.font = [UIFont systemFontOfSize:13.0];
        self.listNameTextfield.delegate = self;
        [self addSubview:self.listNameTextfield];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(90.0, self.listNameTextfield.frame.origin.y + self.listNameTextfield.frame.size.height - 25.0, self.listNameTextfield.frame.size.width + 15.0, 15.0)];
        line.text = @"_________________";
        line.textColor = [UIColor whiteColor];
        [self addSubview:line];
        
        //'Crear' button setup
        UIButton *createButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, frame.size.height - 50.0, frame.size.width/2 - 20 - 20, 40.0)];
        [createButton setTitle:@"Crear" forState:UIControlStateNormal];
        [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        createButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [createButton addTarget:self action:@selector(createList) forControlEvents:UIControlEventTouchUpInside];
        [createButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
        [self addSubview:createButton];
        
        //'Cancelar' button setup
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2.0 + 20.0, createButton.frame.origin.y, frame.size.width/2.0 - 20.0 - 20.0, 40.0)];
        [cancelButton setTitle:@"Cancelar" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"BotonInicio.png"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [self addSubview:cancelButton];
        
        [self showViewWithAnimation];
    }
    return self;
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
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self.delegate hiddeAnimationDidEndInCreateListView:self];
                     }];
}

#pragma mark - Actions 

-(void)createList {
    if ([self.listNameTextfield.text length] > 0) {
        [self.delegate createButtonPressedInCreateListView:self withListName:self.listNameTextfield.text];
        [self hiddeViewWithAnimation];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Debes asignarle un nombre a tu lista." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)cancel {
    [self.delegate cancelButtonPressedInCreateListView:self];
    [self hiddeViewWithAnimation];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
