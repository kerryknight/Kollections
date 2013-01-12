//
//  KKSetupTableBaseCell.h
//  Kollections
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKSetupTableBaseCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *footnoteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *divider;
@property (weak, nonatomic) IBOutlet UITextView *entryField;

- (void)formatCell;

@end
