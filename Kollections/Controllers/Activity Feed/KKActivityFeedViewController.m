//
//  KKActivityFeedViewController.m
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKActivityFeedViewController.h"
#import "KKSettingsActionSheetDelegate.h"
#import "KKActivityCell.h"
#import "KKAccountViewController.h"
#import "KKPhotoDetailsViewController.h"
#import "KKBaseTextCell.h"
#import "KKLoadMoreCell.h"
#import "KKSettingsButtonItem.h"
#import "KKFindFriendsViewController.h"
#import "MBProgressHUD.h"

@interface KKActivityFeedViewController ()

@property (nonatomic, strong) KKSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

static NSString *const kKKActivityTypeLikeString = @"liked your photo";
static NSString *const kKKActivityTypeCommentString = @"commented on your photo";
static NSString *const kKKActivityTypeFollowString = @"started following you";
static NSString *const kKKActivityTypeJoinedString = @"joined Kollections";

@implementation KKActivityFeedViewController

@synthesize settingsActionSheetDelegate;
@synthesize lastRefresh;
@synthesize blankTimelineView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KKAppDelegateApplicationDidReceiveRemoteNotification object:nil];    
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.className = kKKActivityClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 15;          
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];

    // Add Settings button
    self.navigationItem.rightBarButtonItem = [[KKSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:KKAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"ActivityFeedBlank.png"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(24.0f, 113.0f, 271.0f, 140.0f)];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];

    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kKKUserDefaultsActivityFeedViewControllerLastRefreshKey];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        NSString *activityString = [KKActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kKKActivityTypeKey]];
        PFUser *user = (PFUser*)[object objectForKey:kKKActivityFromUserKey];
        NSString *nameString = @"";

        if (user) {
            nameString = [user objectForKey:kKKUserDisplayNameKey];
        }
        
        return [KKActivityCell heightForCellWithName:nameString contentString:activityString];
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = [self.objects objectAtIndex:indexPath.row];
        if ([activity objectForKey:kKKActivityPhotoKey]) {
            KKPhotoDetailsViewController *detailViewController = [[KKPhotoDetailsViewController alloc] initWithPhoto:[activity objectForKey:kKKActivityPhotoKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else if ([activity objectForKey:kKKActivityFromUserKey]) {
            KKAccountViewController *detailViewController = [[KKAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [detailViewController setUser:[activity objectForKey:kKKActivityFromUserKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.className];
        [query setLimit:0];
        return query;
    }

    PFQuery *query = [PFQuery queryWithClassName:self.className];
    [query whereKey:kKKActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kKKActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [query whereKeyExists:kKKActivityFromUserKey];
    [query includeKey:kKKActivityFromUserKey];
    [query includeKey:kKKActivityPhotoKey];
    [query orderByDescending:@"createdAt"];

    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSLog(@"Loading from cache");
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    

    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kKKUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        self.tableView.scrollEnabled = NO;
        self.navigationController.tabBarItem.badgeValue = nil;

        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kKKActivityTypeKey] isEqualToString:kKKActivityTypeJoined]) {
                unreadCount++;
            }
        }
        
        if (unreadCount > 0) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",unreadCount];
        } else {
            self.navigationController.tabBarItem.badgeValue = nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"ActivityCell";

    KKActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[KKActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    [cell setActivity:object];

    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }

    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    KKLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[KKLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
   }
    return cell;
}


#pragma mark - KKActivityCellDelegate Methods

- (void)cell:(KKActivityCell *)cellView didTapActivityButton:(PFObject *)activity {    
    // Get image associated with the activity
    PFObject *photo = [activity objectForKey:kKKActivityPhotoKey];
    
    // Push single photo view controller
    KKPhotoDetailsViewController *photoViewController = [[KKPhotoDetailsViewController alloc] initWithPhoto:photo];
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)cell:(KKBaseTextCell *)cellView didTapUserButton:(PFUser *)user {    
    // Push account view controller
    KKAccountViewController *accountViewController = [[KKAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}


#pragma mark - KKActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kKKActivityTypeLike]) {
        return kKKActivityTypeLikeString;
    } else if ([activityType isEqualToString:kKKActivityTypeFollow]) {
        return kKKActivityTypeFollowString;
    } else if ([activityType isEqualToString:kKKActivityTypeComment]) {
        return kKKActivityTypeCommentString;
    } else if ([activityType isEqualToString:kKKActivityTypeJoined]) {
        return kKKActivityTypeJoinedString;
    } else {
        return nil;
    }
}

#pragma mark - ()



- (void)settingsButtonAction:(id)sender {
    settingsActionSheetDelegate = [[KKSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile", @"Find Friends", @"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)inviteFriendsButtonAction:(id)sender {
    KKFindFriendsViewController *detailViewController = [[KKFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    [self loadObjects];
}

@end
