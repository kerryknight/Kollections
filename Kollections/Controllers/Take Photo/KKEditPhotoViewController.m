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
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, assign) BOOL profilePhotoUploadedSuccessfully;
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
    
    NSLog(@"Memory warning on Edit");
}


#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]];
    self.view = self.scrollView;
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 25.0f, 280.0f, 280.0f)];
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
    if (!self.isProfilePhoto) {
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
        //we're uploading a profile photo so don't allow comments
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y + photoImageView.frame.size.height)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES];

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
    
    //add custom toolbar buttons
    KKToolbarButton *cancelButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame andTitle:@"Cancel"];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:cancelButton];
    
    KKToolbarButton *publishButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame andTitle:@"Publish"];
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
    
    //first, check to see if it's a regular photo for submission or a profile photo we're trying to upload
    //if it's a profile photo, since we'll be resizing and processing a bit differently, pass it off to KKUtility instead of uploading here
    if (self.isProfilePhoto) {
        NSLog(@"is a profile photo");
        //it's a profile photo, so pass the data off, mark if successful and exit here
        self.profilePhotoUploadedSuccessfully = [KKUtility processLocalProfilePicture:anImage];
        return NO;//return NO here since we'll upload from KKUtility instead
    } else {
        NSLog(@"is a regular non-profile photo");
    }
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
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
    
    NSLog(@"Requested background expiration task with id %d for Kollections photo upload", self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Thumbnail uploaded successfully");
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
//    NSLog(@"%s", __FUNCTION__);
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  trimmedComment,kKKEditPhotoViewControllerUserInfoCommentKey,
                                  nil];
    }
    
    //if we don't have image data and it's not a profile pic, show upload error
    if ((!self.photoFile || !self.thumbnailFile) && !self.profilePhotoUploadedSuccessfully) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't upload your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    //if it was a profile pic upload, dismiss the view, tell the my account view to update the current profile photo
    //and then exit without further processing
    if (self.profilePhotoUploadedSuccessfully) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyAccountViewLoadProfilePhoto" object:nil];
        [self.parentViewController dismissModalViewControllerAnimated:YES];
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
            NSLog(@"Photo uploaded");
            
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
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
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
