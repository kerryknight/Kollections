//
//  KKFindFriendsViewController.m
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKFindFriendsViewController.h"
#import "KKProfileImageView.h"
#import "KKAppDelegate.h"
#import "KKLoadMoreCell.h"
#import "KKAccountViewController.h"
#import "MBProgressHUD.h"
#import "KKToolbarButton.h"

typedef enum {
    KKFindFriendsFollowingNone = 0,    // User isn't following anybody in Friends list
    KKFindFriendsFollowingAll,         // User is following all Friends
    KKFindFriendsFollowingSome         // User is following some of their Friends
} KKFindFriendsFollowStatus;

@interface KKFindFriendsViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) KKFindFriendsFollowStatus followStatus;
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;
@end

static NSUInteger const kKKCellFollowTag = 2;
static NSUInteger const kKKCellNameLabelTag = 3;
static NSUInteger const kKKCellAvatarTag = 4;
static NSUInteger const kKKCellPhotoNumLabelTag = 5;

@implementation KKFindFriendsViewController
@synthesize headerView;
@synthesize followStatus;
@synthesize selectedEmailAddress;
@synthesize outstandingFollowQueries;
@synthesize outstandingCountQueries;
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        self.selectedEmailAddress = @"";

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
        
        // Used to determine Follow/Unfollow All button status
        self.followStatus = KKFindFriendsFollowingSome;
        
        [self.tableView setSeparatorColor:[UIColor colorWithRed:210.0f/255.0f green:203.0f/255.0f blue:182.0f/255.0f alpha:1.0]];
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
        
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TitleFindFriends.png"]];
    
    //add custom toolbar button
    KKToolbarButton *backButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Back"];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:backButton];
    
    if ([MFMailComposeViewController canSendMail] || [MFMessageComposeViewController canSendText]) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 67)];
        [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFindFriendsCell.png"]]];
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setBackgroundColor:[UIColor clearColor]];
        [clearButton addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setFrame:self.headerView.frame];
        [self.headerView addSubview:clearButton];
        NSString *inviteString = @"Invite friends";
        CGSize inviteStringSize = [inviteString sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
        UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.headerView.frame.size.height-inviteStringSize.height)/2, inviteStringSize.width, inviteStringSize.height)];
        [inviteLabel setText:inviteString];
        [inviteLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [inviteLabel setTextColor:[UIColor colorWithRed:87.0f/255.0f green:72.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
        [inviteLabel setBackgroundColor:[UIColor clearColor]];
        [self.headerView addSubview:inviteLabel];
        UIImageView *separatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparatorTimeline.png"]];
        [separatorImage setFrame:CGRectMake(0, self.headerView.frame.size.height-2, 320, 2)];
        [self.headerView addSubview:separatorImage];
        [self.tableView setTableHeaderView:self.headerView];
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        return [KKFindFriendsCell heightForCell];
    } else {
        return 44.0f;
    }
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    // Use cached facebook friend ids
    NSArray *facebookFriends = [[KKCache sharedCache] facebookFriends];
    
    // Query for all friends you have on facebook and who are using the app
    PFQuery *friendsQuery = [PFUser query];
    [friendsQuery whereKey:kKKUserFacebookIDKey containedIn:facebookFriends];
    
    // Query for all Parse employees
    NSMutableArray *parseEmployees = [[NSMutableArray alloc] initWithArray:kKKParseEmployeeAccounts];
    [parseEmployees removeObject:[[PFUser currentUser] objectForKey:kKKUserFacebookIDKey]];
    PFQuery *parseEmployeeQuery = [PFUser query];
    [parseEmployeeQuery whereKey:kKKUserFacebookIDKey containedIn:parseEmployees];
        
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:friendsQuery, parseEmployeeQuery, nil]];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:kKKUserDisplayNameKey];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kKKActivityClassKey];
    [isFollowingQuery whereKey:kKKActivityFromUserKey equalTo:[PFUser currentUser]];
    [isFollowingQuery whereKey:kKKActivityTypeKey equalTo:kKKActivityTypeFollow];
    [isFollowingQuery whereKey:kKKActivityToUserKey containedIn:self.objects];
    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number == self.objects.count) {
                self.followStatus = KKFindFriendsFollowingAll;
                [self configureUnfollowAllButton];
                for (PFUser *user in self.objects) {
                    [[KKCache sharedCache] setFollowStatus:YES user:user];
                }
            } else if (number == 0) {
                self.followStatus = KKFindFriendsFollowingNone;
                [self configureFollowAllButton];
                for (PFUser *user in self.objects) {
                    [[KKCache sharedCache] setFollowStatus:NO user:user];
                }
            } else {
                self.followStatus = KKFindFriendsFollowingSome;
                [self configureFollowAllButton];
            }
        }
        
        if (self.objects.count == 0) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
    
    if (self.objects.count == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    KKFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[KKFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    
    [cell setUser:(PFUser*)object];

    [cell.photoLabel setText:@"0 photos"];
    
    NSDictionary *attributes = [[KKCache sharedCache] attributesForUser:(PFUser *)object];
    
    if (attributes) {
        // set them now
        NSString *pluralizedPhoto;
        NSNumber *number = [[KKCache sharedCache] photoCountForUser:(PFUser *)object];
        if ([number intValue] == 1) {
            pluralizedPhoto = @"photo";
        } else {
            pluralizedPhoto = @"photos";
        }
        [cell.photoLabel setText:[NSString stringWithFormat:@"%@ %@", number, pluralizedPhoto]];
    } else {
        @synchronized(self) {
            NSNumber *outstandingCountQueryStatus = [self.outstandingCountQueries objectForKey:indexPath];
            if (!outstandingCountQueryStatus) {
                [self.outstandingCountQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                PFQuery *photoNumQuery = [PFQuery queryWithClassName:kKKPhotoClassKey];
                [photoNumQuery whereKey:kKKPhotoUserKey equalTo:object];
                [photoNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [photoNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    @synchronized(self) {
                        [[KKCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:(PFUser *)object];
                        [self.outstandingCountQueries removeObjectForKey:indexPath];
                    }
                    KKFindFriendsCell *actualCell = (KKFindFriendsCell*)[tableView cellForRowAtIndexPath:indexPath];
                    NSString *pluralizedPhoto;
                    if (number == 1) {
                        pluralizedPhoto = @"photo";
                    } else {
                        pluralizedPhoto = @"photos";
                    }
                    [actualCell.photoLabel setText:[NSString stringWithFormat:@"%d %@", number, pluralizedPhoto]];
                    
                }];
            };
        }
    }

    cell.followButton.selected = NO;
    cell.tag = indexPath.row;
    
    if (self.followStatus == KKFindFriendsFollowingSome) {
        if (attributes) {
            [cell.followButton setSelected:[[KKCache sharedCache] followStatusForUser:(PFUser *)object]];
        } else {
            @synchronized(self) {
                NSNumber *outstandingQuery = [self.outstandingFollowQueries objectForKey:indexPath];
                if (!outstandingQuery) {
                    [self.outstandingFollowQueries setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
                    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kKKActivityClassKey];
                    [isFollowingQuery whereKey:kKKActivityFromUserKey equalTo:[PFUser currentUser]];
                    [isFollowingQuery whereKey:kKKActivityTypeKey equalTo:kKKActivityTypeFollow];
                    [isFollowingQuery whereKey:kKKActivityToUserKey equalTo:object];
                    [isFollowingQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                    
                    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingFollowQueries removeObjectForKey:indexPath];
                            [[KKCache sharedCache] setFollowStatus:(!error && number > 0) user:(PFUser *)object];
                        }
                        if (cell.tag == indexPath.row) {
                            [cell.followButton setSelected:(!error && number > 0)];
                        }
                    }];
                }
            }
        }
    } else {
        [cell.followButton setSelected:(self.followStatus == KKFindFriendsFollowingAll)];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NextPageCellIdentifier = @"NextPageCell";
    
    KKLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:NextPageCellIdentifier];
    
    if (cell == nil) {
        cell = [[KKLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NextPageCellIdentifier];
        [cell.mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFindFriendsCell.png"]]];
        cell.hideSeparatorBottom = YES;
        cell.hideSeparatorTop = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}


#pragma mark - KKFindFriendsCellDelegate

- (void)cell:(KKFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    KKAccountViewController *accountViewController = [[KKAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:aUser];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(KKFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    [self shouldToggleFollowFriendForCell:cellView];
}


#pragma mark - ABPeoplePickerDelegate

/* Called when the user cancels the address book view controller. We simply dismiss it. */
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

/* Called when a member of the address book is selected, we return YES to display the member's details. */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

/* Called when the user selects a property of a person in their address book (ex. phone, email, location,...)
   This method will allow them to send a text or email inviting them to Kollections.  */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {

    if (property == kABPersonEmailProperty) {

        //original Anypic code commented out 12Dec2012
//        ABMultiValueRef emailProperty = ABRecordCopyValue(person,property);
//        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailProperty,identifier);
//        self.selectedEmailAddress = email;
        
        //***** fix proposed by user Orlando on Parse forum as replacement for above commented out code - 12Dec2012 - https://www.parse.com/questions/bug-anypic
        ABMultiValueRef emailProperty = ABRecordCopyValue(person,property);
        CFIndex index = ABMultiValueGetIndexForIdentifier(emailProperty, identifier);
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailProperty, index);
        self.selectedEmailAddress = email;
        CFRelease(emailProperty);
        //***** fix *****//

        if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
            // ask user
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Invite %@",@""] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"iMessage", nil];
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        } else if ([MFMailComposeViewController canSendMail]) {
            // go directly to mail
            [self presentMailComposeViewController:email];
        } else if ([MFMessageComposeViewController canSendText]) {
            // go directly to iMessage
            [self presentMessageComposeViewController:email];
        }

    } else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty,identifier);
        
        if ([MFMessageComposeViewController canSendText]) {
            [self presentMessageComposeViewController:phone];
        }
    }
    
    return NO;
}

#pragma mark - MFMailComposeDelegate

/* Simply dismiss the MFMailComposeViewController when the user sends an email or cancels */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];  
}


