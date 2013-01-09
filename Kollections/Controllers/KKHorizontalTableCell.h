//
//  KKHorizontalTableCell.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKHorizontalTableCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, strong) UIView *tableContainerView;
@property (nonatomic, strong) UITableView *horizontalTableView;
@property (nonatomic, strong) NSArray *kollections;

@end
