//
//  DLCImagePickerController.m
//  DLCImagePickerController
//
//  Created by Dmitri Cherniak on 8/14/12.
//  Copyright (c) 2012 Dmitri Cherniak. All rights reserved.
//

#import "DLCImagePickerController.h"
#import "GrayscaleContrastFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Colorization.h"

#define kStaticBlurSize 2.0f
#define kLandscapeHeight 240.0f
#define kImageViewCroppedYPositioning 90.0f
#define kInstructionLabelTag 1001

@interface DLCImagePickerController () {
    
}
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *blurFilter;
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;
@property (nonatomic, strong) GPUImagePicture *staticPicture;
@property (nonatomic, strong) UIImage *cameraPhoto;
@property (nonatomic, assign) UIImageOrientation staticPictureOriginalOrientation;
@property (nonatomic, strong) KKImageEditorViewController *imageEditor;//knightka
@property (nonatomic, assign) BOOL isStatic;
@property (nonatomic, assign) BOOL hasBlur;
@property (nonatomic, assign) BOOL filterBarIsShowing;//knightka
@property (nonatomic, assign) int selectedFilter;
@property (nonatomic, assign) CGRect filterStartingFrame;//knightka
@end

@implementation DLCImagePickerController {
    
}

@synthesize delegate,
    imageView,
    cameraToggleButton,
    photoCaptureButton,
    blurToggleButton,
    flashToggleButton,
    cancelButton,
    retakeButton,
    filtersToggleButton,
    libraryToggleButton,
    filterScrollView,
    filtersBackgroundImageView,
    photoBar,
    topBar,
    blurOverlayView,
    outputJPEGQuality;

-(id) init {
//    NSLog(@"%s", __FUNCTION__);
    self = [super initWithNibName:@"DLCImagePicker" bundle:nil];
    
    if (self) {
        self.outputJPEGQuality = 1.0;
    }
    
    return self;
}

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    //set background color
    self.view.backgroundColor = [UIColor blackColor];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = kMint4;
    [hud setDimBackground:YES];
    [self.view sendSubviewToBack:hud];
    
    self.photoBar.backgroundColor = [UIColor colorWithPatternImage:
                                     [UIImage imageNamed:@"photo_bar"]];
    
    self.topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kkBackgroundNavBar.png"]];
    
    [self configureCancelButton];
    
    //button states
    [self.blurToggleButton setSelected:NO];
    [self.filtersToggleButton setSelected:NO];
    self.blurToggleButton.hidden = YES;//knightka
    self.filtersToggleButton.hidden = YES;//knightka
    
    self.staticPictureOriginalOrientation = UIImageOrientationUp;
    
    self.focusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus-crosshair"]];
	[self.view addSubview:self.focusView];
	self.focusView.alpha = 0;
    
    
    if (!self.blurOverlayView) self.blurOverlayView = [[BlurOverlayView alloc] init];
    self.blurOverlayView.alpha = 0;
    [self.imageView addSubview:self.blurOverlayView];
    
    self.hasBlur = NO;
    
    //we need a crop filter for the live video
    self.cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0f, 0.0f, 1.0f, 0.75f)];
    
    self.filter = [[GPUImageFilter alloc] init];
    
    self.filterStartingFrame = self.filterScrollView.frame;
    
    [self configureBlurInstructionLabel];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self setUpCamera];
    });
}

-(void) viewWillAppear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [super viewWillAppear:animated];
}

-(void) loadFilters {
//    NSLog(@"%s", __FUNCTION__);
    for(int i = 0; i < 10; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i + 1]] forState:UIControlStateNormal];
        UIImage *downImage = [UIImage darkenImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i + 1]] toLevel:1.2];
        [button setBackgroundImage:downImage forState:UIControlStateSelected];
        
        button.frame = CGRectMake(10+i*(60+10), 5.0f, 60.0f, 60.0f);
        button.layer.cornerRadius = 7.0f;
        
        //use bezier path instead of maskToBounds on button.layer
        UIBezierPath *bi = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:CGSizeMake(7.0,7.0)];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = button.bounds;
        maskLayer.path = bi.CGPath;
        button.layer.mask = maskLayer;
        
        button.layer.borderWidth = 1;
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [button addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [button setTitle:@"*" forState:UIControlStateSelected];
        if(i == 0){
            [button setSelected:YES];
            [button setNeedsDisplay];
        }
		[self.filterScrollView addSubview:button];
	}
	[self.filterScrollView setContentSize:CGSizeMake(10 + 10*(60+10), 75.0)];
}

