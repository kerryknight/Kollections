//
//  KKAccountViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKPhotoTimelineViewController.h"
#import "KKSideScrollToolBarViewController.h"

typedef enum {
    KKMyAccountHeaderToolItemKollections = 0,
    KKMyAccountHeaderToolItemSubmissions,
    KKMyAccountHeaderToolItemFavorites,
    KKMyAccountHeaderToolItemAchievements,
    KKMyAccountHeaderToolItemStore
} KKMyAccountHeaderToolItem;

@interface KKAccountViewController : KKPhotoTimelineViewController <SRRefreshDelegate, KKSideScrollToolBarViewControllerDelegate> {
    
}

@property (nonatomic, assign) KKMyAccountHeaderToolItem headerToolItem; //used in switch statement for determining what toolbar item was touched
@property (nonatomic, strong) PFUser *user;

@end
