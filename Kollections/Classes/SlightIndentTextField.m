//
//  SlightIndentTextField.m
//  mIP
//
//  Created by Kerry Knight on 7/20/12.
//  Copyright (c) 2012 PPD. All rights reserved.
//

#import "SlightIndentTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation SlightIndentTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//these methods are so the text isn't smooshed against the left side of the textfield
- (CGRect)textRectForBounds:(CGRect)bounds {
    int margin = 5;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    int margin = 5;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y, bounds.size.width - margin, bounds.size.height);
    return inset;
}

@end
