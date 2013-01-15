//
//  KKSetupTableNavigateCell.m
//  Kollections
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKSetupTableNavigateCell.h"

@implementation KKSetupTableNavigateCell

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
    self.footnoteLabel.textColor = kGray5;
    self.entryField.textColor = kGray4;
    self.entryField.backgroundColor = [UIColor clearColor];
    [self.rowButton setBackgroundImage:[UIImage imageNamed:@"kkRowButtonDown.png"] forState:UIControlStateHighlighted];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
