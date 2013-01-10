//
//  KKMyAccountSummaryTableViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKKollectionsBarViewController.h"

//use this enum to differentiate among table rows and the kollections they hold
typedef enum {
    KKMyAccountKollectionsBarTypeMyPublic = 10000,
    KKMyAccountKollectionsBarTypeMyPrivate,
    KKMyAccountKollectionsBarTypeSubscribedPublic,
    KKMyAccountKollectionsBarTypeSubscribedPrivate
} KKMyAccountKollectionsBarType;

@interface KKMyAccountSummaryTableViewController : PFQueryTableViewController {
    
}

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) KKKollectionsBarViewController *kollectionsBar;
@property (nonatomic, assign) KKMyAccountKollectionsBarType kollectionType;

@end
