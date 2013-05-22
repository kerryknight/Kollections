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
#import "ELCAsset.h"
#import <CoreGraphics/CoreGraphics.h>

#define kPHOTO_TRAY_CLOSED_Y (self.view.frame.size.height - (self.tabBarController.tabBar.frame.size.height + 91)) //91 sets it just right based on current size at 44px high
#define kPHOTO_TRAY_OPEN_Y (kPHOTO_TRAY_CLOSED_Y - 140)
#define kPHOTO_TRAY_HEIGHT 307

typedef enum {
    PhotoTrayPositionOffset = -1,
    PhotoTrayPositionClosed,
    PhotoTrayPositionOpen
} PhotoTrayPosition;

@interface KKKollectionViewController () {
    PhotoTrayPosition photoTrayPosition;
}

@property (nonatomic, strong) KKKollectionTableViewController *tableView;
@property (nonatomic, strong) ELCImagePickerController *photosTrayPicker;
@property (nonatomic, strong) ELCAlbumPickerController *photoAlbumPickerController;
@property (nonatomic, strong) KKToolbarButton *editButton;
@property (nonatomic, strong) KKToolbarButton *backButton;
@property (nonatomic, strong) KKToolbarButton *dragButton;
@property (nonatomic, strong) NSMutableArray *subjectList;
@property (nonatomic, strong) UIView *photosTrayView;
@property (nonatomic, strong) JDDroppableView *dropview;
@property (nonatomic, strong) ELCAsset *photoToSubmit;
@property (nonatomic, strong) UILabel *instructionLabel;

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

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    
    if (!self.tableView) self.tableView = [[KKKollectionTableViewController alloc] initWithKollection:self.kollection];
    self.tableView.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);//allow a little inset padding
    
    //give table a bit of content inset so we can see the whole thing since it's fullscreen
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 44, 0.0);
    self.tableView.tableView.contentInset = contentInsets;
    
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView.view];
    
    //hide default back button as it's not styled like I want
    self.navigationItem.hidesBackButton = YES;
    //set up our toolbar buttons
    [self configureBackButton];
    [self configureEditButton];
    
    //set up our photos tray
    if(!self.photosTrayView)[self configurePhotoTray];
    
    //add a draggable view of our photo over top
    if (!self.dropview) self.dropview = [[JDDroppableView alloc] init];
    self.dropview.tag = 999;
    self.dropview.delegate = self;
    [self.dropview becomeFirstResponder];
    
    //add a border
    self.dropview.layer.borderColor = kMint3.CGColor;
    self.dropview.layer.borderWidth = 0.75f;
    [self.view addSubview:self.dropview];
}

- (void)viewWillAppear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    self.backButton.hidden = NO;//this is hidden if we navigate away
    self.editButton.hidden = NO;//this is hidden if we navigate away
    
    //attach notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photosTrayPhotoTouchDown:) name:@"PhotosTrayPhotoTouchDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAnySelectedPhoto:) name:@"PhotosTrayDismissAnySelectedPhoto" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear:animated];
    self.backButton.hidden = YES;
    self.editButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PhotosTrayPhotoTouchDown" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PhotosTrayDismissAnySelectedPhoto" object:nil];
}

- (void)dealloc {
    
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
//                DLog(@"kollection subjects refreshed");
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
- (void)kollectionTableViewControllerDidLoadSubjects:(NSArray*)subjects {
    self.subjectList = [subjects mutableCopy];
}

- (void)animatePhotoBarOn {
    
    //only animate our photo bar on if it's currently not visible
    if (self.photosTrayView.frame.origin.y > 379) {
        //it's hidden so we can animate it on
        CGRect sliderScrollFrame = self.photosTrayView.frame;
        sliderScrollFrame.origin.y -= 60;//329 overall for iphone 4s
        //perform the animation
        [UIView animateWithDuration:0.25
                              delay:0.05
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.photosTrayView.frame = sliderScrollFrame;
                         }
                         completion:^(BOOL finished){
                             //finished animation
                         }];
    }
}

