//
//  KKSubjectEntryTableCell.h
//  Kollections
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlightIndentTextField.h"

@interface KKSubjectEntryTableCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UIImageView *divider;
@property (weak, nonatomic) IBOutlet SlightIndentTextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionField;
@property (weak, nonatomic) IBOutlet UITextField *payoutField;

- (void)formatCell;

@end