-(void) setUpCamera {
//    NSLog(@"%s", __FUNCTION__);
    
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(0,
                                      0,
                                      self.view.frame.size.height,//take photo at a square to prevent lens distortion
                                      self.view.frame.size.height);
    
    [self.filter forceProcessingAtSize:self.imageView.sizeInPixels];
    self.imageView.backgroundColor = [UIColor blackColor];
    
    [self.imageView setNeedsLayout];
    [self.imageView setNeedsDisplay];
    
    self.blurOverlayView.frame = self.imageView.frame;
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        // Has camera
        
        if(!self.stillCamera) self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
                
        self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        runOnMainQueueWithoutDeadlocking(^{
            [self.stillCamera startCameraCapture];
            if([self.stillCamera.inputCamera hasTorch]){
                [self.flashToggleButton setEnabled:YES];
            }else{
                [self.flashToggleButton setEnabled:NO];
            }
            [self prepareFilter];
        });
    } else {
        // No camera
        NSLog(@"No camera");
        runOnMainQueueWithoutDeadlocking(^{
            [self prepareFilter];
        });
    }
   
}

-(void) filterClicked:(UIButton *) sender {
    for(UIView *view in self.filterScrollView.subviews){
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton *)view setSelected:NO];
        }
    }
    
    [sender setSelected:YES];
    [self removeAllTargets];
    
    self.selectedFilter = sender.tag;
    [self chooseFilter:sender.tag];
    [self prepareFilter];
}

//knightka
- (void)deselectAllFilters {
//    NSLog(@"%s", __FUNCTION__);
    for(UIView *view in self.filterScrollView.subviews){
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton *)view setSelected:NO];
        }
    }
    
    [self.filterScrollView scrollRectToVisible:CGRectMake(1, 1, 1, 1) animated:NO];//scroll to beginning
    self.selectedFilter = -1;
    [self chooseFilter:0];//reset to default/no filter knightka
    [self prepareFilter];
}

-(void) chooseFilter:(int) index {
    switch (index) {
        case 1:{
            self.filter = [[GPUImageContrastFilter alloc] init];
            [(GPUImageContrastFilter *) self.filter setContrast:1.75];
        } break;
        case 2: {
            self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"crossprocess"];
        } break;
        case 3: {
            self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"02"];
        } break;
        case 4: {
            self.filter = [[GrayscaleContrastFilter alloc] init];
        } break;
        case 5: {
            self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"17"];
        } break;
        case 6: {
            self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"aqua"];
        } break;
        case 7: {
            self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"yellow-red"];
        } break;
        case 8: {
            self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"06"];
        } break;
        case 9: {
            self.filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"purple-green"];
        } break;
        default:
            self.filter = [[GPUImageFilter alloc] init];
            break;
    }
}

- (void) prepareFilter {
//    NSLog(@"%s", __FUNCTION__);
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.isStatic = YES;
    }
    
    if (!self.isStatic) {
        [self prepareLiveFilter];
    } else {
        [self prepareStaticFilter];
    }
}

- (void) prepareLiveFilter {
//    NSLog(@"%s", __FUNCTION__);
    [self.stillCamera addTarget:self.cropFilter];
    [self.cropFilter addTarget:self.filter];
    //blur is terminal filter
    if (self.hasBlur) {
        [self.filter addTarget:self.blurFilter];
        [self.blurFilter addTarget:self.imageView];
    //regular filter is terminal
    } else {
        [self.filter addTarget:self.imageView];
    }
    
    [self.filter prepareForImageCapture];
    
    [self.imageView setNeedsLayout];
    [self.imageView setNeedsDisplay];
}

