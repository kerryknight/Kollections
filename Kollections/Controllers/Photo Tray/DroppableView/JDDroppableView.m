//
//  JDDroppableView.m
//  JDDroppableView
//
//  Created by Markus Emrich on 01.07.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//

#import "JDDroppableView.h"
#import "NSMutableArray+AddOns.h"


#define DROPPABLEVIEW_ANIMATION_DURATION 0.33

@interface JDDroppableView ()
@property (nonatomic, weak) UIView *activeDropTarget;
@property (nonatomic, weak) UIView *outerView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL didInitalizeReturnPosition;

- (void)commonInit;
- (void)beginDrag;
- (void)dragAtPosition:(UITouch*)touch;
- (void)endDrag;
- (void)changeSuperView;

@end

@implementation JDDroppableView

- (id)initWithFrame:(CGRect)frame {
//    NSLog(@"%s", __FUNCTION__);
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithDropTarget:(UIView*)target {
//    NSLog(@"%s", __FUNCTION__);
	self = [super init];
	if (self != nil) {
        [self commonInit];
        [self addDropTarget:target forIndexPath:nil];
	}
	return self;
}

- (void)awakeFromNib {
//    NSLog(@"%s", __FUNCTION__);
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
//    NSLog(@"%s", __FUNCTION__);
    self.shouldUpdateReturnPosition = YES;
}

#pragma mark UIResponder (touch handling)

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
//    NSLog(@"%s", __FUNCTION__);
    [super touchesBegan:touches withEvent:event];
	[self beginDrag];
	[self dragAtPosition:[touches anyObject]];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
//    NSLog(@"%s", __FUNCTION__);
    [super touchesMoved:touches withEvent:event];
    [self dragAtPosition: [touches anyObject]];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
//    NSLog(@"%s", __FUNCTION__);
    [super touchesEnded:touches withEvent:event];
	[self endDrag];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
    [super touchesCancelled:touches withEvent:event];
	[self endDrag];
}

#pragma mark target managment

- (void)addDropTarget:(UIView*)target forIndexPath:(NSIndexPath*)indexPath {
//    NSLog(@"%s", __FUNCTION__);
    // lazy initialization
    if (!self.dropTargets) {
        self.dropTargets = [NSMutableArray array];
    }
    
    // add target
    if ([target isKindOfClass:[UIView class]]) {
        [self.dropTargets addUniqueObject:target];
    }
    
    if (indexPath) {
        self.activeIndexPath = indexPath;
    }
}

- (void)removeDropTarget:(UIView*)target {
    [self.dropTargets removeObject:target];
}

- (void)replaceDropTargets:(NSArray*)targets {
    self.dropTargets = [[targets filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[UIView class]];
    }]] mutableCopy];
}

#pragma mark dragging logic

- (void)beginDrag {
//    NSLog(@"%s", __FUNCTION__);
    // remember state
    self.isDragging = YES;
    
    // inform delegate
    if ([self.delegate respondsToSelector: @selector(droppableViewBeganDragging:)]) {
        [self.delegate droppableViewBeganDragging: self];
    };
	
    // update return position
    if (!self.didInitalizeReturnPosition || self.shouldUpdateReturnPosition) {
        self.returnPosition = self.center;
        self.didInitalizeReturnPosition = YES;
    }
	
    // swap out of scrollView if needed
	[self changeSuperView];
}