- (void)loadPhotoDetailsViewForPhoto:(PFObject*)photo {
    
    if (photo) {
        KKPhotoDetailsViewController *photoDetailsVC = [[KKPhotoDetailsViewController alloc] initWithPhoto:photo];
        photoDetailsVC.delegate = self;
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

#pragma mark - KKPhotoDetailsViewControllerDelegate
- (void)photoDetailViewDidSwipeToLoadNextPhotoReplacingCurrentPhoto:(PFObject*)photo {
    NSLog(@"%s", __FUNCTION__);
    
//    KKPhotoDetailsViewController *photoDetailsVC = [[KKPhotoDetailsViewController alloc] initWithPhoto:photo];
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.75;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromRight;
//    transition.delegate = self;
//    [self.view.layer addAnimation:transition forKey:nil];
//    [self.view addSubview:photoDetailsVC.view];
}

- (void)photoDetailViewDidSwipeToLoadPreviousPhotoReplacingCurrentPhoto:(PFObject*)photo {
    NSLog(@"%s", __FUNCTION__);
    
//    KKPhotoDetailsViewController *photoDetailsVC = [[KKPhotoDetailsViewController alloc] initWithPhoto:photo];
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.75;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromLeft;
//    transition.delegate = self;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//    [self.navigationController.view addSubview:photoDetailsVC.view];
}

- (void)getPreviousPhotoFromPhoto:(PFObject*)photo {
    //loop through array of photos till we find passed in photo, then get the previous one and load it
}

- (void)getNextPhotoFromPhoto:(PFObject*)photo {
    
}

#pragma mark - Asset Delegate
- (void)dismissAnySelectedPhoto:(id)sender {
    //dismiss the drop view if we're hit edit, back or closed the photo tray
    [self.dropview hide];
}

#define GROW_ANIMATION_DURATION_SECONDS 0.15
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15
- (void)photosTrayPhotoTouchDown:(NSNotification*)notification {
//    NSLog(@"%s", __FUNCTION__);
    
    //TODO: here's some example code of how to add a context menu to items onscreen
    //here's how to add a little menu popover to a view with a selectable action(s)
//    UIMenuController *menuController = [UIMenuController sharedMenuController];
//    UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Reset" action:@selector(resetPiece:)];
//    CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
//    
//    [self becomeFirstResponder];
//    [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
//    [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
//    [menuController setMenuVisible:YES animated:YES];

    //TODO: Get dropview dragging on FIRST touch; not on a subsequent second touch
    
    [self.dropview becomeFirstResponder];//doesn't appear to help first touch dragging
    
    NSDictionary *userInfo = notification.userInfo;
    
    //get our passed in photo object from the notification
    self.photoToSubmit = userInfo[@"photo"];
    
    CGPoint touchedPoint = [self.view convertPoint:self.photoToSubmit.center fromView:self.photoToSubmit.superview];
    CGRect photoFrame = [self.photoToSubmit.superview convertRect:self.photoToSubmit.frame toView:self.view];
    UIImageView *photoImage = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self.photoToSubmit.asset thumbnail]]];
    photoImage.tag = 99999;
    
    //set our initial frames for animating larger photo in
    self.dropview.frame = photoFrame;
    photoImage.frame = self.dropview.bounds;
    
    [[self.dropview viewWithTag:99999] removeFromSuperview];//remove any previous thumbnail images
    self.dropview.bounds = CGRectMake(0, 0, 75, 75);//set our bounds so we're always the same size on subsequent touches
    
    //add our new thumbnail
    [self.dropview addSubview:photoImage];
    self.dropview.alpha = 1.0;
    self.dropview.hidden = NO;
    
    //add an instruction label
    UILabel *dragLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, 75, 35)];
    dragLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    dragLabel.text = @"Drag to a Kollection";
    dragLabel.textColor = kCreme;
    dragLabel.textAlignment = UITextAlignmentCenter;
    [dragLabel setFont:[UIFont fontWithName:@"OriyaSangamMN" size:11]];
    dragLabel.numberOfLines = 0;
    dragLabel.lineBreakMode = UILineBreakModeWordWrap;
    dragLabel.alpha = 0.0;
    [self.dropview addSubview:dragLabel];
    
    [UIView animateWithDuration:GROW_ANIMATION_DURATION_SECONDS animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.dropview.transform = transform;
        self.dropview.center = touchedPoint;
        photoImage.frame = self.dropview.bounds;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:SHRINK_ANIMATION_DURATION_SECONDS animations:^{
            CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
            self.dropview.transform = transform;
            photoImage.frame = self.dropview.bounds;
            dragLabel.alpha = 1.0;
        } completion:^(BOOL finished2) {
            //done
            [self.dropview becomeFirstResponder];//doesn't appear to help first touch draggin
        }];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	NSLog(@"%s", __FUNCTION__);
	// We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [touches anyObject];
	
	// Only move the placard view if the touch was in the placard view
	if ([touch view] != self.dropview) {
		return;
	}
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//	NSLog(@"%s", __FUNCTION__);
	UITouch *touch = [touches anyObject];
	
	// If the touch was in the placardView, move the placardView to its location
	if ([touch view] == self.dropview) {
		CGPoint location = [touch locationInView:self.view];
		self.dropview.center = location;
		return;
	}
}