-( void) prepareStaticFilter {
//    NSLog(@"%s", __FUNCTION__);
    if (!self.staticPicture) {
        // TODO: fix this hack
        [self performSelector:@selector(switchToLibrary:) withObject:nil afterDelay:0.5];
    }
    
    [self.staticPicture addTarget:self.filter];

    // blur is terminal filter
    if (self.hasBlur) {
        [self.filter addTarget:self.blurFilter];
        [self.blurFilter addTarget:self.imageView];
    //regular filter is terminal
    } else {
        [self.filter addTarget:self.imageView];
    }
    
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    switch (self.staticPictureOriginalOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    
    // seems like atIndex is ignored by GPUImageView...
    [self.imageView setInputRotation:imageViewRotationMode atIndex:0];

    [self.staticPicture processImage];
    
    [self.imageView setNeedsLayout];
    [self.imageView setNeedsDisplay];
}

-(void) removeAllTargets {
//    NSLog(@"%s", __FUNCTION__);
    [self.stillCamera removeAllTargets];
    [self.staticPicture removeAllTargets];
    [self.cropFilter removeAllTargets];
    
    //regular filter
    [self.filter removeAllTargets];
    
    //blur
    [self.blurFilter removeAllTargets];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [viewController.navigationItem setTitle:@"Photos"];
    
    //TODO: use custom buttons on the navigation bar with correct up/down states
    
//    KKToolbarButton *rightButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@""];
//    [rightButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    viewController.navigationItem.rightBarButtonItem = rightItem;
//    
//    KKToolbarButton *leftButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@""];
//    [leftButton addTarget:self action:@selector(popView:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//    viewController.navigationItem.leftBarButtonItem = leftItem;
}

- (void)popView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)switchToLibrary:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    if (!self.isStatic) {
        // shut down camera
        [self.stillCamera stopCameraCapture];
        [self removeAllTargets];
    }
    
    //resize our filtered imageView to match our 320x240 dimensions
    self.imageView.hidden = YES;
    self.imageView.frame = CGRectMake(0,
                                      kImageViewCroppedYPositioning,
                                      self.view.frame.size.width,
                                      kLandscapeHeight);
    [self.filter forceProcessingAtSize:self.imageView.sizeInPixels];
    self.blurOverlayView.frame = self.imageView.bounds;
    
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    
    if (!self.imageEditor) self.imageEditor = [[KKImageEditorViewController alloc] initWithNibName:@"KKImageEditorViewController" bundle:nil];
    
    __unsafe_unretained DLCImagePickerController *myself = self;
    
    self.imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled){
        if(!canceled) {
            
            UIImage *outputImage = editedImage;
            if (outputImage) {
                //reset filter selection
                [myself deselectAllFilters];
                myself.imageView.hidden = NO;
                myself.staticPicture = [[GPUImagePicture alloc] initWithImage:outputImage smoothlyScaleOutput:YES];
                myself.staticPictureOriginalOrientation = outputImage.imageOrientation;
                myself.isStatic = YES;
                [myself dismissViewControllerAnimated:YES completion:nil];
                [myself.cameraToggleButton setHidden:YES];
                [myself.flashToggleButton setHidden:YES];
                [myself.libraryToggleButton setHidden:YES];
                [myself.blurToggleButton setHidden:NO];
                [myself prepareStaticFilter];
                [myself.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
                [myself.photoCaptureButton setImage:nil forState:UIControlStateNormal];
                [myself.photoCaptureButton setEnabled:YES];
                [myself showFilters];
                
                //put border on image view
                myself.imageView.layer.borderColor = kGray3.CGColor;
                myself.imageView.layer.borderWidth = 0.75f;
                
                [MBProgressHUD hideHUDForView:myself.view.superview animated:YES];
            } else {
                //just pop back; error
                [myself dismissViewControllerAnimated:YES completion:nil];
                [MBProgressHUD hideHUDForView:myself.view.superview animated:YES];
            }
        } else {
            //we cancelled so reset the camera
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [myself setUpCamera];
            });
        }
    };
    
    //reset the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)captureImage {
