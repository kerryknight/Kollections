//
//  KKKollectionSubjectsTableCell.m
//  Kollections
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionSubjectsTableCell.h"

@implementation KKKollectionSubjectsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    NSLog(@"%s 1", __FUNCTION__);
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
        // Lay out subviews normally for non-editing mode
    } else {
        //frame for editing mode
        self.contentView.frame = CGRectMake(0,
                                            self.contentView.frame.origin.y,
                                            self.contentView.frame.size.width + 100,
                                            self.contentView.frame.size.height);
    }
}

//overriding this method to add a custom bg to the Delete button that appears
//when we attempt to edit (delete) a subject table row
- (void)willTransitionToState:(UITableViewCellStateMask)state {
    
    [super willTransitionToState:state];
    
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        
        for (UIView *subview in self.subviews) {
            
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                
            }
        }
    }
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    
    [super didTransitionToState:state];
    
    if (state == UITableViewCellStateShowingDeleteConfirmationMask || state == UITableViewCellStateDefaultMask) {
        for (UIView *subview in self.subviews) {
            
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                
                UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
                CGRect f = deleteButtonView.frame;
                f.origin.x -= 15;
                
                //slide the delete button just a bit more to the left from where it normally is
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDelegate:self];
                deleteButtonView.frame = f;
                [UIView commitAnimations];
            }
        }
    }
}

@end
