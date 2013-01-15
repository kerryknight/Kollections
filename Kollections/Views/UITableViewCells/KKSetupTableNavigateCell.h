//
//  KKSetupTableNavigateCell.h
//  Kollections
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKSetupTableNavigateCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *footnoteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *divider;
@property (weak, nonatomic) IBOutlet UITextView *entryField;
@property (weak, nonatomic) IBOutlet UIButton *rowButton;

- (void)formatCell;

@end
