//
//  KKKollectionTableViewController.m
//  Kollections
//
//  Created by Kerry Knight
//

#import "KKKollectionTableViewController.h"
#import "KKEditKollectionViewController.h"
#import "KKPhotoDetailsViewController.h"
#import "KKPhotoCell.h"
#import "KKUtility.h"
#import "KKLoadMoreCell.h"
#import "KKToolbarButton.h"
#import "UITableView+ZGParallelView.h"

@interface KKKollectionTableViewController () {
    BOOL objectsAreLoaded;
    NSMutableArray *kollectionPhotos;
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) KKToolbarButton *editButton;
@property (nonatomic, strong) KKToolbarButton *backButton;
@property (nonatomic, strong) PFObject *kollection;

@property (strong, nonatomic) UIScrollView *headerScrollView;
@property (strong, nonatomic) UIPageControl *headerPageControl;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *avatar;
@end

@implementation KKKollectionTableViewController

#pragma mark - Initialization
- (id)initWithKollection:(PFObject *)kollection {
//    NSLog(@"%s", __FUNCTION__);
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        self.kollection = kollection;
        
        // The className to query on
        self.className = kKKPhotoClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO; //i don't like their default style; manually adding slime refresh
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;//[self.subjectTitles count];
        
        self.shouldReloadOnAppear = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; // PFQueryTableViewController reads this in viewDidLoad -- would prefer to throw this in init, but didn't work
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    //initialize all our local arrays
    kollectionPhotos = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 200.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]];
    UIImageView *imageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"demo1.png"]];
    [self.headerView addSubview:imageView];
    
    //hide default back button as it's not styled like I want
    self.navigationItem.hidesBackButton = YES;
    //set up our toolbar buttons
    [self configureBackButton];
    [self configureEditButton];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    self.backButton.hidden = NO;//this is hidden if we navigate away
    self.editButton.hidden = NO;//this is hidden if we navigate away
}

- (void)viewWillDisappear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear:animated];
    self.backButton.hidden = YES;
    self.editButton.hidden = YES;
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
    
    //don't show anything until objects are loaded
    if (!objectsAreLoaded) {
        return 0;
    }
    
//    NSInteger sections = [self.subjectTitles count];
//    return sections;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);
    return 3;//1 for top row header w/label, 1 for main content view and 1 for bottom row graphic
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s\n", __FUNCTION__);
    
    //don't show anything until objects are loaded
    if (!objectsAreLoaded) {
        return 0.0f;
    } else {
        NSInteger sectionRows = 3;
        NSInteger row = [indexPath row];
        
        if (row == 0 && row == sectionRows - 1) {
            //single row; will this ever happen?
            return 0;
        }
        else if (row == 0) {
            //top row
            return kDisplayTableHeaderHeight;
        }
        else if (row == sectionRows - 1) {
            //bottom row
            return kDisplayTableFooterHeight;
        }
        else {
            //middle row
            return kDisplayTableContentRowHeight;
        }
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
- (void)objectsDidLoad:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    [super objectsDidLoad:error];
    
    //add the parallax effect to the table with out cover photo view
    [self.tableView addParallelViewWithUIView:self.headerView withDisplayRadio:0.4 cutOffAtMax:YES];
    
    if (!error) {
        //load table rows
        objectsAreLoaded = YES;
        if ([self.view viewWithTag:999]) [[self.view viewWithTag:999] removeFromSuperview];
        
    } else {
        //error loading items
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 230, self.tableView.frame.size.width, 45)];
        errorLabel.textAlignment = UITextAlignmentCenter;
        errorLabel.textColor = kGray6;
        errorLabel.backgroundColor = [UIColor clearColor];
        errorLabel.tag = 999;
        errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
        errorLabel.numberOfLines = 2;
        errorLabel.text = @"An error occurred loading your\nprofile details. Please try again.";
        [self.view addSubview:errorLabel];
    }
}

