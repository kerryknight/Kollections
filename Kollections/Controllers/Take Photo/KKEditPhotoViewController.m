//
//  KKEditPhotoViewController.m
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKEditPhotoViewController.h"
#import "KKPhotoDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"
#import "KKToolbarButton.h"

@interface KKEditPhotoViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIImage *kollectionImage;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, assign) BOOL profilePhotoUploadedSuccessfully;
@property (nonatomic, assign) BOOL kollectionPhotoUploadedSuccessfully;
@end

@implementation KKEditPhotoViewController
@synthesize scrollView;
@synthesize image;
@synthesize commentTextField;
@synthesize photoFile;
@synthesize thumbnailFile;
@synthesize fileUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    DLog(@"Memory warning on Edit Photo View Controller");
}


#pragma mark - UIViewController

- (void)loadView {
//    NSLog(@"%s", __FUNCTION__);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]];
    self.view = self.scrollView;
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 25.0f, 280.0f, 210.6f)];
    [photoImageView setBackgroundColor:[UIColor blackColor]];
    [photoImageView setImage:self.image];
    [photoImageView setContentMode:UIViewContentModeScaleAspectFit];

    CALayer *layer = photoImageView.layer;
    layer.masksToBounds = NO;
    layer.shadowRadius = 3.0f;
    layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    layer.shadowOpacity = 0.5f;
    layer.shouldRasterize = YES;
    
    [self.scrollView addSubview:photoImageView];

    //check what type of photo we're dealing with; profile pics shouldn't allow comments or get posted like regular pics
    if (self.photoType == KKEditPhotoViewPhotoTypeRegularPhoto) {
        CGRect footerRect = [KKPhotoDetailsFooterView rectForView];
        footerRect.origin.y = photoImageView.frame.origin.y + photoImageView.frame.size.height;
        
        KKPhotoDetailsFooterView *footerView = [[KKPhotoDetailsFooterView alloc] initWithFrame:footerRect];
        footerView.hideDropShadow = YES;
        self.commentTextField = footerView.commentField;
        self.commentTextField.delegate = self;
        [self.scrollView addSubview:footerView];
        
        //allow room for comments in scrollview
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y + photoImageView.frame.size.height + footerView.frame.size.height)];
    } else {
        //we're uploading a profile or kollection photo so don't allow comments
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y + photoImageView.frame.size.height)];
    }
}

- (void)viewDidLoad {
    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    //add custom toolbar buttons
    KKToolbarButton *cancelButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:NO andTitle:@"Cancel"];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:cancelButton];
    
    KKToolbarButton *publishButton;
    //check what type of photo it is; if it's a regular photo or profile photo, go ahead and upload
    //if it's a kollection cover photo, don't upload yet as we need to save it with the kollection (in case the kollection doesn't exist)
    //we'll change the wording on the "publish" vs. "done" buttons to reflect this
    if (self.photoType == KKEditPhotoViewPhotoTypeRegularPhoto) {
        publishButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Publish"];
    } else {
        publishButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Done"];
    }
    [publishButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:publishButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self shouldUploadImage:self.image];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doneButtonAction:textField];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentTextField resignFirstResponder];  
}


#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    NSLog(@"%s", __FUNCTION__);
    
    //knightka - as of 28Jan2013, processing for anything other than a regular photo shouldn't be doing anything from this view controller
    //all of this should have already been handed off as appropriate from the tab bar controller prior to this view ever getting loaded
    //however, i've left the original processing code intact on this class for reference and out of laziness
    
    //first, check to see if it's a regular photo for submission or a profile photo we're trying to upload
    //if it's a profile photo, since we'll be resizing and processing a bit differently, pass it off to KKUtility instead of uploading here
    if (self.photoType == KKEditPhotoViewPhotoTypeProfilePhoto) {
        //it's a profile photo, so pass the data off, mark if successful and exit here
        self.profilePhotoUploadedSuccessfully = [KKUtility processLocalProfilePicture:anImage];
        return NO;//return NO here since we'll upload from KKUtility instead
    } else if (self.photoType == KKEditPhotoViewPhotoTypeKollectionPhoto) {
        //it's a kollection photo, so we'll pass it back to our kollection setup table view controller from here at doneButtonAction:
        //so here, just set our local instance variable to our image so we can pass it along from the doneButtonAction:
        self.kollectionImage = [[UIImage alloc] init];
        self.kollectionImage = anImage;
        return NO;//return NO here since we'll upload from KKUtility instead on KKKollectionSetupTableViewController.m
    } else {
        DLog(@"is a regular non-profile or kollection cover photo");
    }
    
    DLog(@"****** SHOULDN'T BE ANY DIRECT UPLOADING WITHOUT ADDING TO A KOLLECTION AND/OR SUBJECT TOO *******");
    
