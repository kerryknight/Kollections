//
//  KKEditKollectionViewController.h
//  Kollections
//
//  Editd by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKKollectionSetupTableViewController.h"

@protocol KKEditKollectionViewControllerDelegate <NSObject>
-(void)editKollectionViewControllerDidEditKollection:(PFObject*)kollection atIndex:(NSUInteger)index;
@end

@interface KKEditKollectionViewController : UIViewController <KKKollectionSetupTableViewControllerDelegate, UITextViewDelegate> {
    
}

@property (nonatomic, strong) id<KKEditKollectionViewControllerDelegate>delegate;
@property (nonatomic, assign) NSUInteger kollectionToLoadIndex;
@property (nonatomic, strong) PFObject *kollection;
@property (nonatomic, strong) NSMutableArray *subjectsArrayToCompareAgainst; //use to determine if dirty data or not
@end
