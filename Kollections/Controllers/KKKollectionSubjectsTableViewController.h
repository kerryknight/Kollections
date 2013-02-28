//
//  KKKollectionSubjectsTableViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKKollectionSubjectEditViewController.h"

@interface KKKollectionSubjectsTableViewController : UITableViewController <UITableViewDataSource, KKKollectionSubjectEditViewControllerDelegate, UIGestureRecognizerDelegate> {
    
}

@property (nonatomic, strong) NSMutableArray *subjects;

@end
