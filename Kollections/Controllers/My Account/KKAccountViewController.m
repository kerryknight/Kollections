//
//  KKAccountViewController.m
//  Kollections
//
//  Created by Héctor Ramos on 5/2/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKAccountViewController.h"
#import "KKPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "KKLoadMoreCell.h"
#import "KKMyAccountHeaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SRSlimeView.h"
#import "KKAppDelegate.h"
#import "KKToolbarButton.h"

@interface KKAccountViewController() {
    SRRefreshView *slimeRefreshView;
}

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) KKMyAccountHeaderViewController *headerViewController;
@property (nonatomic, strong) KKToolbarButton *logoutButton;
@property (nonatomic, strong) UILabel *logoutLabel;
@end

@implementation KKAccountViewController
@synthesize user;

#pragma mark - Initialization

#pragma mark - UIViewController
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
//        self.className = kKKActivityClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        
//        // Whether the built-in pagination is enabled
//        self.paginationEnabled = YES;
//        
//        // The number of objects to show per page
//        self.objectsPerPage = 15;
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
    if (![PFUser currentUser]) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    
    self.user = [PFUser currentUser];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 222.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
    
    self.headerViewController = [[KKMyAccountHeaderViewController alloc] init];
    [self addChildViewController:self.headerViewController];
    [self.headerView addSubview:self.headerViewController.view];
    [self.headerViewController didMoveToParentViewController:self];
    self.headerViewController.toolBarViewController.delegate = self;

    //insert pull to refresh slime view
    slimeRefreshView = [[SRRefreshView alloc] init];
    slimeRefreshView.delegate = self;
    slimeRefreshView.upInset = 0;
    slimeRefreshView.slimeMissWhenGoingBack = YES;
    slimeRefreshView.slime.bodyColor = [UIColor colorWithRed:149.0f/255.0f green:219.0f/255.0f blue:218.0f/255.0f alpha:1.0];
//    slimeRefreshView.slime.skinColor = [UIColor colorWithRed:74.0f/255.0f green:165.0f/255.0f blue:164.0f/255.0f alpha:1.0];
    [self.tableView addSubview:slimeRefreshView];
    
    //add image view to hold the user's profile pic
    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake(17.0f, 15.0f, 66.0f, 65.0f)];
    [self.headerViewController.view addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    CALayer *layer = [profilePictureImageView layer];
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 0.0f;
    
    //retrieve the user's profile pic to insert
    PFFile *imageFile = [self.user objectForKey:kKKUserProfilePicMediumKey];
    if (imageFile) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.200f animations:^{
                    profilePictureImageView.alpha = 1.0f;
                }];
            }
        }];
    } else {
        //if no image file, make sure we're not logged in with facebook and add a button to allow upload
        if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            //no profile photo available so add a button to allow the user to add one on their own
            UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
            profileButton.frame = [self.headerViewController.view viewWithTag:100].frame;//tag of the placeholder imageview
            [profileButton setBackgroundImage:[UIImage imageNamed:@"kkHeaderUserPhotoPlaceholderDown.png"] forState:UIControlEventTouchDown];
            [profileButton addTarget:self action:@selector(profilePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.headerViewController.view addSubview:profileButton];
        }
    }
    
    //set the label values appropriately for the user
    self.headerViewController.displayNameLabel.text = [self.user objectForKey:kKKUserDisplayNameKey];