//    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(640.0f, 427.0f) interpolationQuality:kCGInterpolationHigh];
    
    UIImage *thumbnailImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(270.0f, 180.0f) interpolationQuality:kCGInterpolationDefault];
    
//    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
//    
//    DLog(@"resizedImage w = %0.0f", resizedImage.size.width);
//    DLog(@"resizedImage h = %0.0f", resizedImage.size.height);
    
    // JPEG to decrease file size and enable faster uploads & downloads
    // Get an NSData representation of our images. We use JPEG for the larger image
    // for better compression and PNG for the thumbnail to keep the corner radius transparency
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    DLog(@"Requested background expiration task with id %d for Kollections photo upload", self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            DLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    DLog(@"Thumbnail uploaded successfully");
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)doneButtonAction:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    // Trim comment and save it in a dictionary for use later in our callback block
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  trimmedComment,kKKEditPhotoViewControllerUserInfoCommentKey,
                                  nil];
    }
    
    //check if it's a profile photo
    if (self.photoType == KKEditPhotoViewPhotoTypeProfilePhoto) {
        //if it was a profile pic upload, dismiss the view, tell the my account view to update the current profile photo
        //and then exit without further processing
        if (self.profilePhotoUploadedSuccessfully) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MyAccountViewLoadProfilePhoto" object:nil];
            [self.parentViewController dismissModalViewControllerAnimated:YES];
            return;
        }
    }
    
    //check if it's a kollection photo
    if (self.photoType == KKEditPhotoViewPhotoTypeKollectionPhoto) {
        //stick the uiimage of our cover photo into a user info dictionary to send with the notification
        NSDictionary *photoItem = @{kKKKollectionCoverPhotoKey : self.kollectionImage};
        
        //send our photo back to our KKKollectionSetupTableViewController to load into our table and save accordingly with our kollection object
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KollectionSetupTableViewControllerProcessKollectionCoverPhoto" object:nil userInfo:photoItem];
        
        //dismiss the edit photo view 
        [self.parentViewController dismissModalViewControllerAnimated:YES];
        return;
    }
    
    //if we don't have image data and it's not a profile or kollection pic, show upload error
    if ((!self.photoFile || !self.thumbnailFile) && !self.profilePhotoUploadedSuccessfully) {
        
        //knightka replaced a regular alert view with our custom subclass
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Couldn't upload your photo" message:nil];
        [alert setCancelButtonWithTitle:@"Dismiss" block:nil];
        [alert show];
        
        
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    PFObject *photo = [PFObject objectWithClassName:kKKPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kKKPhotoUserKey];
    [photo setObject:self.photoFile forKey:kKKPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kKKPhotoThumbnailKey];
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];

    // save
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            DLog(@"Photo uploaded");
            
            // Add the photo to the local cache
            [[KKCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                NSString *commentText = [userInfo objectForKey:kKKEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    PFObject *comment = [PFObject objectWithClassName:kKKActivityClassKey];
                    [comment setObject:kKKActivityTypeComment forKey:kKKActivityTypeKey];
                    [comment setObject:photo forKey:kKKActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kKKActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kKKActivityToUserKey];
                    [comment setObject:commentText forKey:kKKActivityContentKey];
                    
                    // Comments are public but can only be modified by the author
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    // Save the comment
                    [comment saveEventually];
                    
                    // Update the photo's local cache to reflect a new comment
                    [[KKCache sharedCache] incrementCommentCountForPhoto:photo];
                }
            }
            
            // Send a notification. The main timeline will refresh itself when caught
            [[NSNotificationCenter defaultCenter] postNotificationName:KKTabBarControllerDidFinishEditingPhotoNotification object:photo];
        } else {
            DLog(@"Photo failed to save: %@", error);
            
            //knightka replaced a regular alert view with our custom subclass
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Couldn't post your photo" message:nil];
            [alert setCancelButtonWithTitle:@"Dismiss" block:nil];
            [alert show];
        }
        
        // If we are currently in the background, suspend the app, otherwise
        // cancel request for background processing.
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
