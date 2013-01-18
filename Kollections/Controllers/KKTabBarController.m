//
//  KKTabBarController.m
//  Kollections
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKTabBarController.h"

//used to differentiate between regular photos for posting and simply adding a profile pic
typedef enum {
    KKTabBarControllerPhotoTypeRegularPhoto = 0,
    KKTabBarControllerPhotoTypeProfilePhoto,
    KKTabBarControllerPhotoTypeKollectionPhoto
} KKTabBarControllerPhotoType;

@interface KKTabBarController () {
}
@property (nonatomic,strong) UINavigationController *navController;
@property (nonatomic, assign) KKTabBarControllerPhotoType photoType;//used to determine how to process the photo
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
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [cameraButton addGestureRecognizer:swipeUpGestureRecognizer];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    NSLog(@"%s", __FUNCTION__);
    [self dismissModalViewControllerAnimated:NO];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
     
    KKEditPhotoViewController *viewController = [[KKEditPhotoViewController alloc] initWithImage:image];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    //make sure we know what type of photo we're trying to work with as we don't want to treat profile photo
    //uploads the same as regular uploads which could get added as submissions, etc.
    viewController.photoType = self.photoType;
    
    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navController pushViewController:viewController animated:NO];
    
    [self presentModalViewController:self.navController animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}


#pragma mark - KKTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
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
    
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
        [actionSheet showFromTabBar:self.tabBar];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentModalViewController:cameraUI animated:YES];
    
    return YES;
}


- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO 
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentModalViewController:cameraUI animated:YES];
    
    return YES;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self shouldPresentPhotoCaptureController];
}

@end
