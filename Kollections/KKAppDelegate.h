//
//  KKAppDelegate.h
//  Kollections
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKTabBarController.h"

@interface KKAppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, PF_FBRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) KKTabBarController *tabBarController;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;
- (void)presentLoginViewController;
- (void)presentLoginViewControllerAnimated:(BOOL)animated;
- (void)presentTabBarController;
- (void)logOut;

@end
