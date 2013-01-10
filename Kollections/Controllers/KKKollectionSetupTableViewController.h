//
//  KKKollectionSetupTableViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    KKKollectionSetupTypeNew = 0,
    KKKollectionSetupTypeEdit
} KKKollectionSetupType;

@protocol KKKollectionSetupTableViewControllerDelegate <NSObject>
@optional
- (void)setupTableViewDidSelectRowAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface KKKollectionSetupTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    
}

@property (nonatomic, strong) id<KKKollectionSetupTableViewControllerDelegate> delegate;
@property (nonatomic, assign) KKKollectionSetupType kollectionSetupType;//used to set table based on new/existing kollection
@property (nonatomic, strong) NSMutableArray *tableObjects;
@end
