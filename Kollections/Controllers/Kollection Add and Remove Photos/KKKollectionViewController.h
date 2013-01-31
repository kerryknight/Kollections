//
//  KKKollectionViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/30/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKEditKollectionViewController.h"
#import "KKKollectionTableViewController.h"
#import "ELCImagePickerController.h"

@interface KKKollectionViewController : UIViewController <KKEditKollectionViewControllerDelegate, KKKollectionTableViewControllerDelegate, ELCImagePickerControllerDelegate, UIGestureRecognizerDelegate> {
    
}

@property (nonatomic, strong) PFObject *kollection;

@end
