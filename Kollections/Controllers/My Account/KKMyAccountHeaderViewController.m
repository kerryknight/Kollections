//
//  KKMyAccountHeaderViewController.m
//  Kollections
//
//  Created by Kerry Knight on 12/17/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKMyAccountHeaderViewController.h"

@interface KKMyAccountHeaderViewController () {
    
}
@property (nonatomic, strong) UIView *toolbarView;

@end

@implementation KKMyAccountHeaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    NSLog(@"%s", __FUNCTION__);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor clearColor];
        
        //move the koins buttons title labels's text insets up a little bit to make room for the added type denotation labels
        //this is easier than subclassing UIButton
        float buttonTitleOffset = -5.0f;
        [self.koinsEarnedButton setTitleEdgeInsets:UIEdgeInsetsMake(buttonTitleOffset, 0.0, 0.0, 0.0)];
        [self.koinsSpentButton setTitleEdgeInsets:UIEdgeInsetsMake(buttonTitleOffset, 0.0, 0.0, 0.0)];
        [self.koinsAvailableButton setTitleEdgeInsets:UIEdgeInsetsMake(buttonTitleOffset, 0.0, 0.0, 0.0)];
        
        //give the display name label a little shadow
        CALayer *displayNameLayer = self.displayNameLabel.layer;
        displayNameLayer.shadowRadius = 0.4;
        displayNameLayer.shadowOffset = CGSizeMake(0, -1);
        displayNameLayer.shadowColor = [[UIColor whiteColor] CGColor];
        displayNameLayer.shadowOpacity = 0.6f;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"%s", __FUNCTION__);
	// Do any additional setup after loading the view.
    
    //add the custom sliding toolbar
    self.toolbarView = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 130.0f, 289.0f, 37.0f)];
    [self.toolbarView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.toolbarView];
    
    self.toolBarViewController = [[KKSideScrollToolBarViewController alloc] init];
    [self addChildViewController:self.toolBarViewController];
    [self.toolbarView addSubview:self.toolBarViewController.view];
    [self.toolBarViewController didMoveToParentViewController:self];
    self.toolBarViewController.segmentTitles = @[@"Kollections", @"Submissions", @"Favorites", @"Followers", @"Following", @"Achievements", @"Store"];
    
    //04Jan2013 not sure if I want these to actually be buttons or not so I'm disabling them for now
    self.followersButton.enabled = NO;
    self.followingButton.enabled = NO;
    self.kollectionsButton.enabled = NO;
    self.submissionsButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setKoinsEarnedButton:nil];
    [self setKoinsSpentButton:nil];
    [self setKoinsAvailableButton:nil];
    [self setDisplayNameLabel:nil];
    [self setFollowerCountLabel:nil];
    [self setFollowingCountLabel:nil];
    [self setKollectionCountLabel:nil];
    [self setSubmissionCountLabel:nil];
    [self setFollowersButton:nil];
    [self setFollowingButton:nil];
    [self setKollectionsButton:nil];
    [self setSubmissionsButton:nil];
    [super viewDidUnload];
}

@end
