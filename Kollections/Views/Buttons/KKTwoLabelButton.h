//
//  KKTwoLabelButton.h
//  Kollections
//
//  Created by Kerry Knight on 12/19/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    kKKButtonStateUp    = 0x00010000,
    kKKButtonStateDown  = 0x00020000,
};

@interface KKTwoLabelButton : UIButton {
    
}

@property (nonatomic,assign) NSInteger buttonState;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;

@end
