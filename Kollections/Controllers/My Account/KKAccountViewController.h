//
//  KKAccountViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKMyAccountSummaryTableViewController.h"
#import "KKSideScrollToolBarViewController.h"
#import "KKKollectionsBarViewController.h"
#import "KKCreateKollectionViewController.h"

typedef enum {
    KKMyAccountHeaderToolItemKollections = 0,
    KKMyAccountHeaderToolItemSubmissions,
    KKMyAccountHeaderToolItemFavorites,
    KKMyAccountHeaderToolItemFollowers,
    KKMyAccountHeaderToolItemFollowing,
    KKMyAccountHeaderToolItemAchievements,
    KKMyAccountHeaderToolItemStore
} KKMyAccountHeaderToolItem;

@interface KKAccountViewController : KKMyAccountSummaryTableViewController <SRRefreshDelegate, KKSideScrollToolBarViewControllerDelegate, KKKollectionsBarViewControllerDelegate, KKCreateKollectionViewControllerDelegate> {
    
}

@property (nonatomic, assign) KKMyAccountHeaderToolItem headerToolItem; //typedef used in switch statement for determining what toolbar item was touched
@property (nonatomic, strong) PFUser *user;

- (void)loadProfilePhoto:(id)sender;

@end
