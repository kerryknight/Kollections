//
//  KKToolbarButton.m
//  Kollections
//
//  Created by Kerry Knight on 1/4/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKToolbarButton.h"

@implementation KKToolbarButton

- (id)initWithFrame:(CGRect)frame isBackButton:(BOOL)isBackButton andTitle:(NSString*)title {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self = [UIButton buttonWithType:UIButtonTypeCustom];
        self.frame = frame;
        
        //customize the title label
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor colorWithRed:190.0f/255.0f green:182.0f/255.0f blue:166.0f/255.0f alpha:1.0];
        [self setTitle:title forState:UIControlStateNormal];
        
        //give label text some depth
        CALayer *labelLayer = self.titleLabel.layer;
        labelLayer.shadowRadius = 0.4;
        labelLayer.shadowOffset = CGSizeMake(0, -1);
        labelLayer.shadowColor = [[UIColor colorWithRed:134.0f/255.0f green:119.0f/255.0f blue:111.0f/255.0f alpha:1.0] CGColor];
        labelLayer.shadowOpacity = 1.0f;
        
        // Change button appearance based on button type
        if (isBackButton) {
            //it should be use back button images
            [self setBackgroundImage:[UIImage imageNamed:@"kkBackButtonNavBar.png"] forState:UIControlStateNormal];
            [self setBackgroundImage:[UIImage imageNamed:@"kkBackButtonNavBarSelected.png"] forState:UIControlStateHighlighted];
        } else {
            //it's a regular bar button so check it's title to determine if it's a destructive action
            if ([title isEqualToString:@"Delete"]) {
                //show the red button as destructive
                [self setBackgroundImage:[UIImage imageNamed:@"kkDestructiveNavBarButton.png"] forState:UIControlStateNormal];
                [self setBackgroundImage:[UIImage imageNamed:@"kkDestructiveNavBarButtonSelected.png"] forState:UIControlStateHighlighted];
                
                //also, make our label text color white
                self.titleLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
                
            } else {
                [self setBackgroundImage:[UIImage imageNamed:@"kkRegularNavBarButton.png"] forState:UIControlStateNormal];
                [self setBackgroundImage:[UIImage imageNamed:@"kkRegularNavigationBarSelected.png"] forState:UIControlStateHighlighted];
            }
        }
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    NSLog(@"%s", __FUNCTION__);
//    // Drawing code
//}


@end
