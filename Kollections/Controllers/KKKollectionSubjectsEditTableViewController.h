//
//  KKKollectionSubjectsEditTableViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol KKKollectionSubjectsEditTableViewControllerDelegate <NSObject>
@optional
- (void)subjectEditTableViewControllerDidSubmitSubject:(NSMutableDictionary*)subject;
@end

@interface KKKollectionSubjectsEditTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate> {
    
}

@property (nonatomic, strong) id<KKKollectionSubjectsEditTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *subject;

- (void)resetTableContentInsetsWithIndexPath:(NSIndexPath *)indexPath;
- (void)dismissView;
@end
