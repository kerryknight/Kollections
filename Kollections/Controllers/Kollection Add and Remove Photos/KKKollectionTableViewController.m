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
#import "UITableView+ZGParallelView.h"

@interface KKKollectionTableViewController () {
    BOOL objectsAreLoaded;
    
}
@property(nonatomic,copy) KKObjectsLoadedCallback callback;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) PFObject *kollection;
@property (nonatomic, strong) NSMutableArray *allKollectionPhotos;
@property (strong, nonatomic) UIScrollView *headerScrollView;
@property (strong, nonatomic) UIPageControl *headerPageControl;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *avatar;
@end

@implementation KKKollectionTableViewController

#define kCOVER_PHOTO_IMAGE_TAG 99

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
        
        //TODO: Be sure to test performance/ui with more than 10 rows/subjects here
        
        self.shouldReloadOnAppear = YES;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
    [self loadCoverPhoto:self];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; // PFQueryTableViewController reads this in viewDidLoad -- would prefer to throw this in init, but didn't work
    self.tableView.showsVerticalScrollIndicator = NO;
    
    //add the parallax effect to the table with our cover photo view
    [self.tableView addParallelViewWithUIView:self.headerView withDisplayRatio:0.4 cutOffAtMax:YES];
    
    [super viewDidLoad];
}

- (void)loadCoverPhoto:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 200.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]];
    
    PFImageView *imageView  = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
    imageView.alpha = 0.0f;
    imageView.tag = kCOVER_PHOTO_IMAGE_TAG;
    imageView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 320.0f);
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.headerView addSubview:imageView];
    
    PFFile *imageFile = [self.kollection objectForKey:kKKKollectionCoverPhotoKey];
    if (imageFile) {
        
        [(PFImageView*)[self.headerView viewWithTag:kCOVER_PHOTO_IMAGE_TAG] setFile:imageFile];
        [(PFImageView*)[self.headerView viewWithTag:kCOVER_PHOTO_IMAGE_TAG] loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.200f animations:^{
                    [self.headerView viewWithTag:kCOVER_PHOTO_IMAGE_TAG].alpha = 1.0f;//load the photo into the imageview
                }];
            }
        }];
    }
}

- (void)reloadCoverPhoto {
    PFFile *imageFile = [self.kollection objectForKey:kKKKollectionCoverPhotoKey];
    if (imageFile) {
        
        [(PFImageView*)[self.headerView viewWithTag:kCOVER_PHOTO_IMAGE_TAG] setFile:imageFile];
        [(PFImageView*)[self.headerView viewWithTag:kCOVER_PHOTO_IMAGE_TAG] loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.200f animations:^{
                    [self.headerView viewWithTag:kCOVER_PHOTO_IMAGE_TAG].alpha = 1.0f;//load the photo into the imageview
                }];
            }
        }];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSLog(@"%s", __FUNCTION__);
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
//        [self loadObjects];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSLog(@"%s", __FUNCTION__);
    
    //don't show anything until objects are loaded
    //if objects are loaded but we don't have any subjects, just show 1 general section
    if (!objectsAreLoaded || ![self.subjectList count]) {
        return 1;
    }
    
    NSInteger sections = [self.subjectList count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);
    
    //don't show anything until objects are loaded
    if (!objectsAreLoaded) {
        return 0;
    }
    
    return 3;//1 for top row header w/label, 1 for main content view and 1 for bottom row graphic
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s\n", __FUNCTION__);
    
    //don't show anything until objects are loaded
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
        return 124.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - PFQueryTableViewController