#pragma JDDroppableViewDelegate
- (void)droppableViewBeganDragging:(JDDroppableView*)view; {
//    NSLog(@"%s", __FUNCTION__);
    //    DLog(@"droppableViewBeganDragging");
    
	[UIView animateWithDuration:0.33 animations:^{
        view.alpha = 0.8;
        [view becomeFirstResponder];
    }];
}

- (void)droppableViewDidMove:(JDDroppableView*)view; {
//    NSLog(@"%s", __FUNCTION__);
}

- (void)droppableViewEndedDragging:(JDDroppableView*)view onTarget:(UIView *)target {
//    NSLog(@"%s", __FUNCTION__);
    
	[UIView animateWithDuration:0.33 animations:^{
        if (!target) {
            
        } else {
            //we're on target
            view.layer.borderColor = kMint3.CGColor;
            view.layer.borderWidth = 0.75f;
        }
        view.alpha = 1.0;
    }];
}

- (void)droppableView:(JDDroppableView*)view enteredTarget:(UIView*)target {
//    DLog(@"%s view = %@", __FUNCTION__, target);
    
    [[target layer] setMasksToBounds:YES];
    [[target layer] setBorderColor:kMint4.CGColor];
    [[target layer] setBorderWidth:2.0f];
    [[target layer] setShadowColor:kCreme.CGColor];
    [[target layer] setShadowOffset:CGSizeMake(0, 0)];
    [[target layer] setShadowOpacity:1];
    [[target layer] setShadowRadius:2.0];
}

- (void)droppableView:(JDDroppableView*)view leftTarget:(UIView*)target {
//    NSLog(@"%s", __FUNCTION__);

    [[target layer] setMasksToBounds:YES];
    [[target layer] setBorderWidth:0];
    [[target layer] setShadowOpacity:0];
    [[target layer] setShadowRadius:0];
    
}

- (BOOL)shouldAnimateDroppableViewBack:(JDDroppableView*)view wasDroppedOnTarget:(UIView*)target forIndexPath:(NSIndexPath*)indexPath{
//    NSLog(@"%s", __FUNCTION__);
    
	[self droppableView:view leftTarget:target];
    
    // animate out and remove view
    [UIView animateWithDuration:0.33 animations:^{
        view.transform = CGAffineTransformMakeScale(0.2, 0.2);
        view.alpha = 0.0;
        view.center = target.center;
    } completion:^(BOOL finished) {
        //upload our photo to the correct kollection
        [self uploadPhotoForIndexPath:indexPath];
        view.hidden = YES;
    }];
    
    return NO;
}

#pragma mark ELCImagePickerControllerDelegate Methods
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
//	NSLog(@"%s", __FUNCTION__);
    //	[self dismissModalViewControllerAnimated:YES];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    
}

#pragma mark - Touch handling

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder {
    return YES;
}

