//
//  KKMyAccountSummaryTableViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKKollectionsBarViewController.h"

@interface KKMyAccountSummaryTableViewController : PFQueryTableViewController <KKKollectionsBarViewControllerDelegate> {
    
}

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) KKKollectionsBarViewController *kollectionsBar;

@end
