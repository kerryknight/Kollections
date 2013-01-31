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

#define kPHOTO_TRAY_CLOSED_Y (self.view.frame.size.height - (self.tabBarController.tabBar.frame.size.height + 91)) //91 sets it just right based on current size at 44px high
#define kPHOTO_TRAY_OPEN_Y (kPHOTO_TRAY_CLOSED_Y - 140)
#define kPHOTO_TRAY_HEIGHT 307
#define kPHOTO_TRAY_SUPERVIEW_MIN_Y (kPHOTO_TRAY_OPEN_Y + 243)//332 total
#define kPHOTO_TRAY_SUPERVIEW_MAX_Y (kPHOTO_TRAY_CLOSED_Y + 247)//474 total

@interface KKKollectionViewController () {
    BOOL photoTrayIsFullyOpen;
}
@property (nonatomic, strong) KKKollectionTableViewController *tableView;
@property (nonatomic, strong) ELCImagePickerController *photosTrayPicker;
@property (nonatomic, strong) ELCAlbumPickerController *photoAlbumPickerController;
@property (nonatomic, strong) KKToolbarButton *editButton;
@property (nonatomic, strong) KKToolbarButton *backButton;
@property (nonatomic, strong) NSMutableArray *subjectList;
@property (nonatomic, strong) UIView *photosTrayView;
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
    self.tableView.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - 44);//allow a little inset padding
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
    //the photosTrayView created below will be the top level view before we add everything to self.view
    //add a view to hold our tray image background
    self.photosTrayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.photosTrayView.frame = CGRectMake(0,
                                           kPHOTO_TRAY_CLOSED_Y,
                                           self.view.bounds.size.width,
                                           kPHOTO_TRAY_HEIGHT);
    self.photosTrayView.backgroundColor = [UIColor clearColor];
    self.photosTrayView.contentMode = UIViewContentModeRedraw;
    
    //add our tray image
    UIImageView *photoTrayImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkPhotoTray.png"]];
    photoTrayImage.frame = CGRectMake(-4, 0, 328, kPHOTO_TRAY_HEIGHT);
    [self.photosTrayView addSubview:photoTrayImage];
    
    //add our header that while hold the drag button
    UIView *photosTrayHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    photosTrayHeaderView.frame = CGRectMake(0,
                                      0,
                                      self.view.bounds.size.width,
                                      54);
    photosTrayHeaderView.backgroundColor = [UIColor clearColor];
    
    //create a gradient for a shadow at the top of the tab below the tray button
    //let's add a small gradient to appear to be behind the top of the table view
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 48, 320, 3)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:0.9f] CGColor],
                       (id)[[UIColor clearColor] CGColor], nil]; //clear and kGray6
    [gradientView.layer insertSublayer:gradient atIndex:0];
    [photosTrayHeaderView addSubview:gradientView];
    
    //add our tray image
    UIImageView *photoTrayHeaderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkPhotoTrayHeader.png"]];
    photoTrayHeaderImage.frame = CGRectMake(-4, 0, 328, 51);
    [photosTrayHeaderView addSubview:photoTrayHeaderImage];
    
    //add our drag button 
    UIButton *dragButton = [[UIButton alloc] initWithFrame:CGRectMake(247.0f, 10.0f, 63.0f, 33.0f)];
    [dragButton setBackgroundImage:[UIImage imageNamed:@"kkDragButtonUp.png"] forState:UIControlStateNormal];
    [dragButton setBackgroundImage:[UIImage imageNamed:@"kkDragButtonSelected.png"] forState:UIControlStateHighlighted];
    [dragButton addTarget:self action:@selector(dragButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addGestureRecognizersToDragButton:dragButton];
    [photosTrayHeaderView addSubview:dragButton];
    
    //add a container view to hold our picker view controller
    UIView *photosTrayContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    photosTrayContainerView.frame = CGRectMake(0,
                                               2,
                                               self.view.frame.size.width,
                                               kPHOTO_TRAY_HEIGHT - 46);
    photosTrayContainerView.backgroundColor = [UIColor clearColor];
    
    //add the custom image picker to the photo tray
    self.photoAlbumPickerController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
    self.photoAlbumPickerController.view.backgroundColor = [UIColor clearColor];
	self.photosTrayPicker = [[ELCImagePickerController alloc] initWithRootViewController:self.photoAlbumPickerController];
    self.photoAlbumPickerController.view.backgroundColor = [UIColor clearColor];
    [self.photoAlbumPickerController setParent:self.photosTrayPicker];
    self.photosTrayPicker.delegate = self;
    self.photosTrayPicker.view.frame = CGRectMake(0,
                                                  1,
                                                  photosTrayContainerView.frame.size.width,
                                                  photosTrayContainerView.frame.size.height - 75);//add a little inset
    [self addChildViewController:self.photosTrayPicker];
    [photosTrayContainerView addSubview:self.photosTrayPicker.view];
    [self.photosTrayPicker didMoveToParentViewController:self];
    [self.photosTrayView addSubview:photosTrayContainerView];
    [self.photosTrayView addSubview:photosTrayHeaderView];//add on top
    [self.view addSubview:self.photosTrayView];
    
    photoTrayIsFullyOpen = NO;
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark
// adds pan gesture recognizers to the drag button
- (void)addGestureRecognizersToDragButton:(UIButton *)button {
    
    //subclassed pan gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [button addGestureRecognizer:panGesture];
}

// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    //get the full photo tray view that holds the button we attached the gesture to
    UIView *piece = [[[gestureRecognizer view] superview] superview];
    
    NSLog(@"piece y = %0.0f\n", [piece center].y);
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        if ((([piece center].y + translation.y) >= kPHOTO_TRAY_SUPERVIEW_MIN_Y) && (([piece center].y + translation.y) <= kPHOTO_TRAY_SUPERVIEW_MAX_Y)) {
            [piece setCenter:CGPointMake([piece center].x/* + translation.x*/, [piece center].y + translation.y)]; //don't add a translation to maintain vertical movement only
            //set our boolean that tracks if the tray is open or closed
            if (([piece center].y + translation.y) == kPHOTO_TRAY_SUPERVIEW_MAX_Y) {
                photoTrayIsFullyOpen = YES;
            }
            
            if (([piece center].y + translation.y) == kPHOTO_TRAY_SUPERVIEW_MIN_Y) {
                photoTrayIsFullyOpen = NO;
            }
            
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        }
    }
}

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

