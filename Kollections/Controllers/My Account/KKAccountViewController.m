//
//  KKAccountViewController.m
//  Kollections
//
//  Created by Héctor Ramos on 5/2/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

//views
#import "KKAccountViewController.h"
#import "KKMyAccountHeaderViewController.h"
#import "KKKollectionTableViewController.h"
//other stuff
#import "KKPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "KKLoadMoreCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SRSlimeView.h"
#import "KKAppDelegate.h"
#import "KKToolbarButton.h"
#import "NSMutableArray+AddOns.h"

@interface KKAccountViewController() {
    SRRefreshView *slimeRefreshView;
}

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) KKMyAccountHeaderViewController *headerViewController;
@property (nonatomic, strong) KKToolbarButton *logoutButton;
@end

@implementation KKAccountViewController
@synthesize user;

#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    self.logoutButton.hidden = NO;//this is hidden if we navigate away
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.logoutButton.hidden = YES;
}

#define kPlaceholderPictureImageViewTag 100
#define kProfilePictureImageViewTag     101
#define kProfilePictureButtonTag        102

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
    if (![PFUser currentUser]) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    
    self.user = [PFUser currentUser];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 175.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
    
    self.headerViewController = [[KKMyAccountHeaderViewController alloc] init];
    [self addChildViewController:self.headerViewController];
    [self.headerView addSubview:self.headerViewController.view];
    [self.headerViewController didMoveToParentViewController:self];
    
    //add the delegates
    self.headerViewController.toolBarViewController.delegate = self;
    self.kollectionsBar.delegate = self;

    //insert pull to refresh slime view
    slimeRefreshView = [[SRRefreshView alloc] init];
    slimeRefreshView.delegate = self;
    slimeRefreshView.upInset = 0;
    slimeRefreshView.slimeMissWhenGoingBack = YES;
    slimeRefreshView.slime.bodyColor = kMint3;
//    slimeRefreshView.slime.skinColor = [UIColor colorWithRed:74.0f/255.0f green:165.0f/255.0f blue:164.0f/255.0f alpha:1.0];
    [self.tableView addSubview:slimeRefreshView];
    
    //add image view to hold the user's profile pic
    PFImageView *profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake(17.0f, 15.0f, 66.0f, 65.0f)];
    profilePictureImageView.tag = kProfilePictureImageViewTag;
    [self.headerViewController.view addSubview:profilePictureImageView];
    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    CALayer *layer = [profilePictureImageView layer];
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 0.0f;
    
    [self loadProfilePhoto:self];
    
    //check if we're logged in with facebook; add a button to allow changing profile picture if we're not
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //no profile photo available so add a button to allow the user to add one on their own
        UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        profileButton.tag = kProfilePictureButtonTag;//tag it so we can reference it if we need to change the down button image
        profileButton.frame = [self.headerViewController.view viewWithTag:kPlaceholderPictureImageViewTag].frame;//tag of the placeholder imageview
        [profileButton setBackgroundImage:[UIImage imageNamed:@"kkHeaderUserPhotoPlaceholderDown.png"] forState:UIControlEventTouchDown];
        [profileButton addTarget:self action:@selector(profilePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerViewController.view addSubview:profileButton];
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
    
    //add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfilePhoto:) name:@"MyAccountViewLoadProfilePhoto" object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MyAccountViewLoadProfilePhoto" object:nil];
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
    
    [self loadObjects];
}

#pragma mark - KKSideScrollToolBarViewControllerDelegate methods
- (void)didTouchToolbarItemAtIndex:(NSInteger)index {
//    NSLog(@"%s", __FUNCTION__);
    self.sectionTitles = [self determineSectionTitles:index];
    
    [self.tableView reloadData];
}

- (NSArray*)determineSectionTitles:(NSInteger)selectedIndex {
    
    NSArray *sections = [NSArray array];
    
    switch (selectedIndex) {
        case KKMyAccountHeaderToolItemKollections:
//            NSLog(@"Kollections touched");
            sections = @[@"My Public Kollections",
                         @"My Private Kollections",
                         @"Subscribed Public Kollections",
                         @"Subscribed Private Kollections"];
            break;
        case KKMyAccountHeaderToolItemSubmissions:
            NSLog(@"Submissions touched");
            sections = @[@"My Submissions"];
            break;
        case KKMyAccountHeaderToolItemFavorites:
            NSLog(@"Favorites touched");
            sections = @[@"Favorites"];
            break;
        case KKMyAccountHeaderToolItemFollowers:
            NSLog(@"Followers touched");
            sections = @[@"Followers"];
            break;
        case KKMyAccountHeaderToolItemFollowing:
            NSLog(@"Following touched");
            sections = @[@"Following"];
            break;
        case KKMyAccountHeaderToolItemAchievements:
            NSLog(@"Achievements touched");
            sections = @[@"Achievements"];
            break;
        case KKMyAccountHeaderToolItemStore:
            NSLog(@"Store touched");
            sections = @[@"Kollections Store"];
            break;
        default:
            break;
    }
    
    return sections;
}

