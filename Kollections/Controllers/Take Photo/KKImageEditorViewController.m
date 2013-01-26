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
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    
    [self configureNextButton];
    [self configureCancelButton];
}

- (void)viewWillAppear:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    self.nextButton.hidden = NO;//this is hidden if we navigate away
    self.cancelButton.hidden = NO;//this is hidden if we navigate away
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.nextButton.hidden = YES;
    self.cancelButton.hidden = YES;
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
    NSLog(@"%s", __FUNCTION__);
    
    //show a hud in case it takes awhile to process photo
    [MBProgressHUD showHUDAddedTo:self.view.superview animated:NO];
    [self doneAction:sender];
}

- (void)configureCancelButton {
    //add button to view
    self.cancelButton = [[KKToolbarButton alloc] initWithFrame:kKKBarButtonItemLeftFrame isBackButton:YES andTitle:@"Back"];
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //hide the default back button
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar addSubview:self.cancelButton];
}

- (void)cancelButtonAction:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Hooks
- (void)startTransformHook {
//    self.nextButton.tintColor = [UIColor colorWithRed:0 green:49/255.0f blue:98/255.0f alpha:1];
}

- (void)endTransformHook {
//    self.nextButton.tintColor = [UIColor colorWithRed:0 green:128/255.0f blue:1 alpha:1];
}

@end    