//    NSLog(@"%s" ,__FUNCTION__);
    UIImage *img = [self.cropFilter imageFromCurrentlyProcessedOutput];
    [self.stillCamera.inputCamera unlockForConfiguration];
    [self.stillCamera stopCameraCapture];
    [self removeAllTargets];
    
    if(!self.cameraPhoto) self.cameraPhoto = [[UIImage alloc] init];
    self.cameraPhoto = img;
    self.staticPicture = [[GPUImagePicture alloc] initWithImage:img
                                            smoothlyScaleOutput:YES];
    
    self.staticPictureOriginalOrientation = img.imageOrientation;
    
    [self prepareFilter];
    [self.retakeButton setHidden:NO];
    [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
    [self.photoCaptureButton setEnabled:YES];
    
    //knightka added additional method to button
    [self.photoCaptureButton removeTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.photoCaptureButton addTarget:self action:@selector(loadCroppingView:) forControlEvents:UIControlEventTouchUpInside];
    
    //hitting the Done button will take us to the cropping view
}

//knightka
- (void) loadCroppingView:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    
    //resize our filtered imageView to match our 320x240 dimensions
    self.imageView.hidden = YES;
    self.imageView.frame = CGRectMake(0,
                                      kImageViewCroppedYPositioning,
                                      self.view.frame.size.width,
                                      kLandscapeHeight);
    [self.filter forceProcessingAtSize:self.imageView.sizeInPixels];
    self.blurOverlayView.frame = self.imageView.bounds;
    
    //load the image editor
    if (!self.imageEditor) self.imageEditor = [[KKImageEditorViewController alloc] initWithNibName:@"KKImageEditorViewController" bundle:nil];
    
    __unsafe_unretained DLCImagePickerController *myself = self;
    
    //set our callback block
    self.imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled){
        if(!canceled) {
            
//            NSLog(@"self.imageEditor.doneCallback editedImage w = %0.0f", editedImage.size.width);
//            NSLog(@"self.imageEditor.doneCallback editedImage h = %0.0f", editedImage.size.height);
            
            UIImage *outputImage = editedImage;
            if (outputImage) {
                //reset filter selection
                [myself deselectAllFilters];
                myself.imageView.hidden = NO;
                myself.staticPicture = [[GPUImagePicture alloc] initWithImage:outputImage smoothlyScaleOutput:YES];
                myself.staticPictureOriginalOrientation = outputImage.imageOrientation;
                myself.isStatic = YES;
                [myself prepareFilter];
                [myself.cameraToggleButton setHidden:YES];
                [myself.flashToggleButton setHidden:YES];
                [myself.libraryToggleButton setHidden:YES];
                [myself.blurToggleButton setHidden:NO];
                [myself prepareStaticFilter];
                [myself.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
                [myself.photoCaptureButton setImage:nil forState:UIControlStateNormal];
                [myself.photoCaptureButton setEnabled:YES];
                //knightka reset photo button method and unhide buttons
                [myself.photoCaptureButton removeTarget:myself action:@selector(loadCroppingView:) forControlEvents:UIControlEventTouchUpInside];
                [myself.photoCaptureButton addTarget:myself action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
                myself.filtersToggleButton.hidden = NO;
                myself.blurToggleButton.hidden = NO;
                [myself showFilters];
                
                [MBProgressHUD hideHUDForView:myself.view.superview animated:YES];
                
                //put border on image view
                myself.imageView.layer.borderColor = kGray3.CGColor;
                myself.imageView.layer.borderWidth = 0.75f;
                
                [myself dismissModalViewControllerAnimated:YES];
            } else {
                //just pop back; error
                [myself dismissViewControllerAnimated:YES completion:nil];
                [MBProgressHUD hideHUDForView:myself.view.superview animated:YES];
            }
        } else {
            //we cancelled so reset the camera
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [myself setUpCamera];
            });
        }
    };
    
    //give it the images
    self.imageEditor.sourceImage = self.cameraPhoto;
    self.imageEditor.isCameraPhoto = YES;
    [self.imageEditor reset:NO];
    
    //add our editor to a nav controller since we won't have one
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.imageEditor];
    
    //push into our view
    [self presentModalViewController:navController animated:YES];
}

- (void)receivedCroppedImage:(UIImage*)editedImage {
//    NSLog(@"%s", __FUNCTION__);
}