#pragma mark - PFQueryTableViewController
- (void)objectsDidLoad:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
    [super objectsDidLoad:error];
    
    self.tableView.tableHeaderView = self.headerView;
    
    if (!error) {
        //once objects are loaded, separate them into their pertinant arrays
        [self separateReturnedObjectsIntoProperKollectionArrays];
        
        //also tell the UI to update itself
        [self updateKollectionCountLabel];
    }
    
    //tell the table to end refresh in case we did it by hand
    [slimeRefreshView performSelector:@selector(endRefresh)
                           withObject:nil afterDelay:0.0
                              inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    //tell our collection views to reload
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KollectionsBarViewControllerReloadKollectionsData" object:nil];
}

- (PFQuery *)queryForTable {
//    NSLog(@"%s", __FUNCTION__);
    
    /*
     //kak 19Jan2013 //UPDATE, use the compounding technique below to pull in subscribed kollections as well, not just user-created ones
     // Query for the friends the current user is following
     PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kKKActivityClassKey];
     [followingActivitiesQuery whereKey:kKKActivityTypeKey equalTo:kKKActivityTypeFollow];
     [followingActivitiesQuery whereKey:kKKActivityFromUserKey equalTo:[PFUser currentUser]];
     followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
     followingActivitiesQuery.limit = 1000;
     
     // Using the activities from the query above, we find all of the photos taken by
     // the friends the current user is following
     PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.className];
     [photosFromFollowedUsersQuery whereKey:kKKPhotoUserKey matchesKey:kKKActivityToUserKey inQuery:followingActivitiesQuery];
     [photosFromFollowedUsersQuery whereKeyExists:kKKPhotoPictureKey];
     
     // We create a second query for the current user's photos
     PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.className];
     [photosFromCurrentUserQuery whereKey:kKKPhotoUserKey equalTo:[PFUser currentUser]];
     [photosFromCurrentUserQuery whereKeyExists:kKKPhotoPictureKey];
     
     // We create a final compound query that will find all of the photos that were
     // taken by the user's friends or by the user
     PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, photosFromCurrentUserQuery, nil]];
     [query includeKey:kKKPhotoUserKey];
     [query orderByDescending:@"createdAt"];
     
     // If no objects are loaded in memory, we look to the cache first to fill the table
     // and then subsequently do a query against the network.
     //
     // If there is no network connection, we will hit the cache first.
     if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
     }
     */
    
    //Query for the current user's kollections
    PFQuery *kollectionsQuery = [PFQuery queryWithClassName:kKKKollectionClassKey];
    [kollectionsQuery whereKey:kKKKollectionUserKey equalTo:[PFUser currentUser]];
    kollectionsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;//always pull local stuff first then hit network
    
    // create a 2nd query that will have a different cache policy for pull-to-refresh to kick in
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:kollectionsQuery, nil]];
    [query orderByDescending:@"createdAt"];
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
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