// adds pan gesture recognizers to the drag button
- (void)addGestureRecognizersToDragButton:(UIButton *)button {
    
    //TODO: knightka 19Feb2013 Fix the drop target creation when dragging the photo tray;
    //right now, it doesn't properly reset the drop target frames so the user has to drag in wierd places to submit a photo when
    //this section is uncommented so I'm disabling dragging the tray open and closed gesture until a later date
    
    /*
    //subclassed pan gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [button addGestureRecognizer:panGesture];
     */
}

//knightka 19Feb2013 - disabled b/c drop target frames were properly resizing on drag of photo tray
//this recognizer is applied to the photo tray for opening and closing it
// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer {
    //dismiss any dropview that might be showing
    [self dismissAnySelectedPhoto:nil];
    
    //get the full photo tray view that holds the button we attached the gesture to
    UIView *piece = [[[gestureRecognizer view] superview] superview];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        if (((piece.frame.origin.y + translation.y) >= (kPHOTO_TRAY_OPEN_Y + (piece.frame.size.height/4) + 11)) &&
            ((piece.frame.origin.y + translation.y) <= (kPHOTO_TRAY_CLOSED_Y + (piece.frame.size.height/4) + 16))) {
            
            [piece setCenter:CGPointMake([piece center].x/* + translation.x*/, [piece center].y + translation.y)]; //don't add a translation to maintain vertical movement only
            
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
            
            //set our boolean that tracks if the tray is open or closed
            if (piece.frame.origin.y == (kPHOTO_TRAY_OPEN_Y + (piece.frame.size.height/4) + 11)) {
                photoTrayPosition = PhotoTrayPositionOpen;
            }
            
            if (piece.frame.origin.y == (kPHOTO_TRAY_CLOSED_Y + (piece.frame.size.height/4) + 16)) {
                photoTrayPosition = PhotoTrayPositionClosed;
            }
            
            //now determine what our positioning is so we can use this to tell our button what to do in case the user
            //touches it to open fully or close fully instead of continuing to drag
            if (((piece.frame.origin.y <= (kPHOTO_TRAY_CLOSED_Y + (piece.frame.size.height/4) + 16)) &&
                 (piece.frame.origin.y >= (kPHOTO_TRAY_OPEN_Y + (piece.frame.size.height/4) + 11))) ||
                ((piece.frame.origin.y >= (kPHOTO_TRAY_CLOSED_Y + (piece.frame.size.height/4) + 16)) ||
                 (piece.frame.origin.y <= (kPHOTO_TRAY_OPEN_Y + (piece.frame.size.height/4) + 11)))) {
                    //not full open/closed
                    photoTrayPosition = PhotoTrayPositionOffset;
                }
            
            //also, we need to adjust our tablview's insets to reflect our new positioning so that the user can still scroll the whole thing
            //the higher the tray is pulled or open, the larger the inset needs to be
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, ((piece.frame.size.height - 30) - (piece.frame.origin.y - kPHOTO_TRAY_OPEN_Y)), 0);
            self.tableView.tableView.contentInset = contentInsets;
            
        }
    }
    
    [self resizeVisibleAreaIntersectionAndDropTargets];
}

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
        
    }
}

