//
//  KKTabBarController.m
//  Kollections
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "KKTabBarController.h"

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
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"profilePhotoCaptureButtonAction" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kollectionPhotoCaptureButtonAction" object:nil];
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
    NSLog(@"%s", __FUNCTION__);
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
    NSLog(@"%s", __FUNCTION__);
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    if (info) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:[info objectForKey:@"data"] metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
         {
             if (error) {
                 NSLog(@"ERROR: the image failed to be written");
             }
             else {
                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
                 
                 [self dismissModalViewControllerAnimated:NO];
                 
                 [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                     
//                     //get regular-sized image
//                     ALAssetRepresentation *rep = [asset defaultRepresentation];
//                     CGImageRef imageRef = [rep fullResolutionImage];
//                     UIImage *largeImage;
//                     
//                     if (imageRef) {
//                         largeImage = [UIImage imageWithCGImage:imageRef];
//                     }
//                     
//                     //hide hud
//                     [MBProgressHUD hideAllHUDsForView:self.view.superview animated:NO];
                     
                     UIImage *preview = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
                     
                     //UPDATE most likely we'll want to pop up a kollection picker view here instead of a comments view for the photo
                     
                     KKEditPhotoViewController *viewController = [[KKEditPhotoViewController alloc] initWithImage:preview];
                     [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                     
                     //make sure we know what type of photo we're trying to work with as we don't want to treat profile photo
                     //uploads the same as regular uploads which could get added as submissions, etc.
                     viewController.photoType = self.photoType;
                     
                     [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                     [self.navController pushViewController:viewController animated:NO];
                     [self presentModalViewController:self.navController animated:YES];
                     
                 } failureBlock:^(NSError *error) {
                     NSLog(@"Failed to get asset from library");
                 }];
                 
             }
         }];
    }
}

@end