//
//    UIImageView *photoCountIconImageView = [[UIImageView alloc] initWithImage:nil];
//    [photoCountIconImageView setImage:[UIImage imageNamed:@"IconPics.png"]];
//    [photoCountIconImageView setFrame:CGRectMake( 26.0f, 50.0f, 45.0f, 37.0f)];
//    [self.headerView addSubview:photoCountIconImageView];
//
//    UILabel *photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 94.0f, 92.0f, 22.0f)];
//    [photoCountLabel setTextAlignment:UITextAlignmentCenter];
//    [photoCountLabel setBackgroundColor:[UIColor clearColor]];
//    [photoCountLabel setTextColor:[UIColor whiteColor]];
//    [photoCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
//    [photoCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
//    [photoCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
//    [self.headerView addSubview:photoCountLabel];
//
//    UIImageView *followersIconImageView = [[UIImageView alloc] initWithImage:nil];
//    [followersIconImageView setImage:[UIImage imageNamed:@"IconFollowers.png"]];
//    [followersIconImageView setFrame:CGRectMake( 247.0f, 50.0f, 52.0f, 37.0f)];
//    [self.headerView addSubview:followersIconImageView];
//
//    UILabel *followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 94.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
//    [followerCountLabel setTextAlignment:UITextAlignmentCenter];
//    [followerCountLabel setBackgroundColor:[UIColor clearColor]];
//    [followerCountLabel setTextColor:[UIColor whiteColor]];
//    [followerCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
//    [followerCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
//    [followerCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
//    [self.headerView addSubview:followerCountLabel];
//
//    UILabel *followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 110.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
//    [followingCountLabel setTextAlignment:UITextAlignmentCenter];
//    [followingCountLabel setBackgroundColor:[UIColor clearColor]];
//    [followingCountLabel setTextColor:[UIColor whiteColor]];
//    [followingCountLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
//    [followingCountLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
//    [followingCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
//    [self.headerView addSubview:followingCountLabel];
//
//    UILabel *userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 176.0f, self.headerView.bounds.size.width, 22.0f)];
//    [userDisplayNameLabel setTextAlignment:UITextAlignmentCenter];
//    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
//    [userDisplayNameLabel setTextColor:[UIColor whiteColor]];
//    [userDisplayNameLabel setShadowColor:[UIColor colorWithWhite:0.0f alpha:0.300f]];
//    [userDisplayNameLabel setShadowOffset:CGSizeMake( 0.0f, -1.0f)];
//    [userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
//    [userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
//    [self.headerView addSubview:userDisplayNameLabel];
//
//    [photoCountLabel setText:@"0 photos"];
//
//    PFQuery *queryPhotoCount = [PFQuery queryWithClassName:@"Photo"];
//    [queryPhotoCount whereKey:kKKPhotoUserKey equalTo:self.user];
//    [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
//    [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        if (!error) {
//            [photoCountLabel setText:[NSString stringWithFormat:@"%d photo%@", number, number==1?@"":@"s"]];
//            [[KKCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
//        }
//    }];
//
//    [followerCountLabel setText:@"0 followers"];
//
//    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kKKActivityClassKey];
//    [queryFollowerCount whereKey:kKKActivityTypeKey equalTo:kKKActivityTypeFollow];
//    [queryFollowerCount whereKey:kKKActivityToUserKey equalTo:self.user];
//    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
//    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        if (!error) {
//            [followerCountLabel setText:[NSString stringWithFormat:@"%d follower%@", number, number==1?@"":@"s"]];
//        }
//    }];
//    
//    NSDictionary *followingDictionary = [[PFUser currentUser] objectForKey:@"following"];
//    [followingCountLabel setText:@"0 following"];
//    if (followingDictionary) {
//        [followingCountLabel setText:[NSString stringWithFormat:@"%d following", [[followingDictionary allValues] count]]];
//    }
//
//    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kKKActivityClassKey];
//    [queryFollowingCount whereKey:kKKActivityTypeKey equalTo:kKKActivityTypeFollow];
//    [queryFollowingCount whereKey:kKKActivityFromUserKey equalTo:self.user];
//    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
//    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        if (!error) {
//            [followingCountLabel setText:[NSString stringWithFormat:@"%d following", number]];
//        }
//    }];
//    
//    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
//        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        [loadingActivityIndicatorView startAnimating];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
//
////     check if the currentUser is following this user
//        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kKKActivityClassKey];
//        [queryIsFollowing whereKey:kKKActivityTypeKey equalTo:kKKActivityTypeFollow];
//        [queryIsFollowing whereKey:kKKActivityToUserKey equalTo:self.user];
//        [queryIsFollowing whereKey:kKKActivityFromUserKey equalTo:[PFUser currentUser]];
//        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
//        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//            if (error && [error code] != kPFErrorCacheMiss) {
//                NSLog(@"Couldn't determine follow relationship: %@", error);
//                self.navigationItem.rightBarButtonItem = nil;
//            } else {
//                if (number == 0) {
//                    [self configureFollowButton];
//                } else {
//                    [self configureUnfollowButton];
//                }
//            }
//        }];
//    }
    
    [self configureLogoutButton];
}

#pragma mark - Slime Refresh delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    NSLog(@"%s", __FUNCTION__);
    [slimeRefreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //    NSLog(@"%s", __FUNCTION__);
    [slimeRefreshView scrollViewDidEndDraging];
}

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView {
    //    NSLog(@"%s", __FUNCTION__);
    
    [self refreshTable:nil];
    
}

- (void)refreshTable:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    [slimeRefreshView performSelector:@selector(endRefresh)
                           withObject:nil afterDelay:0.0
                              inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

#pragma mark - KKSideScrollToolBarViewControllerDelegate methods
-(void)didTouchToolbarItemAtIndex:(NSInteger)index {
//    NSLog(@"%s", __FUNCTION__);
    switch (index) {
        case KKMyAccountHeaderToolItemKollections:
            NSLog(@"Kollections touched");
            break;
        case KKMyAccountHeaderToolItemSubmissions:
            NSLog(@"Submissions touched");
            break;
        case KKMyAccountHeaderToolItemFavorites:
            NSLog(@"Favorites touched");
            break;
        case KKMyAccountHeaderToolItemFollowers:
            NSLog(@"Followers touched");
            break;
        case KKMyAccountHeaderToolItemFollowing:
            NSLog(@"Following touched");
            break;
        case KKMyAccountHeaderToolItemAchievements:
            NSLog(@"Achievements touched");
            break;
        case KKMyAccountHeaderToolItemStore:
            NSLog(@"Store touched");
            break;
        default:
            break;
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    self.tableView.tableHeaderView = self.headerView;
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.className];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kKKPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kKKPhotoUserKey];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    KKLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[KKLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - ()
- (void)profilePhotoButtonAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"profilePhotoCaptureButtonAction" object:sender];
}

- (void)followButtonAction:(id)sender {
//    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    [loadingActivityIndicatorView startAnimating];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
//    
//    [self configureUnfollowButton];
//    
//    [KKUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            [self configureFollowButton];
//        }
//    }];
}

- (void)unfollowButtonAction:(id)sender {
//    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    [loadingActivityIndicatorView startAnimating];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
//    
//    [self configureFollowButton];
//    
//    [KKUtility unfollowUserEventually:self.user];
}

- (void)logoutButtonAction:(id)sender {
    [(KKAppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
}

- (void)backButtonAction:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureFollowButton {
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonAction:)];
//    [[KKCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowButtonAction:)];
//    [[KKCache sharedCache] setFollowStatus:YES user:self.user];
}

//the logout button may/may not be kept in this position; temporarily set here for testing purposes 04Jan2013
- (void)configureLogoutButton {
    //add button to view
    self.logoutButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame andTitle:@"Logout"];
    [self.logoutButton addTarget:self action:@selector(logoutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.logoutButton];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonAction:)];
}

@end