- (void)dragAtPosition:(UITouch*)touch {
//    NSLog(@"%s", __FUNCTION__);
    // animate into new position
    [UIView animateWithDuration:DROPPABLEVIEW_ANIMATION_DURATION animations:^{
        self.center = [touch locationInView: self.superview];
    }];
	
    // inform delegate
    if ([self.delegate respondsToSelector: @selector(droppableViewDidMove:)]) {
        [self.delegate droppableViewDidMove:self];
    }
	
    // check target contact
    if (self.dropTargets.count > 0) {
        for (UIView *dropTarget in self.dropTargets) {
            CGRect intersect = CGRectIntersection(self.frame, dropTarget.frame);
            BOOL didHitTarget = intersect.size.width > 50 || intersect.size.height > 50;
            
            // target was hit
            if (didHitTarget) {
                if (self.activeDropTarget != dropTarget)
                {
                    // inform delegate about leaving old target
                    if (self.activeDropTarget != nil) {
                        // inform delegate
                        if ([self.delegate respondsToSelector:@selector(droppableView:leftTarget:)]) {
                            [self.delegate droppableView:self leftTarget:self.activeDropTarget];
                        }
                    }
                    
                    // set new active target
                    self.activeDropTarget = dropTarget;
                    
                    // inform delegate about new target hit
                    if ([self.delegate respondsToSelector:@selector(droppableView:enteredTarget:)]) {
                        [self.delegate droppableView:self enteredTarget:self.activeDropTarget];
                    }
                    return;
                }
                
                // currently not over any target
            } else {
                if (self.activeDropTarget == dropTarget)
                {
                    // inform delegate
                    if ([self.delegate respondsToSelector:@selector(droppableView:leftTarget:)]) {
                        [self.delegate droppableView:self leftTarget:self.activeDropTarget];
                    }
                    
                    // reset active target
                    self.activeDropTarget = nil;
                    return;
                }
            }
        }
    }
}


- (void) endDrag {
//    NSLog(@"%s", __FUNCTION__);
    // inform delegate
    if([self.delegate respondsToSelector: @selector(droppableViewEndedDragging:onTarget:)]) {
        [self.delegate droppableViewEndedDragging:self onTarget:self.activeDropTarget];
    }
	
    // check target drop
    BOOL shouldAnimateBack = YES;
    if (self.activeDropTarget != nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(shouldAnimateDroppableViewBack:wasDroppedOnTarget:forIndexPath:)]) {
            shouldAnimateBack = [self.delegate shouldAnimateDroppableViewBack:self wasDroppedOnTarget:self.activeDropTarget forIndexPath:self.activeIndexPath];
        }
    }

    // insert in scrollview again, if needed
    if (shouldAnimateBack) {
        [self changeSuperView];
    }
    
    // update state
    // this needs to be after superview change
    self.isDragging = NO;
    self.activeDropTarget = nil;
	
    // animate back to original position
    if (shouldAnimateBack) {
        [UIView animateWithDuration:DROPPABLEVIEW_ANIMATION_DURATION animations:^{
            self.center = self.returnPosition;
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
}

-(void)hide {
    //this is called if we dismiss the current view or close/drag the photo tray view
    [UIView animateWithDuration:DROPPABLEVIEW_ANIMATION_DURATION animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark superview handling

- (void)willMoveToSuperview:(id)newSuperview {
//    NSLog(@"%s", __FUNCTION__);
    if (!self.isDragging && [newSuperview isKindOfClass: [UIScrollView class]]) {
        self.scrollView = newSuperview;
        self.outerView = self.scrollView.superview;
    }
}

- (void) changeSuperView {
//    NSLog(@"%s", __FUNCTION__);
    if (!self.scrollView) {
        [self.superview bringSubviewToFront: self];
        return;
    }
    
	UIView * tmp = self.superview;
	
	[self removeFromSuperview];
	[self.outerView addSubview: self];
	
	self.outerView = tmp;
	
	// set new position
	
	CGPoint ctr = self.center;
	
	if (self.outerView == self.scrollView) {
		ctr.x += self.scrollView.frame.origin.x - self.scrollView.contentOffset.x;
		ctr.y += self.scrollView.frame.origin.y - self.scrollView.contentOffset.y;
	} else {
		ctr.x -= self.scrollView.frame.origin.x - self.scrollView.contentOffset.x;
		ctr.y -= self.scrollView.frame.origin.y - self.scrollView.contentOffset.y;
	}

	self.center = ctr;
}


@end
