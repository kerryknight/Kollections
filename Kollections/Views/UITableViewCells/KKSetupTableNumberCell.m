//
//  KKSetupTableNumberCell.m
//  Kollections
//
//  Created by Kerry Knight on 1/11/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKSetupTableNumberCell.h"

@implementation KKSetupTableNumberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    DLog(@"%s 1", __FUNCTION__);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)formatCell {
//    NSLog(@"%s", __FUNCTION__);
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
    self.headerLabel.textColor = kGray5;
    self.footnoteLabel.textColor = kGray5;
    self.numberField.backgroundColor = [UIColor colorWithRed:251 green:251 blue:250 alpha:1.0];//almost white
    self.numberField.textColor = kGray3;
    
    //put border on entry field
    self.numberField.layer.borderColor = kGray3.CGColor;
    self.numberField.layer.borderWidth = 0.75f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
