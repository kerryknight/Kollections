//
//  KKPhotoDetailsTableViewController.m
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKPhotoDetailsTableViewController.h"
#import "KKBaseTextCell.h"
#import "KKActivityCell.h"
#import "KKPhotoDetailsFooterView.h"
#import "KKConstants.h"
#import "KKAccountViewController.h"
#import "KKLoadMoreCell.h"
#import "KKUtility.h"
#import "MBProgressHUD.h"
#import "SRSlimeView.h"

@interface KKPhotoDetailsTableViewController () {
    SRRefreshView *slimeRefreshView;
}

@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) KKPhotoDetailsHeaderView *headerView;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@end

static const CGFloat kKKCellInsetWidth = 20.0f;

@implementation KKPhotoDetailsTableViewController

@synthesize commentTextField;
@synthesize headerView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KKUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
}

- (id)initWithPhoto:(PFObject *)aPhoto {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.photo = aPhoto;

        // Set query table view properties
        self.className = kKKActivityClassKey;
        self.objectsPerPage = 10;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        self.likersQueryInProgress = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [super viewDidLoad];
    
    // Set table view properties
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
    // Set table header
    self.headerView = [[KKPhotoDetailsHeaderView alloc] initWithFrame:[KKPhotoDetailsHeaderView rectForView] photo:self.photo];
    [self.headerView setDelegate:self];
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Set table footer
    KKPhotoDetailsFooterView *footerView = [[KKPhotoDetailsFooterView alloc] initWithFrame:[KKPhotoDetailsFooterView rectForView]];
    commentTextField = footerView.commentField;
    [commentTextField setDelegate:self];
    self.tableView.tableFooterView = footerView;
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];     
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedPhoto:) name:KKUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:self.photo];
    
    //insert pull to refresh slime view
    slimeRefreshView = [[SRRefreshView alloc] init];
    slimeRefreshView.delegate = self;
    slimeRefreshView.upInset = 0;
    slimeRefreshView.slimeMissWhenGoingBack = YES;
    slimeRefreshView.slime.bodyColor = kMint3;
    [self.tableView addSubview:slimeRefreshView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this photo
    BOOL hasCachedLikers = [[KKCache sharedCache] attributesForPhoto:self.photo] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        
        BOOL hasActivityImage = NO;
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if (object) {
            if ([[object objectForKey:kKKActivityTypeKey] isEqualToString:kKKActivityTypeFollow] || [[object objectForKey:kKKActivityTypeKey] isEqualToString:kKKActivityTypeJoined]) {
                hasActivityImage = NO;
            } else {
                hasActivityImage = YES;
            }
            
            NSString *commentString = [[self.objects objectAtIndex:indexPath.row] objectForKey:kKKActivityContentKey];
            
            PFUser *commentAuthor = (PFUser *)[object objectForKey:kKKActivityFromUserKey];
            
            NSString *nameString = @"";
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:kKKUserDisplayNameKey];
            }
            
            return [KKActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kKKCellInsetWidth];
        }
    }
    
    // The pagination row
    return 44.0f;
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    [query whereKey:kKKActivityPhotoKey equalTo:self.photo];
    [query includeKey:kKKActivityFromUserKey];
    [query whereKey:kKKActivityTypeKey equalTo:kKKActivityTypeComment];
    [query orderByAscending:@"createdAt"]; 

    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    [self.headerView reloadLikeBar];
    [self loadLikers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"CommentCell";

    // Try to dequeue a cell and create one if necessary
    KKBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[KKBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setCellInsetWidth:kKKCellInsetWidth];
        [cell setDelegate:self];
    }
    [cell setUser:[object objectForKey:kKKActivityFromUserKey]];
    [cell setContentText:[object objectForKey:kKKActivityContentKey]];
    [cell setDate:[object createdAt]];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    KKLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[KKLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kKKCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Trim the comment text
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedComment.length != 0 && [self.photo objectForKey:kKKPhotoUserKey]) {
        // Create the comment activity object
        PFObject *comment = [PFObject objectWithClassName:kKKActivityClassKey];
        [comment setValue:trimmedComment forKey:kKKActivityContentKey]; // Set comment text
        [comment setValue:[self.photo objectForKey:kKKPhotoUserKey] forKey:kKKActivityToUserKey]; // Set toUser
        [comment setValue:[PFUser currentUser] forKey:kKKActivityFromUserKey]; // Set fromUser
        [comment setValue:kKKActivityTypeComment forKey:kKKActivityTypeKey];
        [comment setValue:self.photo forKey:kKKActivityPhotoKey];
        
        // Set the proper ACLs
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kKKPhotoUserKey]];
        comment.ACL = ACL;

        // Assume the save will work and increment the comment count cache
        [[KKCache sharedCache] incrementCommentCountForPhoto:self.photo];
        
        // Show HUD view
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview  animated:YES];
        hud.color = kMint4;
        [hud setDimBackground:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:[NSDictionary dictionaryWithObject:comment forKey:@"comment"] repeats:NO];

        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];// Stop the timer if it's still running
            
            // Check if the photo was deleted by owner
            if (error && [error code] == kPFErrorObjectNotFound) {
                // Undo cache update and alert user
                [[KKCache sharedCache] decrementCommentCountForPhoto:self.photo];
                
                //knightka replaced a regular alert view with our custom subclass
                BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Could not post comment" message:@"This photo was deleted by its owner"];
                [alert setCancelButtonWithTitle:@"OK" block:nil];
                [alert show];
                
                [self.navigationController popViewControllerAnimated:YES];
            } else if (succeeded) {
                // refresh cache
                
                NSMutableSet *channelSet = [NSMutableSet setWithCapacity:self.objects.count];
                
                // set up this push notification to be sent to all commenters, excluding the current user
                for (PFObject *comment in self.objects) {
                    PFUser *author = [comment objectForKey:kKKActivityFromUserKey];
                    NSString *privateChannelName = [author objectForKey:kKKUserPrivateChannelKey];
                    if (privateChannelName && privateChannelName.length != 0 && ![[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                        [channelSet addObject:privateChannelName];
                    }
                }
                
                [channelSet addObject:[[self.photo objectForKey:kKKPhotoUserKey] objectForKey: kKKUserPrivateChannelKey]];

                if (channelSet.count > 0) {
                    NSString *alert = [NSString stringWithFormat:@"%@: %@", [KKUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kKKUserDisplayNameKey]], trimmedComment];
                    
                    // make sure to leave enough space for payload overhead
                    if (alert.length > 100) {
                        alert = [alert substringToIndex:99];
                        alert = [alert stringByAppendingString:@"…"];
                    }
                    
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          alert, kAPNSAlertKey,
                                          kKKPushPayloadPayloadTypeActivityKey, kKKPushPayloadPayloadTypeKey,
                                          kKKPushPayloadActivityCommentKey, kKKPushPayloadActivityTypeKey,
                                          [[PFUser currentUser] objectId], kKKPushPayloadFromUserObjectIdKey,
                                          [self.photo objectId], kKKPushPayloadPhotoObjectIdKey,
                                          @"Increment",kAPNSBadgeKey,
                                          nil];
                    PFPush *push = [[PFPush alloc] init];
                    [push setChannels:[channelSet allObjects]];
                    [push setData:data];
                    [push sendPushInBackground];
                }
            }
            
            // Notify the timeline to update the comment count in the header
            [[NSNotificationCenter defaultCenter] postNotificationName:KKPhotoDetailsTableViewControllerUserCommentedOnPhotoNotification object:self.photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.objects.count + 1] forKey:@"comments"]];
            
            // Remove hud
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            
            // Reload the table to display the new comment
            [self loadObjects];
        }];
    }
    [textField setText:@""];
    return [textField resignFirstResponder];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
}