-(IBAction)toggleFlash:(UIButton *)button{
    [button setSelected:!button.selected];
}

-(IBAction) toggleBlur:(UIButton*)blurButton {
    
    [self.blurToggleButton setEnabled:NO];
    [self removeAllTargets];
    
    if (self.hasBlur) {
        self.hasBlur = NO;
        [self showBlurOverlay:NO];
        [self.blurToggleButton setSelected:NO];
        [self.view viewWithTag:kInstructionLabelTag].hidden = YES;
    } else {
        if (!self.blurFilter) {
            self.blurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            [(GPUImageGaussianSelectiveBlurFilter*)self.blurFilter setExcludeCircleRadius:80.0/320.0];
            [(GPUImageGaussianSelectiveBlurFilter*)self.blurFilter setExcludeCirclePoint:CGPointMake(0.5f, 0.5f)];
            [(GPUImageGaussianSelectiveBlurFilter*)self.blurFilter setBlurSize:kStaticBlurSize];
            [(GPUImageGaussianSelectiveBlurFilter*)self.blurFilter setAspectRatio:1.0f];
        }
        self.hasBlur = YES;
        [self.blurToggleButton setSelected:YES];
        [self.view viewWithTag:kInstructionLabelTag].hidden = NO;
        [self flashBlurOverlay];
    }
    
    [self prepareFilter];
    [self.blurToggleButton setEnabled:YES];
}

-(IBAction) switchCamera {
    
    [self.cameraToggleButton setEnabled:NO];
    [self.stillCamera rotateCamera];
    [self.cameraToggleButton setEnabled:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && self.stillCamera) {
        if ([self.stillCamera.inputCamera hasFlash] && [self.stillCamera.inputCamera hasTorch]) {
            [self.flashToggleButton setEnabled:YES];
        } else {
            [self.flashToggleButton setEnabled:NO];
        }
    }
}

-(void) prepareForCapture {
//    NSLog(@"%s", __FUNCTION__);
    [self.stillCamera.inputCamera lockForConfiguration:nil];
    if(self.flashToggleButton.selected &&
       [self.stillCamera.inputCamera hasTorch]){
        [self.stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        [self performSelector:@selector(captureImage)
                   withObject:nil
                   afterDelay:0.25];
    }else{
        [self captureImage];
    }
}

-(IBAction) takePhoto:(id)sender{
//    NSLog(@"%s", __FUNCTION__);
    [self.photoCaptureButton setEnabled:NO];
    
    if (!self.isStatic) {
        self.isStatic = YES;
        
        [self.libraryToggleButton setHidden:YES];
        [self.cameraToggleButton setEnabled:NO];
        [self.flashToggleButton setEnabled:NO];
        [self prepareForCapture];
        
    } else {
        //we selected done to process and save the photo so show a hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        hud.color = kMint4;
        [hud setDimBackground:YES];
        
        GPUImageOutput<GPUImageInput> *processUpTo;
        
        if (self.hasBlur) {
            processUpTo = self.blurFilter;
        } else {
            processUpTo = self.filter;
        }
        
        [self.staticPicture processImage];
        
        UIImage *currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:self.staticPictureOriginalOrientation];

        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                              UIImageJPEGRepresentation(currentFilteredVideoFrame, self.outputJPEGQuality), @"data", nil];
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:info];
    }
}

-(IBAction) retakePhoto:(UIButton *)button {
//    NSLog(@"%s", __FUNCTION__);
    
    //main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.retakeButton setHidden:YES];
        [self.libraryToggleButton setHidden:NO];
        self.staticPicture = nil;
        self.staticPictureOriginalOrientation = UIImageOrientationUp;
        self.isStatic = NO;
        [self removeAllTargets];
        [self.stillCamera startCameraCapture];
        [self.cameraToggleButton setEnabled:YES];
        [self.filtersToggleButton setEnabled:NO];
        self.filtersToggleButton.hidden = YES;
        
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]
           && self.stillCamera
           && [self.stillCamera.inputCamera hasTorch]) {
            [self.flashToggleButton setEnabled:YES];
        }
        
        [self.photoCaptureButton setImage:[UIImage imageNamed:@"camera-icon"] forState:UIControlStateNormal];
        [self.photoCaptureButton setTitle:nil forState:UIControlStateNormal];
        //knightka reset our changed actions
        [self.photoCaptureButton removeTarget:self action:@selector(loadCroppingView:) forControlEvents:UIControlEventTouchUpInside];
        [self.photoCaptureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        [self hideFilters];
        
        self.filterScrollView.frame = self.filterStartingFrame;

        [self setUpCamera];
    });
}