#pragma mark - MFMessageComposeDelegate

/* Simply dismiss the MFMessageComposeViewController when the user sends a text or cancels */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }

    if (buttonIndex == 0) {
        [self presentMailComposeViewController:self.selectedEmailAddress];
    } else if (buttonIndex == 1) {
        [self presentMessageComposeViewController:self.selectedEmailAddress];
    }
}

#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inviteFriendsButtonAction:(id)sender {
    ABPeoplePickerNavigationController *addressBook = [[ABPeoplePickerNavigationController alloc] init];
    addressBook.peoplePickerDelegate = self;
    
    if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonEmailProperty], [NSNumber numberWithInt:kABPersonPhoneProperty], nil];
    } else if ([MFMailComposeViewController canSendMail]) {
        addressBook.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    } else if ([MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    }

    [self presentModalViewController:addressBook animated:YES];
}

- (void)followAllFriendsButtonAction:(id)sender {

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow  animated:YES];
    hud.color = kMint4;
    [hud setDimBackground:YES];
    
    self.followStatus = KKFindFriendsFollowingAll;
    [self configureUnfollowAllButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];

        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
        for (int r = 0; r < self.objects.count; r++) {
            PFObject *user = [self.objects objectAtIndex:r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            KKFindFriendsCell *cell = (KKFindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            cell.followButton.selected = YES;
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(followUsersTimerFired:) userInfo:nil repeats:NO];
        [KKUtility followUsersEventually:self.objects block:^(BOOL succeeded, NSError *error) {
            // note -- this block is called once for every user that is followed successfully. We use a timer to only execute the completion block once no more saveEventually blocks have been called in 2 seconds
            [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0f]];
        }];

    });
}

