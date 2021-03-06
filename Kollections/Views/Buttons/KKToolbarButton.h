//
//  KKToolbarButton.h
//  Kollections
//
//  Created by Kerry Knight on 1/4/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKToolbarButton : UIButton {
    
}

- (id)initWithFrame:(CGRect)frame isBackButton:(BOOL)isBackButton andTitle:(NSString*)title;
- (id)initWithTitle:(NSString*)title;
- (id)initAsActionButtonWithFrame:(CGRect)frame;

@end
