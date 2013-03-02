//
//  KKPhotoDetailsViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKPhotoDetailsViewController.h"
#import "KKToolbarButton.h"
#import "KKAppDelegate.h"
#import "DMLazyScrollView.h"


@interface KKPhotoDetailsViewController () <DMLazyScrollViewDelegate> {
    NSMutableArray *photoViewControllerArray;
}

@property (nonatomic, strong) DMLazyScrollView *scrollView;
@property (nonatomic, strong) KKToolbarButton *backButton;
@property (nonatomic, strong) KKToolbarButton *actionButton;
@end

@implementation KKPhotoDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
    //add toolbar buttons
    self.navigationItem.hidesBackButton = YES;//hide default back button as it's not styled like I want
    [self configureBackButton];//add our custom back button
    
    //we could potentially pass in an array of 1 or more photos or a single photo object
    //we need to determine that first, and then we'll load our photo view based on that
    [self determineHowToLoadPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)dealloc {
    //remove observers
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    self.backButton.hidden = NO;//this is hidden if we navigate away
    self.actionButton.hidden = NO;//this is hidden if we navigate away
}

- (void)viewWillDisappear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear:animated];
    self.backButton.hidden = YES;
    self.actionButton.hidden = YES;
}

#pragma mark - Custom Methods
- (void)determineHowToLoadPhotos {
    //determine if we passed in a array of photos (this happens when we click on a photo contained in a kollection's collectionview photo bar
    //if not, check if we passed in a single photo object, which could happen from a feed view or elsewhere
    if (self.photosArray && [self.photosArray count] > 1) {
        //we passed in an array of photos so add our lazy, paging scrollview
        [self configureLazyScrollView];
    } else {
        //check if we passed in a single photo object
        if (self.photo) {
            //if so, we'll just add our photo details tableview directly to self.view, skipping the any scrollview addition
            [self configureTableViewDirectlyForPhoto:self.photo];
        } else if ([self.photosArray count] == 1) {//we passed in a single object array
            PFObject *photo = (PFObject*)[self.photosArray objectAtIndex:0];//should always be at 0
            self.photo = photo;
            [self configureTableViewDirectlyForPhoto:self.photo];
        }
    }
}