- (void)resizeVisibleAreaIntersectionAndDropTargets {
//    NSLog(@"%s", __FUNCTION__);
    
    //check if the photo tray is open; if not, there's not need to do anything b/c we can't drag photos around
    if (photoTrayPosition != PhotoTrayPositionClosed) {
        //first, let's get the visible rect of the backing table view; this should be the bottom of the navigation bar to the top of the photo tray
        CGRect visibleFrame = CGRectMake(0,
                                         0,
                                         self.navigationController.navigationBar.frame.size.width,
                                         self.photosTrayView.frame.origin.y - self.navigationController.navigationBar.frame.size.height - 10);
        
        //now determine if our droptargets intersect with our visible frame; if not, remove them from the list
        NSArray *indexes = [self.tableView.tableView indexPathsForVisibleRows];
        
        //remove existing drop targets
        [self.dropview.dropTargets removeAllObjects];
        
        if ([indexes count]) {
            
            for (NSIndexPath *index in indexes) {
                if (index.row == 1) {
                    
                    //get our table row's frame in relation to the parent view
                    CGRect rowRect = [self.tableView.tableView rectForRowAtIndexPath:index];
                    CGRect rowFrame = [self.tableView.tableView convertRect:rowRect toView:self.view];
                    
                    //determine if our row's frame intersects with the visible window frame
                    CGPoint rowCenter = CGPointMake(rowFrame.origin.x + rowFrame.size.width/2,
                                                    rowFrame.origin.y + rowFrame.size.height/2);
                    BOOL didHitTarget = CGRectContainsPoint(visibleFrame, rowCenter);
                    
//                    DLog(@"visibleFrame = %@", NSStringFromCGRect(visibleFrame));
                    
                    //only 1 drop target available at a time
                    if (didHitTarget && [self.dropview.dropTargets count] == 0) {
//                        DLog(@"rowCenter %@ for indexpath = %@", NSStringFromCGPoint(rowCenter), index);
                        //it's a kollection row, is visible and should be able to be added to drop targets
                        KKPhotoBarCell *cell = (KKPhotoBarCell*)[self.tableView.tableView cellForRowAtIndexPath:index];
                        //check if we have any existing photos in our collection view; if not, the collectionView doesn't get
                        //added so we need to pass in our no photos label's frame
                        if ([cell.kb.photos count]) {
                            //pass in our collection view
                            [self.dropview addDropTarget:cell.kb.collectionView forIndexPath:index];
                        } else {
                            //no photos, use our no photos label as the view
                            [self.dropview addDropTarget:cell.noPhotosLabel forIndexPath:index];
                        }
                        
                    } 
                }
            }
        }
    }
}

- (void) kollectionTableViewDidScroll {
    [self resizeVisibleAreaIntersectionAndDropTargets];
}

#pragma mark - Custom Methods
- (void)uploadPhotoForIndexPath:(NSIndexPath*)indexPath {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = kMint4;
    [hud setDimBackground:YES];
    [hud setLabelText:@"Submitting Photo"];
    
    PFObject *subject;
    
    if ([self.subjectList count] && indexPath) {
        subject = (PFObject*)[self.subjectList objectAtIndex:indexPath.section];
    } else {
        //there are no subjects so create a template one with our current kollection
        subject = [PFObject objectWithClassName:kKKSubjectClassKey];
    }
    
    if (subject) {
        //get our fully-sized image; we'll resize and orient in KKUtility
        ALAssetRepresentation *rep = [self.photoToSubmit.asset defaultRepresentation];
        NSDictionary *metadata = [rep metadata];
        
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *photoImage = [UIImage imageWithCGImage:iref scale:[rep scale] orientation:[rep orientation]];
            [KKUtility uploadPhoto:photoImage withMetadata:metadata forKollectionSubject:subject block:^(BOOL succeeded, NSError *error) {
                //hide hud
                
                if (succeeded) {
                    hud.labelText = @"Submission Success!";
                    [hud hide:YES afterDelay:1.0];
                    
                    //uploaded! now, tell our kollection view to reload itself
                    [self.tableView loadObjects];
                    
                } else {
                    //error
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    
                    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Oops! Something happened!" message:@"We couldn't post your photo. Please try your request again."];
                    [alert setCancelButtonWithTitle:@"Dismiss" block:nil];
                    [alert show];
                }
            }];
        }
    }
}

