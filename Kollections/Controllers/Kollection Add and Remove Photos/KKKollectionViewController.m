//
//  KKKollectionViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/30/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionViewController.h"
#import "KKToolbarButton.h"
#import "ELCAlbumPickerController.h"

#define kPHOTO_TRAY_CLOSED_Y self.view.frame.size.height - (self.tabBarController.tabBar.frame.size.height + 91) //91 sets it just right based on current size at 44px high
#define kPHOTO_TRAY_OPEN_Y kPHOTO_TRAY_CLOSED_Y - 140
#define kPHOTO_TRAY_HEIGHT 307

@interface KKKollectionViewController () {
    
}
@property (nonatomic, strong) KKKollectionTableViewController *tableView;
@property (nonatomic, strong) ELCImagePickerController *photosTrayPicker;
@property (nonatomic, strong) ELCAlbumPickerController *photoAlbumPickerController;
@property (nonatomic, strong) KKToolbarButton *editButton;
@property (nonatomic, strong) KKToolbarButton *backButton;
@property (nonatomic, strong) NSMutableArray *subjectList;
@end

@implementation KKKollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    
    self.tableView = [[KKKollectionTableViewController alloc] initWithKollection:self.kollection];
    self.tableView.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - 46);//allow a little inset padding
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView.view];
    
    //hide default back button as it's not styled like I want
    self.navigationItem.hidesBackButton = YES;
    //set up our toolbar buttons
    [self configureBackButton];
    [self configureEditButton];
    
    //set up our photos tray
    [self configurePhotoTray];
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

#pragma mark - KKEditKollectionViewControllerDelegate methods
- (void)editKollectionViewControllerDidEditKollectionWithInfo:(NSDictionary *)userInfo atIndex:(NSUInteger)index {
    //    NSLog(@"%s", __FUNCTION__);
    self.kollection = (PFObject*)userInfo[@"kollection"];
    self.subjectList = (NSMutableArray*)userInfo[@"subjects"];
    self.tableView.subjectList = self.subjectList;
    
    if (!self.tableView.isNetworkBusy) {
        self.tableView.isNetworkBusy = YES;
        //refresh our object and reload our table once complete
        [self.kollection refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                NSLog(@"kollection subjects refreshed");
                self.kollection = object;
                self.tableView.isNetworkBusy = NO;
                
                //now that we have our subjects and all our photos, group them together and reload our table rows
                [self.tableView createSubjectsWithPhotosArrayWithCompletion:^(NSArray *objects) {
                    if (objects) {
                        self.tableView.subjectsWithPhotos = [objects mutableCopy];
                        
                        //reload our table in case any data has changed
                        [self.tableView.tableView reloadData];
                    }
                }];
            }
            
        }];
    }
    
    //reload cover photo
    [self.tableView reloadCoverPhoto];
}

#pragma mark - KKKollectionTableViewControllerDelegate
- (void) kollectionTableViewControllerDidLoadSubjects:(NSArray*)subjects {
    self.subjectList = [subjects mutableCopy];
}

#pragma mark ELCImagePickerControllerDelegate Methods
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
	NSLog(@"%s", __FUNCTION__);
//	[self dismissModalViewControllerAnimated:YES];
}

- (void)configurePhotoTray {
    //add view to hold our photo tray header view; we're going to use this to cover up the navigation controller
    //that goes with the image picker controllers we're about to add; this is easier to do than removing
    //the navigation controller from those controllers and then trying to replicated that functionality on our own
    UIView *photosTrayHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    photosTrayHeaderView.frame = CGRectMake(0,
                                      kPHOTO_TRAY_OPEN_Y,
                                      self.view.bounds.size.width,
                                      51);
    photosTrayHeaderView.backgroundColor = [UIColor clearColor];
    
    //add our tray image
    UIImageView *photoTrayHeaderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkPhotoTrayHeader.png"]];
    photoTrayHeaderImage.frame = CGRectMake(-4, 0, 328, 51);
    [photosTrayHeaderView addSubview:photoTrayHeaderImage];
    
    //add a view to hold our tray image background
    UIView *photosTrayView = [[UIView alloc] initWithFrame:CGRectZero];
    photosTrayView.frame = CGRectMake(0,
                                      kPHOTO_TRAY_OPEN_Y,
                                      self.view.bounds.size.width,
                                      kPHOTO_TRAY_HEIGHT);
    photosTrayView.backgroundColor = [UIColor clearColor];
    
    //add our tray image
    UIImageView *photoTrayImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkPhotoTray.png"]];
    photoTrayImage.frame = CGRectMake(-4, 0, 328, kPHOTO_TRAY_HEIGHT);
    [photosTrayView addSubview:photoTrayImage];
    
    //add a container view to hold our picker view controller
    UIView *photosTrayContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    photosTrayContainerView.frame = CGRectMake(0,
                                               2,
                                               self.view.frame.size.width,
                                               kPHOTO_TRAY_HEIGHT - 46);
    photosTrayContainerView.backgroundColor = [UIColor clearColor];
    
    //add the custom image picker to the photo tray
    self.photoAlbumPickerController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
	self.photosTrayPicker = [[ELCImagePickerController alloc] initWithRootViewController:self.photoAlbumPickerController];
    [self.photoAlbumPickerController setParent:self.photosTrayPicker];
    self.photosTrayPicker.delegate = self;
    self.photosTrayPicker.view.frame = CGRectMake(0,
                                                  1,
                                                  photosTrayContainerView.frame.size.width,
                                                  photosTrayContainerView.frame.size.height - 75);//add a little inset
    [self addChildViewController:self.photosTrayPicker];
    [photosTrayContainerView addSubview:self.photosTrayPicker.view];
    [self.photosTrayPicker didMoveToParentViewController:self];
    [photosTrayView addSubview:photosTrayContainerView];
    [self.view addSubview:photosTrayView];
    [self.view addSubview:photosTrayHeaderView];//add on top
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    
}

#pragma mark - Custom Methods
//our custom back button
- (void)configureBackButton {
    //    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.backButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Back"];
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.backButton];
}

- (void)backButtonAction:(id)sender {
    //    NSLog(@"%s", __FUNCTION__);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)editButtonAction:(id)sender {
    //    NSLog(@"%s", __FUNCTION__);
    
    KKEditKollectionViewController *editKollectionViewController = [[KKEditKollectionViewController alloc] init];
    editKollectionViewController.delegate = self;
    editKollectionViewController.kollection = self.kollection;
    editKollectionViewController.subjectsArrayToCompareAgainst = self.subjectList;
    [self.navigationController pushViewController:editKollectionViewController animated:YES];
}

- (void)configureEditButton {
    //    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.editButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Edit"];
    [self.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.editButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
