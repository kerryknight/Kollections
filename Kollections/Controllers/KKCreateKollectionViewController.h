//
//  KKCreateKollectionViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKKollectionSetupTableViewController.h"

@protocol KKCreateKollectionViewControllerDelegate <NSObject>
-(void)createKollectionViewControllerDidCreateNewKollection:(PFObject*)kollection;
@end

@interface KKCreateKollectionViewController : UIViewController <KKKollectionSetupTableViewControllerDelegate, UITextViewDelegate> {
    
}

@property (nonatomic, strong) id<KKCreateKollectionViewControllerDelegate>delegate;

@end