#pragma mark - Custom Methods
- (void)dragButtonPressed:(id)sender {
    
    CGRect sliderScrollFrame = self.photosTrayView.frame;
    
    if (photoTrayIsFullyOpen == NO) {
        //open fully
        sliderScrollFrame.origin.y -= 148;//329
        
        [UIView animateWithDuration:0.25
                              delay:0.05
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.photosTrayView.frame = sliderScrollFrame;
                         }
                         completion:^(BOOL finished){
                             photoTrayIsFullyOpen = YES;
                         }];
    } else {
        //close fully
        sliderScrollFrame.origin.y += 148;//474
        
        [UIView animateWithDuration:0.25
                              delay:0.05
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.photosTrayView.frame = sliderScrollFrame;
                         }
                         completion:^(BOOL finished){
                             photoTrayIsFullyOpen = NO;
                         }];
    }
    
//    //we'll either fully expand or fully contract based on the positioning of the photos tray view
//    CGFloat trayCenterY = [self.photosTrayView center].y;
//    CGFloat topDifference = trayCenterY - kPHOTO_TRAY_SUPERVIEW_MIN_Y;
//    CGFloat bottomDifference = trayCenterY - kPHOTO_TRAY_SUPERVIEW_MIN_Y;
//    
//    //now that we have the differences, see which one is smallest, i.e. closest to and pop to that position
//    if (topDifference <= bottomDifference) {
//        //popping to the will win in a tie
//        //animate open
//        photoTrayIsFullyOpen = YES;
//    } else {
//        //animate closed
//        photoTrayIsFullyOpen = NO;
//    }
}

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