#pragma mark - KKKollectionsBarViewControllerDelegate methods
- (void)didSelectKollectionBarItemAtIndex:(NSInteger)index ofKollectionType:(KKKollectionType)type shouldCreateNew:(BOOL)yesOrNo {
    NSLog(@"%s", __FUNCTION__);
    
    //check kollection type first
    if (type == KKKollectionTypeMyPublic || type == KKKollectionTypeMyPrivate) {
        //need to check if we need to load the create new kollection view or navigate to selected kollection
        if (yesOrNo == YES) {
            //we should be a creating or subscribing to a new kollection
            KKCreateKollectionViewController *createKollectionViewController = [[KKCreateKollectionViewController alloc] init];
            createKollectionViewController.delegate = self;
            //set our bool that initializes our segmented control turn to public or private
            if (type == KKKollectionTypeMyPrivate) {
                NSLog(@"create a private kollection");
                createKollectionViewController.shouldInitializeAsPrivate = YES;
            } else {
                NSLog(@"create a public kollection");
                createKollectionViewController.shouldInitializeAsPrivate = NO;
            }
            [self.navigationController pushViewController:createKollectionViewController animated:YES];
        } else {
            //we selected a pre-existing kollection so load that kollection's photos view
            PFObject *kollectionToLoad;
            //determine which array to pull the kollection out of
            if (type == KKKollectionTypeMyPrivate) {
                kollectionToLoad = (PFObject*)[self.myPrivateKollections objectAtIndex:index];
            } else {
                kollectionToLoad = (PFObject*)[self.myPublicKollections objectAtIndex:index];
            }
            
            KKKollectionTableViewController *nextView = [[KKKollectionTableViewController alloc] initWithKollection:kollectionToLoad];
            [self.navigationController pushViewController:nextView animated:YES];
        }
        
    } else {
        //it's a subscribed-to kollection
        NSLog(@"It's a subscribed-to kollection row");
    }
}

#pragma mark - KKCreateKollectionViewControllerDelegate methods
- (void)createKollectionViewControllerDidCreateNewKollection:(PFObject *)kollection {
//    NSLog(@"%s", __FUNCTION__);
    
    if ([kollection[kKKKollectionIsPrivateKey] boolValue] == YES) {
        //it's a private kollection so replace it in the private list
        [self.myPrivateKollections addUniqueObject:kollection atIndex:0];//add it to the beginning
    } else {
        [self.myPublicKollections addUniqueObject:kollection atIndex:0];//add it to the beginning
    }
    
    [self loadObjects];
}

#pragma mark - Custom Methods
- (void)separateReturnedObjectsIntoProperKollectionArrays {
//    NSLog(@"%s", __FUNCTION__);
    //separate my public and private kollections
    //get current user and compare it with the kollection's owner
    PFUser *currentUser = [PFUser currentUser];
    
    //remove objects from all our tables if they're there
    //initialize all our local arrays
    [self.myPublicKollections removeAllObjects];
    [self.myPrivateKollections removeAllObjects];
    [self.subscribedPrivateKollections removeAllObjects];
    [self.subscribedPublicKollections removeAllObjects];
    
    for (PFObject *kollection in self.objects) {
        PFUser *kollectionUser = (PFUser*)kollection[kKKKollectionUserKey];
        //check if it's a kollection owned by the current user
        if ([kollectionUser.objectId isEqualToString:currentUser.objectId]) {
            //kollection is the same user so it's one of my creations
            //now separate the owned kollections into public and private
            if ([kollection[kKKKollectionIsPrivateKey] boolValue] == TRUE) {
                //it's a private kollection
                [self.myPrivateKollections addObject:kollection];
            } else {
                //it's a public kollection
                [self.myPublicKollections addObject:kollection];
            }
        } else {
            NSLog(@"kollection not owned by the current user");
        }
    }
    
    [self.tableView reloadData];
}

- (void)updateKollectionCountLabel {
    if ([self.objects count]) {
       self.headerViewController.kollectionCountLabel.text = [NSString stringWithFormat:@"%i", [self.objects count]]; 
    } else {
        self.headerViewController.kollectionCountLabel.text = @"000";
    }
}

- (void)loadProfilePhoto:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    self.user = [PFUser currentUser];//reset the self.user since we should've updated the currentUser with the new profile pic
    //retrieve the user's profile pic to insert
    PFFile *imageFile = [self.user objectForKey:kKKUserProfilePicMediumKey];
    if (imageFile) {
        [(PFImageView*)[self.headerViewController.view viewWithTag:101] setFile:imageFile];
        [(PFImageView*)[self.headerViewController.view viewWithTag:101] loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.200f animations:^{
                    [self.headerViewController.view viewWithTag:101].alpha = 1.0f;//load the photo into the imageview
                    //also, change the down image of the profile button image so we darken the whole thing and don't show the down placeholder image
                    [(UIButton*)[self.headerViewController.view viewWithTag:kProfilePictureButtonTag] setBackgroundImage:[UIImage imageNamed:@"kkHeaderUserPhotoDown.png"] forState:UIControlEventTouchDown];
                }];
            }
        }];
    }
}

- (void)profilePhotoButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
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
    self.logoutButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Logout"];
    [self.logoutButton addTarget:self action:@selector(logoutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.logoutButton];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonAction:)];
}

@end