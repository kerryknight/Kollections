//
//  KKKollectionTitleLabel.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionTitleLabel.h"
#import "KKSideScrollingTableViewConstants.h"

@implementation KKKollectionTitleLabel

- (id)initWithFrame:(CGRect)frame {
//    NSLog(@"%s", __FUNCTION__);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPersistentBackgroundColor:(UIColor*)color {
    super.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)color {
    // do nothing - background color never changes
}

- (void)drawTextInRect:(CGRect)rect {
    CGFloat newWidth = rect.size.width - kKollectionTitleLabelPadding;
    CGFloat newHeight = rect.size.height;
    
    CGRect newRect = CGRectMake(kKollectionTitleLabelPadding * 0.5, 0, newWidth, newHeight);
    
    [super drawTextInRect:newRect];
}

@end