- (void)configurePhotoTray {
    //add view to hold our photo tray header view; we're going to use this to cover up the navigation controller
    //that goes with the image picker controllers we're about to add; this is easier to do than removing
    //the navigation controller from those controllers and then trying to replicated that functionality on our own
    //the photosTrayView created below will be the top level view before we add everything to self.view
    //add a view to hold our tray image background
    self.photosTrayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.photosTrayView.frame = CGRectMake(0,
                                           kPHOTO_TRAY_CLOSED_Y + 60, //start it offscreen hidden initially
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
    self.dragButton = [[KKToolbarButton alloc] initWithTitle:@"Open"];
    self.dragButton.frame = CGRectMake(247.0f, 10.0f, 63.0f, 33.0f);
    [self.dragButton addTarget:self action:@selector(dragButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addGestureRecognizersToDragButton:self.dragButton];
    [photosTrayHeaderView addSubview:self.dragButton];
    
#define kPHOTO_ICON_WIDTH 40
    
    //add our photo icon image button
    UIButton *photoIconButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2 - kPHOTO_ICON_WIDTH/2), 12, kPHOTO_ICON_WIDTH, 27)];
    [photoIconButton setBackgroundImage:[UIImage imageNamed:@"kkPhotoIcon.png"] forState:UIControlStateNormal];
    [photoIconButton addTarget:self action:@selector(dragButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [photosTrayHeaderView addSubview:photoIconButton];
    
    //add a container view to hold our picker view controller
    UIView *photosTrayContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    photosTrayContainerView.frame = CGRectMake(0,
                                               2,
                                               self.view.frame.size.width,
                                               kPHOTO_TRAY_HEIGHT - 46);
    photosTrayContainerView.backgroundColor = [UIColor clearColor];
    
    //add the custom image picker to the photo tray
    if (!self.photoAlbumPickerController) self.photoAlbumPickerController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
    self.photoAlbumPickerController.mainView = self.view;
    self.photoAlbumPickerController.mainTableView = self.tableView.view;
    self.photoAlbumPickerController.view.backgroundColor = [UIColor clearColor];
	self.photosTrayPicker = [[ELCImagePickerController alloc] initWithRootViewController:self.photoAlbumPickerController];
    self.photoAlbumPickerController.view.backgroundColor = [UIColor clearColor];
    [self.photoAlbumPickerController setParent:self.photosTrayPicker];
    self.photosTrayPicker.delegate = self;
    self.photosTrayPicker.view.frame = CGRectMake(0,
                                                  1,
                                                  photosTrayContainerView.frame.size.width,
                                                  photosTrayContainerView.frame.size.height - 73);//add a little inset
    [self addChildViewController:self.photosTrayPicker];
    [photosTrayContainerView addSubview:self.photosTrayPicker.view];
    [self.photosTrayPicker didMoveToParentViewController:self];
    [self.photosTrayView addSubview:photosTrayContainerView];
    [self.photosTrayView addSubview:photosTrayHeaderView];//add on top
    [self.view addSubview:self.photosTrayView];
    
    photoTrayPosition = PhotoTrayPositionClosed;//initialize tray as closed
    
    //add instruction label that displays when photo tray is opened
    [self addInstructionLabel];
}

- (void)dragButtonPressed:(id)sender {
    
    //dismiss any dropview that might be showing
    [self dismissAnySelectedPhoto:nil];
    
    CGRect sliderScrollFrame = self.photosTrayView.frame;
    NSInteger position = photoTrayPosition;
    BOOL shouldShowInstructionLabel = NO;
    
    if (photoTrayPosition == PhotoTrayPositionClosed) {
        //open fully
        sliderScrollFrame.origin.y -= 144;//329 overall for iphone 4s
        position = PhotoTrayPositionOpen;
        shouldShowInstructionLabel = YES;
        [self.dragButton setTitle:@"Close" forState:UIControlStateNormal];
        
    } else if (photoTrayPosition == PhotoTrayPositionOpen){
        //close fully
        sliderScrollFrame.origin.y += 144;//474 overall for iphone 4s
        position = PhotoTrayPositionClosed;
        shouldShowInstructionLabel = NO;
        [self.dragButton setTitle:@"Open" forState:UIControlStateNormal];
        
    } else if (photoTrayPosition == PhotoTrayPositionOffset) {
        
        //we're not fully open and not fully closed so determine which one we're closer to and continue to that point
        //we'll either fully expand or fully contract based on the positioning of the photos tray view
        CGFloat trayY = self.photosTrayView.frame.origin.y;
        CGFloat topDifference = trayY - kPHOTO_TRAY_OPEN_Y;
        CGFloat bottomDifference = kPHOTO_TRAY_CLOSED_Y - trayY; //reverse subtraction since the bottom y is greater than our center y
        
        //now that we have the differences, see which one is smallest, i.e. closest to and pop to that position
        if (topDifference <= bottomDifference) {
            //popping to the will win in a tie
            //animate open
            sliderScrollFrame = CGRectMake(0,
                                           (kPHOTO_TRAY_OPEN_Y + (self.photosTrayView.frame.size.height/4) + 8),
                                           self.photosTrayView.frame.size.width,
                                           self.photosTrayView.frame.size.height);
            position = PhotoTrayPositionOpen;
            shouldShowInstructionLabel = YES;
            [self.dragButton setTitle:@"Close" forState:UIControlStateNormal];
        } else {
            //animate closed
            sliderScrollFrame = CGRectMake(0,
                                           (kPHOTO_TRAY_CLOSED_Y + (self.photosTrayView.frame.size.height/4) + 16),
                                           self.photosTrayView.frame.size.width,
                                           self.photosTrayView.frame.size.height);
            position = PhotoTrayPositionClosed;
            shouldShowInstructionLabel = NO;
            [self.dragButton setTitle:@"Open" forState:UIControlStateNormal];
        }
    }
    
    //perform the animation
    [UIView animateWithDuration:0.25
                          delay:0.05
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.photosTrayView.frame = sliderScrollFrame;
                         //also, we need to adjust our tablview's insets to reflect our new positioning so that the user can still scroll the whole thing
                         //the higher the tray is pulled or open, the larger the inset needs to be
                         UIEdgeInsets contentInsets = UIEdgeInsetsMake(0,
                                                                       0,
                                                                       ((self.photosTrayView.frame.size.height - 30) - (self.photosTrayView.frame.origin.y - kPHOTO_TRAY_OPEN_Y)),
                                                                       0);
                         self.tableView.tableView.contentInset = contentInsets;
                         
                         //show or hide instruction label accordingly
                         if (shouldShowInstructionLabel) {
                             self.instructionLabel.alpha = 1.0f;
                         } else {
                             self.instructionLabel.alpha = 0.0f;
                         }
                     }
                     completion:^(BOOL finished){
                         photoTrayPosition = position;
                         
                         //reset our visible area and drop targets for photo submission only to the kollection row we can currently see in the view
                         [self resizeVisibleAreaIntersectionAndDropTargets];
                         [self.dragButton setNeedsDisplay];
                     }];
}