- (void)objectsDidLoad:(NSError *)error {
//    NSLog(@"%s", __FUNCTION__);
    [super objectsDidLoad:error];
    
    if (!error) {
        if (!self.isNetworkBusy) {
            //load table rows
            self.subjectList = [self.objects mutableCopy];
            
            //tell our sublcass to update it's subject list in case we need to edit the kollection
            [self.delegate kollectionTableViewControllerDidLoadSubjects:[NSArray arrayWithArray:self.subjectList]];
            
            self.shouldReloadOnAppear = NO;
            //once we have our subjects, query Parse for all photos in our kollection
            //once we have those, we'll be able to separate them into our collection views by their subject id pointers
            PFQuery *photoQuery = [PFQuery queryWithClassName:kKKPhotoClassKey];
            [photoQuery whereKey:kKKPhotoKollectionKey equalTo:self.kollection];
            photoQuery.cachePolicy = kPFCachePolicyNetworkElseCache;//always hit the network too
            
            self.isNetworkBusy = YES;
            [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error && [objects count]) {
                    //populate our main photo array with all our kollection's photos
                    self.allKollectionPhotos = [objects mutableCopy];
                    //now that we have our subjects and all our photos, group them together and reload our table rows
                    [self createSubjectsWithPhotosArrayWithCompletion:^(NSArray *objects) {
                        if ([objects count]) {
                            
                            self.subjectsWithPhotos = [objects mutableCopy];
                            
                        }
                    }];
                }
                
                //remove network activity indicators
                self.isNetworkBusy = NO;
                if ([self.view viewWithTag:999]) [[self.view viewWithTag:999] removeFromSuperview];//spinner
                
                if (!error) {
                    //regardless of whether we have subjects or not, tell our tableview we've completed loading them
                    //so it can refresh and reload itself, preparing it's rows accordingly
                    objectsAreLoaded = YES;
                    
                    //reload our table in case any data has changed
                    [self.tableView reloadData];
                    //tell the parent view it can show the bottom photos tray bar now
                    [self.delegate animatePhotoBarOn];
                } else {
                    //error loading items
                    [self addErrorLabel];
                }
                
            }];
        }
    } else {
        //error loading items
        [self addErrorLabel];
    }
}

- (void)addErrorLabel {
    //error loading items
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 230, self.tableView.frame.size.width, 45)];
    errorLabel.textAlignment = UITextAlignmentCenter;
    errorLabel.textColor = kGray6;
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.tag = 999;
    errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
    errorLabel.numberOfLines = 2;
    errorLabel.text = @"An error occurred loading this\nkollection. Please try again.";
    [self.view addSubview:errorLabel];
}

- (PFQuery *)queryForTable {
//    NSLog(@"%s", __FUNCTION__);
    
    //query for this kollection's subjects
    PFQuery *subjectQuery = [PFQuery queryWithClassName:kKKSubjectClassKey];
    [subjectQuery whereKey:kKKSubjectKollectionKey equalTo:self.kollection];
    subjectQuery.cachePolicy = kPFCachePolicyNetworkElseCache;//always pull local stuff first then hit network
    [subjectQuery orderByDescending:@"createdAt"];
    
    return subjectQuery;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    
    return nil;
}

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

