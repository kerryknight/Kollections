//
//  KKMyAccountSummaryTableViewController.m
//  Kollections
//
//  Created by Kerry Knight
//

#import "KKMyAccountSummaryTableViewController.h"
#import "KKPhotoCell.h"
#import "KKAccountViewController.h"
#import "KKPhotoDetailsViewController.h"
#import "KKUtility.h"
#import "KKLoadMoreCell.h"
#import "KKKollectionsBarViewController.h"

@interface KKMyAccountSummaryTableViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
//@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
//@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;
@end

@implementation KKMyAccountSummaryTableViewController
//@synthesize reusableSectionHeaderViews;
@synthesize shouldReloadOnAppear;
//@synthesize outstandingSectionHeaderQueries;
@synthesize sectionTitles;

#pragma mark - Initialization
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
//        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.className = kKKPhotoClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO; //i don't like their default style; manually adding slime refresh
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
        self.objectsPerPage = [self.sectionTitles count];
        
//        // Improve scrolling performance by reusing UITableView section headers
//        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:4];
        
        self.shouldReloadOnAppear = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; // PFQueryTableViewController reads this in viewDidLoad -- would prefer to throw this in init, but didn't work
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSLog(@"%s", __FUNCTION__);
    NSInteger sections = [self.sectionTitles count];
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);
    return 3;//1 for top row, 1 for repeating bg and 1 for bottom row graphic
}


#pragma mark - UITableViewDelegate

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    KKPlainHeaderView *headerView = [self dequeueReusableSectionHeaderView];
//    
//    if (!headerView) {
//        headerView = [[KKPlainHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 40.0f)];
//        [self.reusableSectionHeaderViews addObject:headerView];
//    }
//    
//    //set the header's title label
//    headerView.headerLabel.text = self.sectionTitles[section];
//    
//    return headerView;
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);
    return 0.0f;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 12.0f)];
//    [footerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"footerBGNoActions.png"]]];
//    return footerView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//
//    return 12.0f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s\n", __FUNCTION__);
    
    NSInteger sectionRows = 3;
    NSInteger row = [indexPath row];
    
    if (row == 0 && row == sectionRows - 1) {
        //single row; will this ever happen?
        return 0;
    }
    else if (row == 0) {
        //top row
        return 40.0f;
    }
    else if (row == sectionRows - 1) {
        //bottom row
        return 10.0f;
    }
    else {
        //middle row
        return 100.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    if (indexPath.section == self.objects.count && self.paginationEnabled) {
//        // Load More Cell
//        [self loadNextPage];
//    }
}


#pragma mark - PFQueryTableViewController
// *this method is not overridden in the KKHomeViewController
- (PFQuery *)queryForTable {
    NSLog(@"%s", __FUNCTION__);
//    if (![PFUser currentUser]) {
//        PFQuery *query = [PFQuery queryWithClassName:self.className];
//        [query setLimit:0];
//        return query;
//    }
//    
//    // Query for the friends the current user is following
//    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kKKActivityClassKey];
//    [followingActivitiesQuery whereKey:kKKActivityTypeKey equalTo:kKKActivityTypeFollow];
//    [followingActivitiesQuery whereKey:kKKActivityFromUserKey equalTo:[PFUser currentUser]];
//    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
//    followingActivitiesQuery.limit = 1000;
//    
//    // Using the activities from the query above, we find all of the photos taken by
//    // the friends the current user is following
//    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.className];
//    [photosFromFollowedUsersQuery whereKey:kKKPhotoUserKey matchesKey:kKKActivityToUserKey inQuery:followingActivitiesQuery];
//    [photosFromFollowedUsersQuery whereKeyExists:kKKPhotoPictureKey];
//
//    // We create a second query for the current user's photos
//    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.className];
//    [photosFromCurrentUserQuery whereKey:kKKPhotoUserKey equalTo:[PFUser currentUser]];
//    [photosFromCurrentUserQuery whereKeyExists:kKKPhotoPictureKey];
//
//    // We create a final compound query that will find all of the photos that were
//    // taken by the user's friends or by the user
//    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, photosFromCurrentUserQuery, nil]];
//    [query includeKey:kKKPhotoUserKey];
//    [query orderByDescending:@"createdAt"];
//
//    // A pull-to-refresh should always trigger a network request.
//    [query setCachePolicy:kPFCachePolicyNetworkOnly];
//
//    // If no objects are loaded in memory, we look to the cache first to fill the table
//    // and then subsequently do a query against the network.
//    //
//    // If there is no network connection, we will hit the cache first.
//    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
//        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
//    }
//
//    /*
//     This query will result in an error if the schema hasn't been set beforehand. While Parse usually handles this automatically, this is not the case for a compound query such as this one. The error thrown is:
//     
//     Error: bad special key: __type
//     
//     To set up your schema, you may post a photo with a caption. This will automatically set up the Photo and Activity classes needed by this query.
//     
//     You may also use the Data Browser at Parse.com to set up your classes in the following manner.
//     
//     Create a User class: "User" (if it does not exist)
//     
//     Create a Custom class: "Activity"
//     - Add a column of type pointer to "User", named "fromUser"
//     - Add a column of type pointer to "User", named "toUser"
//     - Add a string column "type"
//     
//     Create a Custom class: "Photo"
//     - Add a column of type pointer to "User", named "user"
//     
//     You'll notice that these correspond to each of the fields used by the preceding query.
//     */
    
//    return query;

    //KAK remove this below once i get the table set up to work with my graphics and uncomment lines above to properly query
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query setLimit:4];
    return query;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
//    NSLog(@"%s", __FUNCTION__);
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
	}
	
	// configureCell:cell forIndexPath: sets the text and image for the cell -- the method is factored out as it's also called during minuted-based updates.
	[self configureCell:cell forIndexPath:indexPath];
	return cell;
}