//our custom buttons
- (void)configureBackButton {
    //    NSLog(@"%s", __FUNCTION__);
    //add button to view
    if (!self.backButton) self.backButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Back"];
    [self.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.backButton];
}

- (void)backButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)editButtonAction:(id)sender {
    //    NSLog(@"%s", __FUNCTION__);
    
    //dismiss any dropview that might be showing
    [self dismissAnySelectedPhoto:nil];
    
    KKEditKollectionViewController *editKollectionViewController = [[KKEditKollectionViewController alloc] init];
    editKollectionViewController.delegate = self;
    editKollectionViewController.kollection = self.kollection;
    editKollectionViewController.subjectsArrayToCompareAgainst = self.subjectList;
    [self.navigationController pushViewController:editKollectionViewController animated:YES];
}

- (void)configureEditButton {
    //    NSLog(@"%s", __FUNCTION__);
    //add button to view
    if (!self.editButton) self.editButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Edit"];
    [self.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.editButton];
    
}

- (void)addInstructionLabel {
    //error loading items
    self.instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 145, 45)];
    self.instructionLabel.textAlignment = UITextAlignmentLeft;
    self.instructionLabel.textColor = kCreme;
    [self.instructionLabel setFont:[UIFont fontWithName:@"OriyaSangamMN" size:10]];
    self.instructionLabel.backgroundColor = [UIColor clearColor];
    self.instructionLabel.numberOfLines = 2;
    self.instructionLabel.text = @"- Touch photo once to select\n- Touch photo again to drag";
    self.instructionLabel.alpha = 0.0f; //hidden when tray is closed
    [self.photosTrayView addSubview:self.instructionLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
