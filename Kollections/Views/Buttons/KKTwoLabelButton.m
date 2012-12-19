//
//  KKTwoLabelButton.m
//  Kollections
//
//  Created by Kerry Knight on 12/19/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKTwoLabelButton.h"

@implementation KKTwoLabelButton

static void *kButtonStateObservingContext = &kButtonStateObservingContext;

@synthesize buttonState;
@synthesize topLabel;
@synthesize bottomLabel;

- (void)awakeFromNib {
    
    //set the unhighlighted/highlighted button graphics
    [self setImage:[UIImage imageNamed:@"kkHeaderKoinCountsButtonUp.png"] forState:( kKKButtonStateUp )];
    [self setImage:[UIImage imageNamed:@"kkHeaderKoinCountsButtonUp.png"] forState:( kKKButtonStateUp | UIControlStateHighlighted )];
    
    [self setImage:[UIImage imageNamed:@"kkHeaderKoinCountsButtonDown.png"] forState:( kKKButtonStateDown )];
    [self setImage:[UIImage imageNamed:@"kkHeaderKoinCountsButtonDown.png"] forState:( kKKButtonStateDown | UIControlStateHighlighted )];
    
    NSAssert( kKKButtonStateUp & UIControlStateApplication, @"Custom state not within UIControlStateApplication" );
    NSAssert( kKKButtonStateDown & UIControlStateApplication, @"Custom state not within UIControlStateApplication" );
    
    //add and initialize/format the 2 button labels
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, self.bounds.size.width, 20)];
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.topLabel.frame.origin.y + self.topLabel.frame.size.height, self.bounds.size.width, 20)];
    self.topLabel.textAlignment = UITextAlignmentCenter;
    self.bottomLabel.textAlignment = UITextAlignmentCenter;
    self.topLabel.font = [UIFont fontWithName:@"OriyaSangamMN-Bold" size:17];
    self.bottomLabel.font = [UIFont fontWithName:@"OriyaSangamMN-Bold" size:17];
    self.topLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    self.bottomLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    self.topLabel.backgroundColor = [UIColor clearColor];
    self.bottomLabel.backgroundColor = [UIColor clearColor];
    self.topLabel.text = @"top label";
    self.bottomLabel.text = @"bottom label";
    [self addSubview:self.topLabel];
    [self addSubview:self.bottomLabel];
    
    [self addObserver:self forKeyPath:@"buttonState" options:NSKeyValueObservingOptionOld context:kButtonStateObservingContext];
}

- (UIControlState)state {
    NSInteger returnState = [super state];
    return ( returnState | self.buttonState );
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"playbackState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( context == kButtonStateObservingContext ) {
        NSInteger oldState = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        if ( oldState != self.buttonState ) {
            [self layoutSubviews];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
