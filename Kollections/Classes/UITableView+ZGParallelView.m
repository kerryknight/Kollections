//
//  UITableView+ZGParallelView.m
//  ZGParallelViewForTable
//
//  Created by Kyle Fang on 1/7/13.
//  Copyright (c) 2013 kylefang. All rights reserved.
//

#import "UITableView+ZGParallelView.h"
#import <objc/runtime.h>

@interface ZGScrollView : UIScrollView
@property (nonatomic, weak) UITableView *tableView;
@end



static char UITableViewZGParallelViewDisplayRatio;
static char UITableViewZGParallelViewViewHeight;
static char UITableViewZGParallelViewCutOffAtMax;
static char UITableViewZGParallelViewEmbeddedScrollView;
static char UITableViewZGParallelViewIsObserving;


@interface UITableView (ZGParallelViewPri)
@property (nonatomic, assign) CGFloat displayRatio;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) BOOL cutOffAtMax;
@property (nonatomic, strong) ZGScrollView *embeddedScrollView;
@property (nonatomic, assign) BOOL isObserving;
@end


@implementation UITableView (ZGParallelViewPri)
@dynamic displayRatio, viewHeight, cutOffAtMax, embeddedScrollView, isObserving;

- (void)setDisplayRatio:(CGFloat)displayRatio {
    [self willChangeValueForKey:@"displayRatio"];
    objc_setAssociatedObject(self, &UITableViewZGParallelViewDisplayRatio,
                             [NSNumber numberWithFloat:displayRatio],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"displayRatio"];
}

- (CGFloat)displayRatio {
    NSNumber *number = objc_getAssociatedObject(self, &UITableViewZGParallelViewDisplayRatio);
    return [number floatValue];
}

- (void)setViewHeight:(CGFloat)viewHeight {
    [self willChangeValueForKey:@"viewHeight"];
    objc_setAssociatedObject(self, &UITableViewZGParallelViewViewHeight,
                             [NSNumber numberWithFloat:viewHeight],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"viewHeight"];
}

- (CGFloat)viewHeight {
    NSNumber *number = objc_getAssociatedObject(self, &UITableViewZGParallelViewViewHeight);
    return [number floatValue];
}

- (void)setCutOffAtMax:(BOOL)cutOffAtMax{
    [self willChangeValueForKey:@"cutOffAtMax"];
    objc_setAssociatedObject(self, &UITableViewZGParallelViewCutOffAtMax, [NSNumber numberWithBool:cutOffAtMax], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"cutOffAtMax"];
}

- (BOOL)cutOffAtMax{
    NSNumber *number = objc_getAssociatedObject(self, &UITableViewZGParallelViewCutOffAtMax);
    if (number == nil) {
        return NO;
    } else {
        return [number boolValue];
    }
}

- (void)setEmbeddedScrollView:(ZGScrollView *)embeddedScrollView {
    [self willChangeValueForKey:@"embeddedScrollView"];
    objc_setAssociatedObject(self, &UITableViewZGParallelViewEmbeddedScrollView,
                             embeddedScrollView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"embeddedScrollView"];
}

- (ZGScrollView *)embeddedScrollView {
    return objc_getAssociatedObject(self, &UITableViewZGParallelViewEmbeddedScrollView);
}

- (void)setIsObserving:(BOOL)isObserving {
    if (self.isObserving == YES && isObserving == NO) {
        @try {
            [self removeObserver:self forKeyPath:@"contentOffset"];
        }
        @catch (NSException *exception) {
            //It's not observing
        }
    }
    
    [self willChangeValueForKey:@"isObserving"];
    objc_setAssociatedObject(self, &UITableViewZGParallelViewIsObserving,
                             [NSNumber numberWithBool:isObserving],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"isObserving"];
}

- (BOOL)isObserving {
    NSNumber *number = objc_getAssociatedObject(self, &UITableViewZGParallelViewIsObserving);
    if (number == nil) {
        return NO;
    } else {
        return [number boolValue];
    }
}
@end



#define DEFAULT_DISPLAY_Ratio   0.5f
@implementation UITableView (ZGParallelView)
- (void)addParallelViewWithUIView:(UIView *)aViewToAdd {
    [self addParallelViewWithUIView:aViewToAdd withDisplayRatio:DEFAULT_DISPLAY_Ratio];
}

- (void)addParallelViewWithUIView:(UIView *)aViewToAdd withDisplayRatio:(CGFloat)displayRatio{
    [self addParallelViewWithUIView:aViewToAdd withDisplayRatio:displayRatio cutOffAtMax:NO];
}

- (void)addParallelViewWithUIView:(UIView *)aViewToAdd withDisplayRatio:(CGFloat)aDisplayRatio cutOffAtMax:(BOOL)cutOffAtMax{
    NSAssert(aViewToAdd != nil, @"aViewToAdd can not be nil");
    
    aViewToAdd.frame = CGRectOffset(aViewToAdd.frame, -aViewToAdd.frame.origin.x, -aViewToAdd.frame.origin.y);
    if (aDisplayRatio>1 && aDisplayRatio<0) {
        self.displayRatio = 1;
    } else {
        self.displayRatio = aDisplayRatio;
    }
    self.viewHeight = aViewToAdd.frame.size.height;
    self.cutOffAtMax = cutOffAtMax;
    self.embeddedScrollView = [[ZGScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.viewHeight + 80)];
    self.embeddedScrollView.tableView = self;
    [self.embeddedScrollView addSubview:aViewToAdd];
    aViewToAdd.frame = CGRectOffset(aViewToAdd.frame, 0, self.viewHeight*(1.f - self.displayRatio)/2.f);
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.viewHeight*self.displayRatio)];
    [headView addSubview:self.embeddedScrollView];
    self.embeddedScrollView.frame = CGRectOffset(self.embeddedScrollView.frame, 0, self.viewHeight*(self.displayRatio-1.f));
    self.tableHeaderView = headView;
    
    if (self.isObserving == NO) {
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        self.isObserving = YES;
    }
}

- (void)updateParallelView {
    CGFloat yOffset = self.contentOffset.y;
    if (yOffset<0 && yOffset>self.viewHeight*(self.displayRatio-1.f)) {
        self.embeddedScrollView.contentOffset = CGPointMake(0.f, -yOffset*0.5f);
    }
    
    if (self.cutOffAtMax && yOffset<self.viewHeight*(self.displayRatio-1.f)) {
        self.contentOffset = CGPointMake(0.f, self.viewHeight*(self.displayRatio-1.f));
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    [self updateParallelView];
}

- (void)dealloc{
    if (self.isObserving) {
        self.isObserving = NO; 
    }
}

@end



@implementation ZGScrollView
@synthesize tableView;
- (void)dealloc {
    if ([self.tableView isObserving] == YES) {
        self.tableView.isObserving = NO;//!!Remove KVO Observer
    }
}
@end
