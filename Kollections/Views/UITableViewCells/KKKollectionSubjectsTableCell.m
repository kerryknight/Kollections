//
//  KKKollectionSubjectsTableCell.m
//  Kollections
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionSubjectsTableCell.h"

@implementation KKKollectionSubjectsTableCell

#define kDISTANCE_TO_MOVE   30.0f
#define kDELETE_CIRCLE_X    20.0f
#define kREORDER_CONTROL_X  -5.0f
#define kCONFIRMATION_CONTROL_X - 10.0f

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    DLog(@"%s", __FUNCTION__);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)formatCell {
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
    self.headerLabel.textColor = kGray5;
    [self.rowButton setBackgroundImage:[UIImage imageNamed:@"kkRowButtonDown.png"] forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - editing view methods
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([self isEditing] == NO) {
        [UIView animateWithDuration:0.25 animations:^{
            self.descriptionLabel.alpha = 1.0; //show description label
        } completion:^(BOOL finished) {
        }];
    } else {
        //frame for editing mode
        self.contentView.frame = CGRectMake(0,
                                            self.contentView.frame.origin.y,
                                            self.contentView.frame.size.width + 100,
                                            self.contentView.frame.size.height);
        
        [UIView animateWithDuration:0.25 animations:^{
            self.descriptionLabel.alpha = 0.25; //hide description label so delete circle button isn't covering it
        } completion:^(BOOL finished) {
        }];
    }
}

//overriding this method to add a custom bg to the Delete button that appears
//when we attempt to edit (delete) a subject table row
- (void)willTransitionToState:(UITableViewCellStateMask)state {
//    DLog(@"state = %i", state);
    
    [super willTransitionToState:state];
    
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        
        for (UIView *subview in self.subviews) {
            
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
//                DLog(@"will transition to DeleteConfirmationControl");
            }
        }
    } 
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
//    NSLog(@"%s", __FUNCTION__);
    [super didTransitionToState:state];
    
    
    for (UIView *subview in self.subviews) {
        
        //left edit button
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellEditControl"]) {
            UIView *editButtonView = (UIView *)[subview.subviews objectAtIndex:0];
            CGRect f = editButtonView.frame;
            f.origin.x = kDELETE_CIRCLE_X;
            
            //slide the edit button just a bit more to the right from where it normally is
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            editButtonView.frame = f;
            [UIView commitAnimations];
        }
        
        //reordering control
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellReorderControl"]) {
            UIView *reorderView = (UIView *)[subview.subviews objectAtIndex:0];
            CGRect f = reorderView.frame;
            f.origin.x = kREORDER_CONTROL_X;
            
            //slide the reordering control just a bit more to the left from where it normally is
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            reorderView.frame = f;
            [UIView commitAnimations];
        }
        
        //delete confirmation button
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
            
            UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
            CGRect f = deleteButtonView.frame;
            f.origin.x = kCONFIRMATION_CONTROL_X;
            
            //slide the delete button just a bit more to the left from where it normally is
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            deleteButtonView.frame = f;
            [UIView commitAnimations];
        }
    }
}

@end
