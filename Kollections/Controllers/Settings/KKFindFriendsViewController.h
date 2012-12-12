//
//  KKFindFriendsViewController.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "KKFindFriendsCell.h"

@interface KKFindFriendsViewController : PFQueryTableViewController <KKFindFriendsCellDelegate, ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>

@end