-(IBAction) cancel:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    [self.delegate imagePickerControllerDidCancel:self];
}

- (void)configureCancelButton {
//    NSLog(@"%s", __FUNCTION__);
    //add button to view
    self.cancelButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Cancel"];
    
    [self.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.topBar addSubview:self.cancelButton];
}

-(IBAction) handlePan:(UIGestureRecognizer *) sender {
    if (self.hasBlur) {
        CGPoint tapPoint = [sender locationInView:imageView];
        GPUImageGaussianSelectiveBlurFilter* gpu =
            (GPUImageGaussianSelectiveBlurFilter*)self.blurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan) {
            [self showBlurOverlay:YES];
            [gpu setBlurSize:0.0f];
            if (self.isStatic) {
                [self.staticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
            [gpu setBlurSize:0.0f];
            [self.blurOverlayView setCircleCenter:tapPoint];
            [gpu setExcludeCirclePoint:CGPointMake(tapPoint.x/320.0f, tapPoint.y/320.0f)];
        }
        
        if([sender state] == UIGestureRecognizerStateEnded){
            [gpu setBlurSize:kStaticBlurSize];
            [self showBlurOverlay:NO];
            if (self.isStatic) {
                [self.staticPicture processImage];
            }
        }
    }
}

- (IBAction) handleTapToFocus:(UITapGestureRecognizer *)tgr{
	if (!self.isStatic && tgr.state == UIGestureRecognizerStateRecognized) {
		CGPoint location = [tgr locationInView:self.imageView];
		AVCaptureDevice *device = self.stillCamera.inputCamera;
		CGPoint pointOfInterest = CGPointMake(.5f, .5f);
		CGSize frameSize = [[self imageView] frame].size;
		if ([self.stillCamera cameraPosition] == AVCaptureDevicePositionFront) {
            location.x = frameSize.width - location.x;
		}
		pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
		if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                [device setFocusPointOfInterest:pointOfInterest];
                
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                
                self.focusView.center = [tgr locationInView:self.view];
                self.focusView.alpha = 1;
                
                [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
                    self.focusView.alpha = 0;
                } completion:nil];
                
                [device unlockForConfiguration];
			} else {
                NSLog(@"ERROR = %@", error);
			}
		}
	}
}

-(IBAction) handlePinch:(UIPinchGestureRecognizer *) sender {
    if (self.hasBlur) {
        CGPoint midpoint = [sender locationInView:imageView];
        GPUImageGaussianSelectiveBlurFilter* gpu =
            (GPUImageGaussianSelectiveBlurFilter*)self.blurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan) {
            [self showBlurOverlay:YES];
            [gpu setBlurSize:0.0f];
            if (self.isStatic) {
                [self.staticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
            [gpu setBlurSize:0.0f];
            [gpu setExcludeCirclePoint:CGPointMake(midpoint.x/320.0f, midpoint.y/320.0f)];
            self.blurOverlayView.circleCenter = CGPointMake(midpoint.x, midpoint.y);
            CGFloat radius = MAX(MIN(sender.scale*[gpu excludeCircleRadius], 0.6f), 0.15f);
            self.blurOverlayView.radius = radius*320.f;
            [gpu setExcludeCircleRadius:radius];
            sender.scale = 1.0f;
        }
        
        if ([sender state] == UIGestureRecognizerStateEnded) {
            [gpu setBlurSize:kStaticBlurSize];
            [self showBlurOverlay:NO];
            if (self.isStatic) {
                [self.staticPicture processImage];
            }
        }
    }
}

-(void) showFilters {
    if (!self.filterBarIsShowing) {
//        NSLog(@"%s", __FUNCTION__);
        
        //retake button should be hidden if filters are showing
        self.retakeButton.hidden = YES;
        
        [self loadFilters];
        
        [self.filtersToggleButton setSelected:YES];
        self.filtersToggleButton.enabled = NO;
        CGRect sliderScrollFrame = self.filterScrollView.frame;
        sliderScrollFrame.origin.y -= self.filterScrollView.frame.size.height;
        CGRect sliderScrollFrameBackground = self.filtersBackgroundImageView.frame;
        sliderScrollFrameBackground.origin.y -=
        self.filtersBackgroundImageView.frame.size.height-3;
        
        self.filterScrollView.hidden = NO;
        self.filtersBackgroundImageView.hidden = NO;
        [UIView animateWithDuration:0.10
                              delay:0.05
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.filterScrollView.frame = sliderScrollFrame;
                             self.filtersBackgroundImageView.frame = sliderScrollFrameBackground;
                         }
                         completion:^(BOOL finished){
                             self.filtersToggleButton.enabled = YES;
                             self.filterScrollView.hidden = NO;
                             self.filterBarIsShowing = YES;
                         }];
    }
}

