//
//  KKImageEditorViewController.m
//  Kollections
//
//  Created by Kerry Knight on 1/25/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "HFImageEditorViewController+SubclassingHooks.h"
#import "KKImageEditorViewController.h"

@interface KKImageEditorViewController () {
    
}
@property (nonatomic, strong) KKToolbarButton *nextButton;
@property (nonatomic, strong) KKToolbarButton *cancelButton;
@end

@implementation KKImageEditorViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.cropSize = CGSizeMake(320, 240);//landscape 3x2
        self.minimumScale = 0.2;
        self.maximumScale = 10;
    }
    return self;
}

- (void)viewDidLoad {
//    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    
    [self configureInstructionLabel];
}

- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    
    //it was a little buggy having the buttons just hide/unhide on appear/disappear so i'm just going to load/reload instead
    [self configureNextButton];
    [self configureCancelButton];
    
}

- (void)viewWillDisappear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillDisappear:animated];
    [self.nextButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
}

- (IBAction)setSquareAction:(id)sender {
    self.cropSize = CGSizeMake(320, 320);
}

- (IBAction)setLandscapeAction:(id)sender {
    self.cropSize = CGSizeMake(320, 240);
}

- (IBAction)setLPortraitAction:(id)sender {
    self.cropSize = CGSizeMake(240, 320);
}

#pragma mark - Custom methods
//the logout button may/may not be kept in this position; temporarily set here for testing purposes 04Jan2013
- (void)configureNextButton {
    //add button to view
    self.nextButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemRightFrame isBackButton:NO andTitle:@"Next"];
    [self.nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.nextButton];
}

- (void)nextButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    
    //show a hud in case it takes awhile to process photo
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview  animated:YES];
    hud.color = kMint4;
    [hud setDimBackground:YES];
    
    [self doneAction:sender];
}

- (void)configureCancelButton {
//    NSLog(@"%s", __FUNCTION__);
    //add button to view
    
    if (self.isCameraPhoto) {
        //make it a legit cancel, not back button
        self.cancelButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:NO andTitle:@"Cancel"];
    } else {
        self.cancelButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Back"];
    }
    
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //hide the default back button
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:self.cancelButton];
}

- (void)cancelButtonAction:(id)sender {
//    NSLog(@"%s", __FUNCTION__);
    if (self.isCameraPhoto) {
        //make it a legit cancel, not back button
        [self.navigationController dismissModalViewControllerAnimated:YES];
        self.doneCallback(nil, YES);//tell our block callback it cancelled itself with no image
    } else {
        //pop back to image picker
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)configureInstructionLabel {
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (window.frame.size.height - 150), self.view.frame.size.width, 90)];
    instructionLabel.text = @"Rotate and size your photo";
    [instructionLabel setTextColor:kCreme];
    instructionLabel.textAlignment = UITextAlignmentCenter;
    instructionLabel.lineBreakMode = UILineBreakModeWordWrap;
    instructionLabel.numberOfLines = 6;
    [instructionLabel setFont:[UIFont fontWithName:@"OriyaSangamMN" size:16]];
    instructionLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:instructionLabel];
}

#pragma mark Hooks
- (void)startTransformHook {
//    self.nextButton.tintColor = [UIColor colorWithRed:0 green:49/255.0f blue:98/255.0f alpha:1];
}

- (void)endTransformHook {
//    self.nextButton.tintColor = [UIColor colorWithRed:0 green:128/255.0f blue:1 alpha:1];
}

@end    