#pragma mark - KKBaseTextCellDelegate

- (void)cell:(KKBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self shouldPresentAccountViewForUser:aUser];
}


#pragma mark - KKPhotoDetailsHeaderViewDelegate

-(void)photoDetailsHeaderView:(KKPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}


#pragma mark - ()
- (void)handleCommentTimeout:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    
    //knightka replaced a regular alert view with our custom subclass
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"New Comment" message:@"Your comment will be posted next time there is an Internet connection."];
    [alert setCancelButtonWithTitle:@"OK" block:nil];
    [alert show];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    KKAccountViewController *accountViewController = [[KKAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)backButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userLikedOrUnlikedPhoto:(NSNotification *)note {
    [self.headerView reloadLikeBar];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-kbSize.height) animated:YES];
}

- (void)loadLikers {
    if (self.likersQueryInProgress) {
        return;
    }

    self.likersQueryInProgress = YES;
    PFQuery *query = [KKUtility queryForActivitiesOnPhoto:self.photo cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        
        //tell the table to end refresh in case we did it by hand
        [slimeRefreshView performSelector:@selector(endRefresh)
                               withObject:nil afterDelay:0.0
                                  inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        
        if (error) {
            [self.headerView reloadLikeBar];
            return;
        }
        
        NSMutableArray *likers = [NSMutableArray array];
        NSMutableArray *commenters = [NSMutableArray array];
        
        BOOL isLikedByCurrentUser = NO;
        
        for (PFObject *activity in objects) {
            if ([[activity objectForKey:kKKActivityTypeKey] isEqualToString:kKKActivityTypeLike] && [activity objectForKey:kKKActivityFromUserKey]) {
                [likers addObject:[activity objectForKey:kKKActivityFromUserKey]];
            } else if ([[activity objectForKey:kKKActivityTypeKey] isEqualToString:kKKActivityTypeComment] && [activity objectForKey:kKKActivityFromUserKey]) {
                [commenters addObject:[activity objectForKey:kKKActivityFromUserKey]];
            }
            
            if ([[[activity objectForKey:kKKActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                if ([[activity objectForKey:kKKActivityTypeKey] isEqualToString:kKKActivityTypeLike]) {
                    isLikedByCurrentUser = YES;
                }
            }
        }
        
        [[KKCache sharedCache] setAttributesForPhoto:self.photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        [self.headerView reloadLikeBar];
    }];
}

@end
