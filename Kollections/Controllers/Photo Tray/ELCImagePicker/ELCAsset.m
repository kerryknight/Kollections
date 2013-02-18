//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"

@interface ELCAsset () {
    BOOL isInTableView;
}
@property (nonatomic, assign) CGPoint originalPosition;
@property (nonatomic, assign) CGPoint originalOutsidePosition;
@end

@implementation ELCAsset

@synthesize asset;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)_asset {
//	NSLog(@"%s", __FUNCTION__);
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = _asset;
		
//        isInTableView = YES;
        
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
		[self addSubview:assetImageView];
		
        //add a border
        self.layer.borderColor = kGray3.CGColor;
        self.layer.borderWidth = 0.75f;
    }
    
	return self;	
}

#pragma mark - DRAG AND DROP

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%s", __FUNCTION__);
    
    [self.delegate photoTouchDown:self];
//    self.originalPosition = self.center;
//    
//    NSLog(@"main view class = %@", [self.mainView class]);
//    NSLog(@"main view = %@", self.mainView);
//    
//    self.tableParent.scrollEnabled = NO;
//    
//	if (isInTableView == YES) {
//        NSLog(@"hereE");
//        
////        id appDelegate = [[UIApplication sharedApplication] delegate];
////        UIWindow *window = [appDelegate window];
//        
//		CGPoint newLoc = CGPointZero;
//        newLoc = [self.superview convertPoint:self.center toView:self.mainView];
//        
////        newLoc = [window convertPoint:self.center toView:self.superview];
//        
//        self.originalOutsidePosition = newLoc;
//        
//		[self removeFromSuperview];
//        
//        self.center = newLoc;
//		[self.mainView addSubview:self];
//        [self.mainView bringSubviewToFront:self];
//        
//        
////        [window addSubview:self];
////        [window bringSubviewToFront:self];
//        
//		isInTableView = NO;
//	}
//	else {
//		NSLog(@"hereD");
//	}
    
}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%s", __FUNCTION__);
//	[UIView beginAnimations:@"stalk" context:nil];
//	[UIView setAnimationDuration:.001];
//	[UIView setAnimationBeginsFromCurrentState:YES];
//    
//	UITouch *touch = [touches anyObject];
//	self.center = [touch locationInView:self.superview];
//    
//    NSLog(@"Frame: %@", NSStringFromCGRect(self.frame));
//    
//	[UIView commitAnimations];
//    
//    if ([self.delegate isInsideKollectionView:self touching:NO]){
//        
//    }
    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%s", __FUNCTION__);
//    if ([self.delegate isInsideKollectionView:self touching:YES]){
//        NSLog(@"hereA");
//        UIImageView * animation = [[UIImageView alloc] init];
//        animation.frame = CGRectMake(self.center.x - 32, self.center.y - 32, 40, 40);
//        [animation setAnimationDuration:0.35];
//        [animation startAnimating];
//        [self.mainView addSubview:animation];
//        [animation bringSubviewToFront:self.mainView];
//        ;
//    } else{
//        NSLog(@"hereB");
//        [UIView beginAnimations:@"goback" context:nil];
//        [UIView setAnimationDuration:0.4f];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        self.center = self.originalOutsidePosition;
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
////        loadingView.frame = CGRectMake(rect.origin.x, rect.origin.y - 80, rect.size.width, rect.size.height);
//        
//        [UIView commitAnimations];
//        
//    }
    
    [self.delegate photoTouchUp:self];
    
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
//    NSLog(@"%s", __FUNCTION__);
//    if ([animationID isEqualToString:@"goback"] && finished) {
//        NSLog(@"hereC");
//        [self removeFromSuperview];
//        self.center = self.originalPosition;
//        [self.tableParent addSubview:self];
//        isInTableView = YES;
//    }
//    
//    self.tableParent.scrollEnabled = YES;
}


-(void)toggleSelection {
    
	overlayView.hidden = !overlayView.hidden;
    
//    if([(ELCAssetTablePicker*)self.parent totalSelectedAssets] >= 10) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//		[alert show];
//		[alert release];	
//
//        [(ELCAssetTablePicker*)self.parent doneAction:nil];
//    }
}

-(BOOL)selected {
	
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    
	[overlayView setHidden:!_selected];
}

- (void)dealloc {
    self.asset = nil;
}

@end