- (void)configureTableViewDirectlyForPhoto:(PFObject*)photo {
//    NSLog(@"%s", __FUNCTION__);
    //prepare the lazy scroll view's layout
    //need our app delegate tabbar's height
    KKAppDelegate *appDelegate = (KKAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //from bottom of nav bar to top of tab bar
    CGRect visibleFrame = CGRectMake(0,
                                     0,
                                     appDelegate.tabBarController.tabBar.frame.size.width,
                                     appDelegate.tabBarController.tabBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);//need to add this in b/c we're in different coordinate sets
    
    //now add our table view
    KKPhotoDetailsTableViewController *tableView = [[KKPhotoDetailsTableViewController alloc] initWithPhoto:self.photo];
    tableView.delegate = self;
    tableView.view.frame = visibleFrame;
    tableView.tableView.bounds = visibleFrame;
    [self.view addSubview:tableView.view];
    
    //knightka only show the action button if user is the owner of the image
    //TODO: change this later once we add additional action menu options beyond just deleting a photo, i.e.
    //saving a photo, posting to facebook, instagram, emailing, texting, etc.
    if ([[[self.photo objectForKey:kKKPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [self configureActionButton];//add our custom action button
    }
}

- (void)configureLazyScrollView {
//    NSLog(@"%s", __FUNCTION__);
    // get page count from number of photos in kollection
    NSUInteger numberOfPages;
    
    if (self.photosArray && [self.photosArray count]) {
        numberOfPages = [self.photosArray count];
    } else {
        numberOfPages = 1;//we have only one photo to show
    }
    
    photoViewControllerArray = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
    for (NSUInteger k = 0; k < numberOfPages; ++k) {
        [photoViewControllerArray addObject:[NSNull null]];
    }
    
    //prepare the lazy scroll view's layout
    //need our app delegate tabbar's height
    KKAppDelegate *appDelegate = (KKAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //from bottom of nav bar to top of tab bar
    CGRect visibleFrame = CGRectMake(0,
                                     0,
                                     appDelegate.tabBarController.tabBar.frame.size.width,
                                     appDelegate.tabBarController.tabBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);//need to add this in b/c we're in different coordinate sets
    
    self.scrollView = [[DMLazyScrollView alloc] initWithFrame:visibleFrame];
    self.scrollView.controlDelegate = self;
    
    //knightka workaround to alleviate "capturing self strongly within this block likely to cause retain cyle" error
    __weak KKPhotoDetailsViewController *weakSelf = self;
    self.scrollView.dataSource = ^(NSUInteger index) {
        return [weakSelf controllerAtIndex:index];
    };
    
    self.scrollView.numberOfPages = numberOfPages;
    [self.view addSubview:self.scrollView];
}

- (KKPhotoDetailsTableViewController *)controllerAtIndex:(NSInteger)index {
//    NSLog(@"%s", __FUNCTION__);
    if (index > photoViewControllerArray.count || index < 0) return nil;
    
    id res = [photoViewControllerArray objectAtIndex:index];
    
    PFObject *photoToLoad = (PFObject*)[self.photosArray objectAtIndex:index];
    self.photo = photoToLoad;
    
    //knightka only show the action button if user is the owner of the image
    //TODO: change this later once we add additional action menu options beyond just deleting a photo, i.e.
    //saving a photo, posting to facebook, instagram, emailing, texting, etc.
    if ([[[self.photo objectForKey:kKKPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [self configureActionButton];//add our custom action button
    }
    
    //if we haven't loaded the photo, alloc a new photo details view, which will load it
    if (res == [NSNull null]) {
        KKPhotoDetailsTableViewController *tableView = [[KKPhotoDetailsTableViewController alloc] initWithPhoto:self.photo];
        tableView.delegate = self;
        tableView.view.frame = self.scrollView.frame;
        tableView.tableView.bounds = self.scrollView.bounds;
        [self.scrollView addSubview:tableView.view];
        [photoViewControllerArray replaceObjectAtIndex:index withObject:tableView];
        
        return tableView;
    }
    
    //else, we've already loaded the photo so just return it
    return res;
}

//our custom back button
- (void)configureBackButton {
//    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.backButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Cancel"];
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.backButton];
}

- (void)backButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureActionButton {
    //create a custom action button
    if(!self.actionButton) {
        self.actionButton = [[KKToolbarButton alloc] initAsActionButtonWithFrame:kKKBarButtonItemRightFrame];
        [self.actionButton addTarget:self action:@selector(actionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:self.actionButton];
    } else {
        self.backButton.hidden = NO;//might be hidden from viewWillDisappear
    }
}

- (void)actionButtonAction:(id)sender {
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
    [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
    [sheet setDestructiveButtonWithTitle:@"Delete Photo" block:^ {
        [self showDeleteConfirmationActionSheet:nil];
    }];
    
    [sheet showInView:self.view];
}

- (void)showDeleteConfirmationActionSheet:(id)sender {
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@"Are you sure you want to delete this photo?"];
    [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
    [sheet setDestructiveButtonWithTitle:@"Yes, delete photo" block:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KKPhotoDetailsTableViewControllerUserDeletedPhotoNotification object:[self.photo objectId]];
        
        // Delete all activites related to this photo
        PFQuery *query = [PFQuery queryWithClassName:kKKActivityClassKey];
        [query whereKey:kKKActivityPhotoKey equalTo:self.photo];
        [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
            if (!error) {
                for (PFObject *activity in activities) {
                    [activity deleteEventually];
                }
            }
            
            // Delete photo
            [self.photo deleteEventually];
        }];
        //TODO: just pop to another photo if we're looking at one of our kollections, otherwise do pop back as normal
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [sheet showInView:self.view];
}

@end
