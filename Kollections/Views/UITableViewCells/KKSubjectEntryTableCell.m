//
//  KKSubjectEntryTableCell.m
//  Kollections
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKSubjectEntryTableCell.h"

@implementation KKSubjectEntryTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    NSLog(@"%s 1", __FUNCTION__);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)formatCell {
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
    self.titleField.backgroundColor = [UIColor colorWithRed:251 green:251 blue:250 alpha:1.0];//almost white
    self.titleField.textColor = kMint4;
    
    //put border on entry field
    self.titleField.layer.borderColor = kGray3.CGColor;
    self.titleField.layer.borderWidth = 0.75f;
    
    self.descriptionField.backgroundColor = [UIColor colorWithRed:251 green:251 blue:250 alpha:1.0];//almost white
    self.descriptionField.textColor = kGray3;
    
    //put border on entry field
    self.descriptionField.layer.borderColor = kGray3.CGColor;
    self.descriptionField.layer.borderWidth = 0.75f;
    
    self.payoutField.backgroundColor = [UIColor colorWithRed:251 green:251 blue:250 alpha:1.0];//almost white
    self.payoutField.textColor = kMint4;
    
    //put border on entry field
    self.payoutField.layer.borderColor = kGray3.CGColor;
    self.payoutField.layer.borderWidth = 0.75f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
