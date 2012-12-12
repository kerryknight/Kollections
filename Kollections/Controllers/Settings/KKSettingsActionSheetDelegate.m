//
//  KKSettingsActionSheetDelegate.m
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKSettingsActionSheetDelegate.h"
#import "KKFindFriendsViewController.h"
#import "KKAccountViewController.h"
#import "KKAppDelegate.h"

// ActionSheet button indexes
typedef enum {
	kKKSettingsProfile = 0,
	kKKSettingsFindFriends,
	kKKSettingsLogout,
    kKKSettingsNumberOfButtons
} kKKSettingsActionSheetButtons;
 
@implementation KKSettingsActionSheetDelegate

@synthesize navController;

#pragma mark - Initialization

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (id)init {
    return [self initWithNavigationController:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.navController) {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kKKSettingsActionSheetButtons)buttonIndex) {
        case kKKSettingsProfile:
        {
            KKAccountViewController *accountViewController = [[KKAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [accountViewController setUser:[PFUser currentUser]];
            [navController pushViewController:accountViewController animated:YES];
            break;
        }
        case kKKSettingsFindFriends:
        {
            KKFindFriendsViewController *findFriendsVC = [[KKFindFriendsViewController alloc] init];
            [navController pushViewController:findFriendsVC animated:YES];
            break;
        }
        case kKKSettingsLogout:
            // Log out user and present the login view controller
            [(KKAppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            break;
        default:
            break;
    }
}

@end