-(void) hideFilters {
    if (self.filterBarIsShowing) {
//        NSLog(@"%s", __FUNCTION__);
        [self.filtersToggleButton setSelected:NO];
        CGRect sliderScrollFrame = self.filterScrollView.frame;
        sliderScrollFrame.origin.y += self.filterScrollView.frame.size.height;
        
        CGRect sliderScrollFrameBackground = self.filtersBackgroundImageView.frame;
        sliderScrollFrameBackground.origin.y += self.filtersBackgroundImageView.frame.size.height-3;
        
        [UIView animateWithDuration:0.2
                              delay:0.2
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.filterScrollView.frame = sliderScrollFrame;
                             self.filtersBackgroundImageView.frame = sliderScrollFrameBackground;
                         }
                         completion:^(BOOL finished){
                             
                             self.filtersToggleButton.enabled = YES;
                             self.filterScrollView.hidden = YES;
                             self.filtersBackgroundImageView.hidden = YES;
                             [self deselectAllFilters];
                             self.filterBarIsShowing = NO;
                         }];
    }
}

-(IBAction) toggleFilters:(UIButton *)sender {
//    NSLog(@"%s", __FUNCTION__);
    sender.enabled = NO;
    if (sender.selected){
        [self hideFilters];
    } else {
        [self showFilters];
    }
}

-(void) showBlurOverlay:(BOOL)show{
    if(show){
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
            self.blurOverlayView.alpha = 0.6;
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            self.blurOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }
}

-(void) flashBlurOverlay {
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        self.blurOverlayView.alpha = 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            self.blurOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void) dealloc {
    [self removeAllTargets];
    self.stillCamera = nil;
    self.cropFilter = nil;
    self.filter = nil;
    self.blurFilter = nil;
    self.staticPicture = nil;
    self.blurOverlayView = nil;
    self.focusView = nil;
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.stillCamera stopCameraCapture];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

- (void)configureBlurInstructionLabel {
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 40)];
    instructionLabel.text = @"Touch and drag to adjust focal point";
    [instructionLabel setTextColor:kCreme];
    instructionLabel.textAlignment = UITextAlignmentCenter;
    instructionLabel.lineBreakMode = UILineBreakModeWordWrap;
    instructionLabel.numberOfLines = 6;
    instructionLabel.tag = kInstructionLabelTag;
    [instructionLabel setFont:[UIFont fontWithName:@"OriyaSangamMN" size:16]];
    instructionLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:instructionLabel];
    instructionLabel.hidden = YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    NSLog(@"%s", __FUNCTION__);

    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        UIImage *preview = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        self.imageEditor.sourceImage = image;
        self.imageEditor.previewImage = preview;
        [self.imageEditor reset:NO];
        
        [picker pushViewController:self.imageEditor animated:YES];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"Failed to get asset from library");
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.isStatic) {
        // TODO: fix this hack
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.delegate imagePickerControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        //we cancelled so reset the camera
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self setUpCamera];
        });
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#endif

@end