//tags
#define kHEADERLABELTAG     1000
#define kADDNEWBUTTONTAG    1001
#define kKOLLECTIONSBARTAG  1002

//sizing
#define kKOLLECTION_X       18.0f
#define kKOLLECTION_WIDTH   284.0f

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier {
//	NSLog(@"%s", __FUNCTION__);
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    //make the cell highlight gray instead of blue
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //add a header label to it
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 13.0f, cell.contentView.bounds.size.width - 20.0f, 20.0f)];
    [cell.contentView addSubview:headerLabel];
    [headerLabel setTextColor:kGray6];
    [headerLabel setShadowColor:kCreme];
    [headerLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
    [headerLabel setFont:[UIFont fontWithName:@"OriyaSangamMN-Bold" size:16]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    headerLabel.tag = kHEADERLABELTAG;
    
    //add the kollection uicollectionview
    self.kollectionsBar = [[KKKollectionsBarViewController alloc] init];
    self.kollectionsBar.delegate = self;
    self.kollectionsBar.kollections = [self.objects mutableCopy];
    [self addChildViewController:self.kollectionsBar];
    self.kollectionsBar.view.tag = kKOLLECTIONSBARTAG;
    [cell.contentView addSubview:self.kollectionsBar.view];
    [self.kollectionsBar didMoveToParentViewController:self];
    self.kollectionsBar.view.hidden = YES;
    
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
    UILabel *headerLabel = (UILabel *)[cell.contentView viewWithTag:kHEADERLABELTAG];
    UIView *kollectionView = (UIView*)[cell.contentView viewWithTag:kKOLLECTIONSBARTAG];
    kollectionView.hidden = YES;//default
    UIColor *rowBackground;
    
    NSInteger sectionRows = [self.tableView numberOfRowsInSection:[indexPath section]];
    NSInteger row = [indexPath row];
    
    if (row == 0 && row == sectionRows - 1) {
        //single row; will this ever happen?
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        headerLabel.text = @"";
    }
    else if (row == 0) {
        //top row
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"headerBG.png"]];
        headerLabel.text = self.sectionTitles[indexPath.section];//set the header title text
    }
    else if (row == sectionRows - 1) {
        //bottom row
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"footerBGNoActions.png"]];
        headerLabel.text = @"";
    }
    else {
        //middle row
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        headerLabel.text = @"";
        //check if we have objects to display in the collection; if not, show the add button
        
        //set the kollection view size to match the cell and unhide it
        kollectionView.hidden = NO;
        kollectionView.frame = CGRectMake(kKOLLECTION_X, cell.contentView.frame.origin.y, kKOLLECTION_WIDTH, [self tableView:self.tableView heightForRowAtIndexPath:indexPath]);
        [kollectionView setNeedsDisplay];
        
//        //this is kinda hackish but I don't wanna redo the entire collection view at this point as a single one instead of multiple instances of the same class
//        //attach a helper method to the cell here that will run when we tap the kollection so that we'll know what table row we touched in order to load correct kollection
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(kollectionItemTapped:)];
//        [kollectionView addGestureRecognizer:tapGesture];
    }
    
    [cell.contentView setBackgroundColor:rowBackground];
}

- (void)kollectionItemTapped:(UITapGestureRecognizer *)gesture {
//    NSLog(@"%s", __FUNCTION__);
    // only when gesture was recognized, not when ended
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // get affected cell
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        
        // get indexPath of cell
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSLog(@"UIGestureRecognizerStateEnded index path = %@", indexPath);
    }
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
//    
//    KKLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
//    if (!cell) {
//        cell = [[KKLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
//        cell.selectionStyle =UITableViewCellSelectionStyleGray;
//        cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark.png"];
//        cell.hideSeparatorBottom = YES;
//        cell.mainView.backgroundColor = [UIColor clearColor];
//    }
//    return cell;
//}

#pragma mark - KKKollectionsBarViewController delegate methods
- (void)didTouchKollectionItemAtIndex:(NSInteger)index {
    //    NSLog(@"%s", __FUNCTION__);
    NSLog(@"index touched = %i", index);
}

#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    [self performSelector:@selector(loadObjects) withObject:nil afterDelay:1.0f];
}

- (void)userDidPublishPhoto:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    NSLog(@"User following changed.");
    self.shouldReloadOnAppear = YES;
}


- (void)didTapOnPhotoAction:(UIButton *)sender {
    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    if (photo) {
        KKPhotoDetailsViewController *photoDetailsVC = [[KKPhotoDetailsViewController alloc] initWithPhoto:photo];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

@end