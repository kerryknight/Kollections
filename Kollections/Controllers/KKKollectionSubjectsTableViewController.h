//
//  KKKollectionSubjectsTableViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKKollectionSubjectsEditTableViewController.h"


@protocol KKKollectionSubjectsTableViewControllerDelegate <NSObject>
@optional
- (void)setupTableViewDidSelectRowAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface KKKollectionSubjectsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, KKKollectionSubjectsEditTableViewControllerDelegate> {
    
}

@property (nonatomic, strong) id<KKKollectionSubjectsTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *subjects;

- (void)resetTableContentInsetsWithIndexPath:(NSIndexPath *)indexPath;
- (void)dismissView;
@end
