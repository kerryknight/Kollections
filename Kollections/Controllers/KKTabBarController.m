//
//  KKTabBarController.m
//  Kollections
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "KKTabBarController.h"
#import "KKAppDelegate.h"

//used to differentiate between regular photos for posting and simply adding a profile pic
typedef enum {
    KKTabBarControllerPhotoTypeRegularPhoto = 0,
    KKTabBarControllerPhotoTypeProfilePhoto,
    KKTabBarControllerPhotoTypeKollectionPhoto
} KKTabBarControllerPhotoType;

@interface KKTabBarController () {
}
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, assign) KKTabBarControllerPhotoType photoType;//used to determine how to process the photo
@property (nonatomic, strong) KKImageEditorViewController *imageEditor;
@property (nonatomic, strong) ALAssetsLibrary *library; //our photo library
@property (nonatomic, assign) BOOL profilePhotoUploadedSuccessfully;
@end

@implementation KKTabBarController
@synthesize navController;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"kkTabBarBackground.png"]];
    [[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"kkTabBarDown.png"]];
    
    self.navController = [[UINavigationController alloc] init];
    [KKUtility addBottomDropShadowToNavigationBarForNavigationController:self.navController];
    
    //add notifications
    //these are the same notification but with different names so we can process the photos slightly differently
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCaptureButtonAction:) name:@"profilePhotoCaptureButtonAction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCaptureButtonAction:) name:@"kollectionPhotoCaptureButtonAction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissParentViewController) name:@"tabBarControllerDismissParentViewController" object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"profilePhotoCaptureButtonAction" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kollectionPhotoCaptureButtonAction" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tabBarControllerDismissParentViewController" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(128.0f, 0.0f, 64.0f, self.tabBar.bounds.size.height);
    [cameraButton setImage:[UIImage imageNamed:@"kkCameraUp.png"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"kkCameraDown.png"] forState:UIControlStateHighlighted];
    [cameraButton addTarget:self action:@selector(photoCaptureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:cameraButton];
    
    //    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    //    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    //    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    //    [cameraButton addGestureRecognizer:swipeUpGestureRecognizer];
}

#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    //check who the sender is to make sure we don't upload a photo per usual if we're just trying to add a profile picture
    if ([sender respondsToSelector:@selector(name)] && [[sender name] isEqualToString:@"profilePhotoCaptureButtonAction"]) {
        self.photoType = KKTabBarControllerPhotoTypeProfilePhoto;
    } else if ([sender respondsToSelector:@selector(name)] && [[sender name] isEqualToString:@"kollectionPhotoCaptureButtonAction"]) {
        self.photoType = KKTabBarControllerPhotoTypeKollectionPhoto;
    } else {
        self.photoType = KKTabBarControllerPhotoTypeRegularPhoto; //this denotes a regular photo submission and not a profile photo
    }
    
    DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    
}

-(void) imagePickerControllerDidCancel:(DLCImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    NSLog(@"%s", __FUNCTION__);
    if (info) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:[info objectForKey:@"data"] metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
         {
             if (error) {
                 NSLog(@"ERROR: the image failed to be written");
             }
             else {
                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
                 
                 [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                     
                     //get regular-sized image
                     ALAssetRepresentation *rep = [asset defaultRepresentation];
                     CGImageRef imageRef = [rep fullResolutionImage];
                     UIImage *largeImage;
                     
                     if (imageRef) {
                         largeImage = [UIImage imageWithCGImage:imageRef];
                     }
                     
                     //further process the image based on what type we're trying to collect
                     if (self.photoType == KKTabBarControllerPhotoTypeProfilePhoto) {
                         //profile photo
                         //it's a profile photo, so pass the data off, mark if successful and exit here
                         
                         self.profilePhotoUploadedSuccessfully = [KKUtility processLocalProfilePicture:largeImage];
                         
                         return;
                     } else if (self.photoType == KKTabBarControllerPhotoTypeKollectionPhoto) {
                         NSLog(@"save kollection cover photo");
                         //kollection cover photo
                         //stick the uiimage of our cover photo into a user info dictionary to send with the notification
                         NSDictionary *photoItem = @{kKKKollectionCoverPhotoKey : largeImage};
                         
                         //send our photo back to our KKKollectionSetupTableViewController to load into our table and save accordingly with our kollection object
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"KollectionSetupTableViewControllerProcessKollectionCoverPhoto" object:nil userInfo:photoItem];
                         
                     } else {
                         //dismiss hud from the appdelegate's window
                         id appDelegate = [[UIApplication sharedApplication] delegate];
                         UIWindow *window = [appDelegate window];
                         [MBProgressHUD hideHUDForView:window animated:NO];
                         
                         //dismiss the filter selector view
                         [self dismissModalViewControllerAnimated:NO];
                         
                         //regular submission photo
                         KKEditPhotoViewController *viewController = [[KKEditPhotoViewController alloc] initWithImage:largeImage];
                         [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                         
                         //make sure we know what type of photo we're trying to work with as we don't want to treat profile photo
                         //uploads the same as regular uploads which could get added as submissions, etc.
                         
                         viewController.photoType = self.photoType;
                         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
                         [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                         [self.navController pushViewController:viewController animated:NO];
                         [self presentModalViewController:self.navController animated:YES];
                     }
                     
                 } failureBlock:^(NSError *error) {
                     NSLog(@"Failed to get asset from library");
                 }];
                 
             }
         }];
    }
}

- (void)dismissParentViewController {
//    NSLog(@"%s", __FUNCTION__);
    
    //dismiss hud from the appdelegate's window
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [MBProgressHUD hideHUDForView:window animated:NO];
    
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

@end