- (PFQuery *)queryForTable {
    NSLog(@"%s", __FUNCTION__);
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

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __FUNCTION__);
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
//    NSLog(@"%s", __FUNCTION__);
    NSString *CellIdentifier = [[NSString alloc] init];
    
    if (indexPath.row == 1) {
        //middle row where our kollections bar is housed
        //switch statement to set different cell identifiers
        //i had to do this roundabout hackish way b/c i couldn't figure out a good way to
        //differentiate the kollection bars from one another without having different collectionView
        //subclasses for each section, i.e. when I click on a collection
        //view item, i could tell what index it was, but not what type of kollection;
        //i'll also use this to help splitting up PFQueries, since i plan to use 1 query for the
        //kollections I own and 1 query for the kollections i'm subscribed to
        //this gets set to one of the kollectionBar's properties
        switch (indexPath.section) {
            case 0:
                CellIdentifier = @"0";//so we can convert to integer for a switch statement on KKKollectionsBarViewController
                break;
            case 1:
                CellIdentifier = @"1";//so we can convert to integer for a switch statement on KKKollectionsBarViewController
                break;
            case 2:
                CellIdentifier = @"2";//so we can convert to integer for a switch statement on KKKollectionsBarViewController
                break;
            case 3:
                CellIdentifier = @"3";//so we can convert to integer for a switch statement on KKKollectionsBarViewController
                break;
            default:
                CellIdentifier = @"Cell";
                break;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [self tableViewCellWithReuseIdentifier:CellIdentifier forIndexPath:(NSIndexPath *)indexPath];
	}
	
	// configureCell:cell forIndexPath: sets the text and image for the cell -- the method is factored out as it's also called during minuted-based updates.
	[self configureCell:cell forIndexPath:indexPath];
	return cell;
}

//tags
#define kHEADERLABELTAG     1000
#define kADDNEWBUTTONTAG    1001
#define kKOLLECTIONSBARTAG  1002

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
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
    
//    //add the kollection uicollectionview
//    self.kollectionsBar = [[KKKollectionsBarViewController alloc] init];
//    self.kollectionsBar.delegate = self;
//    self.kollectionsBar.kollections = self.kollectionPhotos;
//    self.kollectionsBar.identifier = identifier;//cell's identifier used to determine kollection's type
//    [self addChildViewController:self.kollectionsBar];
//    self.kollectionsBar.view.tag = kKOLLECTIONSBARTAG;
//    [cell.contentView addSubview:self.kollectionsBar.view];
//    [self.kollectionsBar didMoveToParentViewController:self];
//    self.kollectionsBar.view.hidden = YES;
    
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s %@", __FUNCTION__, indexPath);
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
//        headerLabel.text = self.subjectTitles[indexPath.section];//set the header title text
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
        kollectionView.frame = CGRectMake(kDisplayTableCellContentX, cell.contentView.frame.origin.y, kDisplayTableCellContentWidth, [self tableView:self.tableView heightForRowAtIndexPath:indexPath]);
        [kollectionView setNeedsDisplay];
        
    }
    
    [cell.contentView setBackgroundColor:rowBackground];
}

#pragma mark - KKEditKollectionViewControllerDelegate methods
- (void)editKollectionViewControllerDidEditKollection:(PFObject*)kollection atIndex:(NSUInteger)index {
    NSLog(@"%s", __FUNCTION__);
    self.kollection = kollection;
    
    //    [self loadObjects];
}

#pragma mark - Custom Methods
- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
//    NSLog(@"%s", __FUNCTION__);
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = [self.objects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

//our custom back button
- (void)configureBackButton {
    //    NSLog(@"%s", self.self.FUNCTIONself.self.);
    //add button to view
    self.backButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Back"];
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.backButton];
}

- (void)backButtonAction:(id)sender {
    //    NSLog(@"%s", self.self.FUNCTIONself.self.);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)editButtonAction:(id)sender {
    //we want edit our kollection's settings
    KKEditKollectionViewController *editKollectionViewController = [[KKEditKollectionViewController alloc] init];
    editKollectionViewController.delegate = self;
    editKollectionViewController.kollection = self.kollection;
    
    [self.navigationController pushViewController:editKollectionViewController animated:YES];
}

- (void)configureEditButton {
    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.editButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Edit"];
    [self.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.editButton];
    
}

@end