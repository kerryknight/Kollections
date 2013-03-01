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

@interface KKPhotoDetailsViewController () {
    
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) KKPhotoDetailsTableViewController *tableView;
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
    
    //need our app delegate tabbar's height
    KKAppDelegate *appDelegate = (KKAppDelegate *)[[UIApplication sharedApplication] delegate];
    //get the space from the bottom of the navigation bar to the top of the tab bar;
    CGRect visibleFrame = CGRectMake(0,
                                     0,
                                     self.navigationController.navigationBar.frame.size.width,
                                     appDelegate.tabBarController.tabBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:visibleFrame];
    [self.scrollView setScrollEnabled:NO]; //up and down scrolling controlled by child tableview
    [self.scrollView setPagingEnabled:YES];//so we can slide left to right
    
    //add our table view
    self.tableView = [[KKPhotoDetailsTableViewController alloc] initWithPhoto:self.photo];
    self.tableView.delegate = self;
    self.tableView.view.frame = self.scrollView.frame;
    self.tableView.tableView.bounds = self.scrollView.bounds;
    
    //size our current view to fit the visible area
    CGRect slideFrame = self.view.frame;
    slideFrame.origin.y -= (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    self.view.frame = slideFrame; //move ourselves down the size of the navigation bar
    
    [self.scrollView addSubview:self.tableView.view];
    [self.view addSubview:self.scrollView];
    
    //add toolbar buttons
    self.navigationItem.hidesBackButton = YES;//hide default back button as it's not styled like I want
    [self configureBackButton];//add our custom back button
    
    //knightka only show the action button if user is the owner of the image
    //TODO: change this later once we add additional action menu options beyond just deleting a photo, i.e.
    //saving a photo, posting to facebook, instagram, emailing, texting, etc.
    if ([[[self.photo objectForKey:kKKPhotoUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        [self configureActionButton];//add our custom action button
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)dealloc {
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)configureActionButton {
    //create a custom action button
    self.actionButton = [[KKToolbarButton alloc] initAsActionButtonWithFrame:kKKBarButtonItemRightFrame];
    [self.actionButton addTarget:self action:@selector(actionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.actionButton];
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