- (void)unfollowAllFriendsButtonAction:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow  animated:YES];
    hud.color = kMint4;
    [hud setDimBackground:YES];

    self.followStatus = KKFindFriendsFollowingNone;
    [self configureFollowAllButton];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];

        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
        for (int r = 0; r < self.objects.count; r++) {
            PFObject *user = [self.objects objectAtIndex:r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            KKFindFriendsCell *cell = (KKFindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            cell.followButton.selected = NO;
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

        [KKUtility unfollowUsersEventually:self.objects];

        [[NSNotificationCenter defaultCenter] postNotificationName:KKUtilityUserFollowingChangedNotification object:nil];
    });

}

- (void)shouldToggleFollowFriendForCell:(KKFindFriendsCell*)cell {
    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        // Unfollow
        cell.followButton.selected = NO;
        [KKUtility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:KKUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        cell.followButton.selected = YES;
        [KKUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KKUtilityUserFollowingChangedNotification object:nil];
            } else {
                cell.followButton.selected = NO;
            }
        }];
    }
}

- (void)configureUnfollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow All" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];
}

- (void)configureFollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];
}

- (void)presentMailComposeViewController:(NSString *)recipient {
    // Create the compose email view controller
    MFMailComposeViewController *composeEmailViewController = [[MFMailComposeViewController alloc] init];
    
    // Set the recipient to the selected email and a default text
    [composeEmailViewController setMailComposeDelegate:self];
    [composeEmailViewController setSubject:@"Join me on Kollections"];
    [composeEmailViewController setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [composeEmailViewController setMessageBody:@"<h2>Share your pictures, share your story.</h2><p><a href=\"http://www.startakollection.com\">Kollections</a> is the easiest way to share photos with your friends. Get the app and share your fun photos with the world.</p><p><a href=\"http://www.startakollection.com\">Kollections</a> is fully powered by <a href=\"http://parse.com\">Parse</a>.</p>" isHTML:YES];
    
    // Dismiss the current modal view controller and display the compose email one.
    // Note that we do not animate them. Doing so would require us to present the compose
    // mail one only *after* the address book is dismissed.
    [self dismissModalViewControllerAnimated:NO];
    [self presentModalViewController:composeEmailViewController animated:NO];
}

- (void)presentMessageComposeViewController:(NSString *)recipient {
    // Create the compose text message view controller
    MFMessageComposeViewController *composeTextViewController = [[MFMessageComposeViewController alloc] init];
    
    // Send the destination phone number and a default text
    [composeTextViewController setMessageComposeDelegate:self];
    [composeTextViewController setRecipients:[NSArray arrayWithObjects:recipient, nil]];
    [composeTextViewController setBody:@"Check out Kollections! http://www.startakollection.com"];
    
    // Dismiss the current modal view controller and display the compose text one.
    // See previous use for reason why these are not animated.
    [self dismissModalViewControllerAnimated:NO];
    [self presentModalViewController:composeTextViewController animated:NO];
}

- (void)followUsersTimerFired:(NSTimer *)timer {
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:KKUtilityUserFollowingChangedNotification object:nil];
}

@end