//tags
#define kHEADERLABELTAG     1000
#define kNOPHOTOSTAG        1001
#define kKOLLECTIONSBARTAG  1002

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
//    NSLog(@"%s", __FUNCTION__);
    
    //set up background image of cell as well as determine when to show/hide label and disclosure
    UIColor *rowBackground;
    
    NSInteger sectionRows = [self.tableView numberOfRowsInSection:[indexPath section]];
    NSInteger row = [indexPath row];
    
    //extract our subject and photos dictionary object from our array
    //there will only be one for each index path row/section
    NSDictionary *subjectDictionary = (NSDictionary*)self.subjectsWithPhotos[indexPath.section];
    NSString *title = @"";
    
    if (subjectDictionary) {
        //we have subjects
        //there should only be 1 for this index path
        for (NSString *key in [subjectDictionary allKeys]) {
            title = key; //we'll use this for setting our photos array too for the collection view
        }
    } else {
        //no subjects so just put the header text to the kollection's title
        title = self.kollection[kKKKollectionTitleKey];
    }
    
    if (row == 0 && row == sectionRows - 1) {
        //single row; will this ever happen?
        
        static NSString *CellIdentifier = @"CellA";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//disable selection
        [cell.contentView setBackgroundColor:rowBackground];
        return cell;
    }
    else if (row == 0) {
        //top row
        static NSString *CellIdentifier = @"CellB";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
            
            //add a header label to it
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 13.0f, cell.contentView.bounds.size.width - 20.0f, 20.0f)];
            headerLabel.tag = kHEADERLABELTAG;
            [cell.contentView addSubview:headerLabel];
            [headerLabel setTextColor:kGray6];
            [headerLabel setShadowColor:kCreme];
            [headerLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
            [headerLabel setFont:[UIFont fontWithName:@"OriyaSangamMN-Bold" size:16]];
            [headerLabel setBackgroundColor:[UIColor clearColor]];
            headerLabel.text = @"";
        }
        
        UILabel *headerLabel = (UILabel*)[cell.contentView viewWithTag:kHEADERLABELTAG];
        headerLabel.text = title;//set the header title text
        
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"headerBG.png"]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//disable selection
        [cell.contentView setBackgroundColor:rowBackground];
        return cell;
        
    }
    else if (row == sectionRows - 1) {
        //bottom row
        
        static NSString *CellIdentifier = @"CellC";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"footerBGNoActions.png"]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//disable selection
        [cell.contentView setBackgroundColor:rowBackground];
        return cell;
    }
    else {
        //middle row
        static NSString *CellIdentifier = @"KKPhotoBarCell";
        
        //add our custom photo bar cell which contains our uicollectionview controller
        KKPhotoBarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[KKPhotoBarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.kb.delegate = self;
        cell.kb.view.tag = (kKOLLECTIONSBARTAG + indexPath.section + 1);
        [self addChildViewController:cell.kb];
        [cell.kb didMoveToParentViewController:self];
        
        //set our photos array
        NSArray *photos = subjectDictionary[title];
        cell.kb.photos = [photos mutableCopy];
        
        //set our row background first so our "no photos" label doesn't show by itself
        rowBackground = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkTableBodyBG.png"]];
        [cell.contentView setBackgroundColor:rowBackground];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//disable selection
        
        if ([photos count]) {
            cell.kb.view.hidden = NO;
            [cell.kb.collectionView reloadData];
            cell.noPhotosLabel.hidden = YES;
        } else {
            cell.kb.view.hidden = YES;
            if (objectsAreLoaded) {
                cell.noPhotosLabel.text = @"No photos submitted for this subject yet.\n\nTouch here or drag and drop from the\nPhotos Drawer below to be the first!";
                cell.noPhotosLabel.hidden = NO;
            }
        }
        
        return cell;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%s", __FUNCTION__);
    [self.delegate kollectionTableViewDidScroll];
}

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier {
	
    //this should only ever get called for the top and bottom blank rows of the table; never content middle rows
    //Create an instance of UITableViewCell and add tagged subviews for the label, imageview and backgrounds
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    //blank out generic stuff
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
	return cell;
}

#pragma mark - KKKollectionsBarViewControllerDelegate methods
- (void)didSelectPhotoBarItemAtIndex:(NSInteger)index{
//    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Custom Methods
- (void)createSubjectsWithPhotosArrayWithCompletion:(KKObjectsLoadedCallback)callback {
//    NSLog(@"%s", __FUNCTION__);
    //create a mutable array of nsdictionaries
    //the keys for each dictionary will be the subject title and the objects will be the array of photos for each subject
    NSMutableArray *subjectsAndPhotosList = [[NSMutableArray alloc] initWithCapacity:0];
    
    //enumerate through our subject list; we'll make our subjects the keys for each dictionary in the array
    //check if we have subjects first; if we don't just use the kollection's title in the subject's place
    
    if ([self.subjectList count]) {
        //we have subjects
        for (PFObject *subject in self.subjectList) {
            NSString *subjectTitle = subject[kKKSubjectTitleKey];
            NSString *subjectID = subject.objectId;
            
            //this array will keep each subjects photos; we'll put it in our final NSDictionary for each subject
            NSMutableArray *subjectPhotos = [[NSMutableArray alloc] initWithCapacity:0];
            //for each subject in our list, pull out all the photos from our photo list that have a subject pointer matching that subject
            for (PFObject *photo in self.allKollectionPhotos) {
                PFObject *photoSubject = photo[kKKPhotoSubjectKey];
                NSString *photoSubjectID = photoSubject.objectId;
                
                if ([photoSubjectID isEqualToString:subjectID]) {
                    //our IDs match add the photo to our photos array
                    [subjectPhotos addObject:photo];
                }
            }
            
            //once we've gone through all the photos, create an NSDictionary with the subject title and the photos
            NSDictionary *subjectWithPhotos = @{subjectTitle:subjectPhotos};
            
            //add it to our full array
            [subjectsAndPhotosList addObject:subjectWithPhotos];
        }
    } 
    
    callback(subjectsAndPhotosList);
}

- (void) reloadCollectionViewTableRows {
    //create index paths for each of our photo collection views; these are always on row 1 of each section
    NSMutableArray *indexPathArray = [[NSMutableArray alloc] initWithCapacity:[self.subjectsWithPhotos count]];
    for (int i = 0; i < [self.subjectsWithPhotos count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:i];
        [indexPathArray addObject:indexPath];
    }
    
    //reload each collection view row instead of whole table using our created array
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithArray:indexPathArray] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end