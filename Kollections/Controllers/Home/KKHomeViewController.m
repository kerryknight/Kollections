//
//  KKHomeViewController.m
//  Kollections
//
//  Created by Héctor Ramos on 5/2/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKHomeViewController.h"
#import "KKSettingsActionSheetDelegate.h"
#import "KKSettingsButtonItem.h"
#import "KKFindFriendsViewController.h"
#import "MBProgressHUD.h"

@interface KKHomeViewController ()
@property (nonatomic, strong) KKSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation KKHomeViewController
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar.png"]];
//
//    self.navigationItem.rightBarButtonItem = [[KKSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
//    
//    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake( 33.0f, 96.0f, 253.0f, 173.0f);
//    [button setBackgroundImage:[UIImage imageNamed:@"HomeTimelineBlank.png"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.blankTimelineView addSubview:button];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kkTitleBarLogo.png"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"kkMainBG.png"]]];//set background image
    
//    UIView *whiteBG = [[UIView alloc] initWithFrame:self.view.bounds];
//    whiteBG.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:whiteBG];
}


#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult] & !self.firstLaunch) {
        self.tableView.scrollEnabled = NO;
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }    
}


#pragma mark - ()

- (void)settingsButtonAction:(id)sender {
    self.settingsActionSheetDelegate = [[KKSettingsActionSheetDelegate alloc] initWithNavigationController:self.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self.settingsActionSheetDelegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"My Profile",@"Find Friends",@"Log Out", nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)inviteFriendsButtonAction:(id)sender {
    KKFindFriendsViewController *detailViewController = [[KKFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}
@end
