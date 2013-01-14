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

typedef enum {
    KKKollectionSetupCellDataTypeNumber = 0,
    KKKollectionSetupCellDataTypeToggle,
    KKKollectionSetupCellDataTypeString,
    KKKollectionSetupCellDataTypeShare,
    KKKollectionSetupCellDataTypeKeywords,
    KKKollectionSetupCellDataTypePhoto,
    KKKollectionSetupCellDataTypeLongString,
    KKKollectionSetupCellDataTypeSegment,
    KKKollectionSetupCellDataTypeNavigate
}KKKollectionSetupCellDataType;
//like http://www.lovelyui.com/post/5160477107/compose-on-dapsem


@protocol KKKollectionSetupTableViewControllerDelegate <NSObject>
@optional
- (void)setupTableViewDidSelectRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)setupTableViewDismissAnyKeyboard;
@end

@interface KKKollectionSetupTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate> {
    
}

@property (nonatomic, strong) id<KKKollectionSetupTableViewControllerDelegate> delegate;
@property (nonatomic, assign) KKKollectionSetupType kollectionSetupType;//used to set table based on new/existing kollection
@property (nonatomic, assign) KKKollectionSetupCellDataType cellDataType;//used to dynamically load cells based on input values
@property (nonatomic, strong) NSMutableArray *tableObjects;

- (void)resetTableContentInsetsWithIndexPath:(NSIndexPath *)indexPath;
- (void)dismissView;
@end
