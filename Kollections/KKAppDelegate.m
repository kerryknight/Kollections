//
//  KKAppDelegate.m
//  Kollections
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKAppDelegate.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "KKCache.h"
#import "KKConstants.h"
#import "KKUtility.h"
#import "KKFunctions.h"
#import "KKLogInViewController.h"
#import "KKSignUpViewController.h"
#import "KKWelcomeViewController.h"
#import "KKHomeViewController.h"
#import "KKSearchViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "KKActivityFeedViewController.h"
#import "KKAccountViewController.h"
#import "KKPhotoDetailsViewController.h"

@interface KKAppDelegate () {
    NSMutableData *_data;
    BOOL firstLaunch;
}

@property (nonatomic, strong) KKWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) KKHomeViewController *homeViewController;
@property (nonatomic, strong) KKActivityFeedViewController *activityViewController;
@property (nonatomic, strong) KKSearchViewController *searchViewController;
@property (nonatomic, strong) KKAccountViewController *myProfileViewController;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation KKAppDelegate

@synthesize networkStatus;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //    NSLog(@"%s", __FUNCTION__);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // ****************************************************************************
    // Fill in with your Parse, Facebook and Twitter credentials:
    // ****************************************************************************
    
    // ****************************************************************************
    // Uncomment and fill in with your Parse credentials:
    [Parse setApplicationId:kKKParseApplicationID clientKey:kKKParseApplicationClientKey];
    //
    // Facebook App Id:
    [PFFacebookUtils initializeWithApplicationId:kKKFacebookAppID];
    //
    // Set the Twitter connection parameters
    [PFTwitterUtils initializeWithConsumerKey:kKKTwitterConsumerKey consumerSecret:kKKTwitterConsumerSecret];
    // ****************************************************************************
    //    [PFUser enableAutomaticUser];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
    
    PFACL *defaultACL = [PFACL ACL];
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    self.welcomeViewController = [[KKWelcomeViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [self handlePush:launchOptions];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    return YES;
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

#pragma mark - PFLogInViewControllerDelegate
- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    //    NSLog(@"%s", __FUNCTION__);
    // Create the log in view controller
    PFLogInViewController *logInViewController = [[KKLogInViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsLogInButton /*| PFLogInFieldsDismissButton*/ | PFLogInFieldsPasswordForgotten];
    
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"user_about_me", @"friends_about_me", nil]];
    
    // Create the sign up view controller
    PFSignUpViewController *signUpViewController = [[KKSignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    //main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        // Present the log in view controller
        [self.welcomeViewController presentViewController:logInViewController animated:YES completion:NULL];
    });
}


- (void)presentLoginViewController {
    //    NSLog(@"%s", __FUNCTION__);
    [self presentLoginViewControllerAnimated:YES];
}

// Called on successful login. This is likely to be the place where we register
// the user to the "user_xxxxxxxx" channel
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"%s", __FUNCTION__);
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
        [self.hud setLabelText:@"Loading"];
        [self.hud setDimBackground:YES];
    }
    
    //check what type of login we have
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //we're logged in with Facebook so request the user's name and pic data
        PF_FBRequest *request = [PF_FBRequest requestForGraphPath:@"me/?fields=name,picture"];
        [request setDelegate:self];
        [request startWithCompletionHandler:NULL];
    } else if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] ) {
        //we're logged in with Twitter //UPDATE
    } else {
        //we're logged with via a Parse account
    }
    
    // Subscribe to private push channel
    if (user) {
        NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
        // Add the user to the installation so we can track the owner of the device
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kKKInstallationUserKey];
        // Subscribe user to private channel
        [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kKKInstallationChannelsKey];
        // Save installation object
        [[PFInstallation currentInstallation] saveEventually];
        [user setObject:privateChannelName forKey:kKKUserPrivateChannelKey];
    }
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    
    NSLog(@"Failed to log in with error: %@", error);
    alertMessage(@"Uh oh. Something happened and logging in failed with error: %@. Please try again.", [error localizedDescription]);
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    NSLog(@"%s", __FUNCTION__);
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        //make sure all fields are filled in
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
        //ensure password is long enough
        if ([key isEqualToString:@"password"] && field.length < kKKMinimumPasswordLength) {
            alertMessage(@"Password must be at least %i characters.", kKKMinimumPasswordLength);
            informationComplete = NO;
            return informationComplete;
        }
        
        //check the characters used in the password field; new passwords must contain at least 1 digit
        NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        if ([key isEqualToString:@"password"] && [field rangeOfCharacterFromSet:set].location == NSNotFound) {
            //no numbers found
            alertMessage(@"Password must contain at least one number");
            informationComplete = NO;
            return informationComplete;
        }
        
        //ensure our display name doesn't include any special characters so we don't get lots of dicks and stuff for names 8======D 
        set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
        if ([key isEqualToString:@"password"] && [field rangeOfCharacterFromSet:set].location != NSNotFound) {
            //special characters found
            alertMessage(@"Display names can only contain letters and numbers.");
            informationComplete = NO;
            return informationComplete;
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    //    NSLog(@"%s", __FUNCTION__);
    [self.welcomeViewController dismissViewControllerAnimated:YES completion:NULL];
    
    [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Please look for an email asking you to verify your email address to get the most from Kollections. Now, get started by contributing to someone's kollection or create your own!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

#pragma mark - Tab Bar Controller
- (void)presentTabBarController {
    //    NSLog(@"%s", __FUNCTION__);
    self.tabBarController = [[KKTabBarController alloc] init];
    self.homeViewController = [[KKHomeViewController alloc] init];
    self.searchViewController = [[KKSearchViewController alloc] init];
    self.activityViewController = [[KKActivityFeedViewController alloc] init];
    self.myProfileViewController = [[KKAccountViewController alloc] init];
    
    //I'LL NEED TO USE THESE COMMENTED OUT PARTS TO INITIALIZE MY TABLE STYLES ONCE I GET THAT FAR
    //INSTEAD OF USING THE ABOVE INITS LIKE I AM TO JUST GET THINGS UP AND RUNNING  //UPDATE
    //    self.homeViewController = [[KKHomeFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    //    [self.homeViewController setFirstLaunch:firstLaunch];
    //    self.activityViewController = [[KKActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    
    //set up all the individual navigation controllers
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:self.searchViewController];
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *myProfileNavigationController = [[UINavigationController alloc] initWithRootViewController:self.myProfileViewController];
    
    [KKUtility addBottomDropShadowToNavigationBarForNavigationController:homeNavigationController];
    [KKUtility addBottomDropShadowToNavigationBarForNavigationController:searchNavigationController];
    [KKUtility addBottomDropShadowToNavigationBarForNavigationController:emptyNavigationController];
    [KKUtility addBottomDropShadowToNavigationBarForNavigationController:activityFeedNavigationController];
    [KKUtility addBottomDropShadowToNavigationBarForNavigationController:myProfileNavigationController];
    
    //SET UP THE TAB BAR BUTTON GRAPHICS
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Feed" image:nil tag:0];
    [homeTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"42-photosW.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"42-photos.png"]];
    [homeTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor darkGrayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    [homeTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    UITabBarItem *searchTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:nil tag:1];
    [searchTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"06-magnifyW.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"06-magnify.png"]];
    [searchTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor darkGrayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    [searchTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    UITabBarItem *cameraTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Camera" image:nil tag:2];
    [cameraTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"86-cameraW.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"86-camera.png"]];
    [cameraTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor darkGrayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    [cameraTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Activity" image:nil tag:3];
    [activityFeedTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"166-newspaperW.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"166-newspaper.png"]];
    [activityFeedTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor darkGrayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    [activityFeedTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    UITabBarItem *myProfileTabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Profile" image:nil tag:4];
    [myProfileTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"111-userW.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"111-user.png"]];
    [myProfileTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor darkGrayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    [myProfileTabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [searchNavigationController setTabBarItem:searchTabBarItem];
    [emptyNavigationController setTabBarItem:cameraTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityFeedTabBarItem];
    [myProfileNavigationController setTabBarItem:myProfileTabBarItem];
    
    [self.tabBarController setDelegate:self];
    [self.tabBarController setViewControllers:[NSArray arrayWithObjects:homeNavigationController, searchNavigationController, emptyNavigationController, activityFeedNavigationController, myProfileNavigationController, nil]];
    
    [self.navController setViewControllers:[NSArray arrayWithObjects:self.welcomeViewController, self.tabBarController, nil] animated:NO];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound];
    
    //check what type of login we have
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //we're logged in with Facebook so request the user's name and pic data
        NSLog(@"Downloading user's profile picture");
        // Download user's profile picture
        NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:kKKUserFacebookIDKey]]];
        NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
        [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    } else if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] ) {
        //we're logged in with Twitter //UPDATE
    } else {
        //we're logged with via a Parse account
    }
}


#pragma mark - Facebook
//Facebook OAuth - one of these URL methods will be used (based on target iOS version) to enable Facebook's Single-Sign On feature
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%s", __FUNCTION__);
    BOOL handledActionURL = [self handleActionURL:url];
    
    if (handledActionURL) {
        return YES;
    }
    
    return [PFFacebookUtils handleOpenURL:url];
}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    NSLog(@"%s", __FUNCTION__);
//    return [PFFacebookUtils handleOpenURL:url];
//}

#pragma mark - PF_FBRequestDelegate
- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    NSLog(@"%s", __FUNCTION__);
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary *friendData in data) {
            [facebookIds addObject:[friendData objectForKey:@"id"]];
        }
        
        // cache friend data
        [[KKCache sharedCache] setFacebookFriends:facebookIds];
        
        if (![[PFUser currentUser] objectForKey:kKKUserAlreadyAutoFollowedFacebookFriendsKey]) {
            [self.hud setLabelText:@"Following Friends"];
            firstLaunch = YES;
            
            [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:kKKUserAlreadyAutoFollowedFacebookFriendsKey];
            NSError *error = nil;
            
            // find common Facebook friends already using Kollections
            PFQuery *facebookFriendsQuery = [PFUser query];
            [facebookFriendsQuery whereKey:kKKUserFacebookIDKey containedIn:facebookIds];
            
//            // auto-follow Parse employees
//            PFQuery *parseEmployeesQuery = [PFUser query];
//            [parseEmployeesQuery whereKey:kKKUserFacebookIDKey containedIn:kKKParseEmployeeAccounts];
            
            // combined query
            PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:/*parseEmployeesQuery,*/facebookFriendsQuery, nil]];
            
            
            //backgrounded version of query
            __block NSArray *kollectionFiends = [NSArray array];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    // There was an error
                } else {
                    // objects has all the Posts the current user liked.
                    kollectionFiends = [NSArray arrayWithArray:objects];
                }
            }];
            
            NSArray *kollectionsFriends = [query findObjects:&error];
            
            if (!error) {
                [kollectionsFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                    PFObject *joinActivity = [PFObject objectWithClassName:kKKActivityClassKey];
                    [joinActivity setObject:[PFUser currentUser] forKey:kKKActivityFromUserKey];
                    [joinActivity setObject:newFriend forKey:kKKActivityToUserKey];
                    [joinActivity setObject:kKKActivityTypeJoined forKey:kKKActivityTypeKey];
                    
                    PFACL *joinACL = [PFACL ACL];
                    [joinACL setPublicReadAccess:YES];
                    joinActivity.ACL = joinACL;
                    
                    // make sure our join activity is always earlier than a follow
                    [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [KKUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                            // This block will be executed once for each friend that is followed.
                            // We need to refresh the timeline when we are following at least a few friends
                            // Use a timer to avoid refreshing innecessarily
                            if (self.autoFollowTimer) {
                                [self.autoFollowTimer invalidate];
                            }
                            
                            self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                        }];
                    }];
                }];
            }
            
            if (![self shouldProceedToMainInterface:[PFUser currentUser]]) {
                [self logOut];
                return;
            }
            
            if (!error) {
                [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                if (kollectionsFriends.count > 0) {
                    self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                    [self.hud setDimBackground:YES];
                    [self.hud setLabelText:@"Following Friends"];
                } else {
                    //                    [self.homeViewController loadObjects]; //UPDATE
                }
            }
        }
        
        [[PFUser currentUser] saveEventually];
    } else {
        [self.hud setLabelText:@"Creating Profile"];
        NSString *facebookId = [result objectForKey:@"id"];
        NSString *facebookName = [result objectForKey:@"name"];
        
        if (facebookName && facebookName != 0) {
            [[PFUser currentUser] setObject:facebookName forKey:kKKUserDisplayNameKey];
        }
        
        if (facebookId && facebookId != 0) {
            [[PFUser currentUser] setObject:facebookId forKey:kKKUserFacebookIDKey];
        }
        
        PF_FBRequest *request = [PF_FBRequest requestForMyFriends];
        [request setDelegate:self];
        [request startWithCompletionHandler:nil];
    }
}

- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
             isEqualToString: @"OAuthException"]) {
            NSLog(@"The facebook token was invalidated");
            [self logOut];
        }
    }
}


#pragma mark - Notifications
// Called every time the app is launched, so if a user is logged in, we ensure he is
// registered to the proper channel
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    //    NSLog(@"%s", __FUNCTION__);
    [PFPush storeDeviceToken:newDeviceToken];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    [[PFInstallation currentInstallation] addUniqueObject:@"" forKey:kKKInstallationChannelsKey];
    if ([PFUser currentUser]) {
        // Make sure they are subscribed to their private push channel
        NSString *privateChannelName = [[PFUser currentUser] objectForKey:kKKUserPrivateChannelKey];
        if (privateChannelName && privateChannelName.length > 0) {
            NSLog(@"Subscribing user to %@", privateChannelName);
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kKKInstallationChannelsKey];
        }
    }
    // Save the added channel(s)
    [[PFInstallation currentInstallation] saveEventually];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //    NSLog(@"%s", __FUNCTION__);
    //    [PFPush handlePush:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KKAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > KKActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[[self.tabBarController viewControllers] objectAtIndex:KKActivityTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
        }
    }
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    //    NSLog(@"%s", __FUNCTION__);
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:[[tabBarController viewControllers] objectAtIndex:KKEmptyTabBarItemIndex]];
}

- (void)logOut {
    // clear cache
    [[KKCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKKUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKKUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by clearing the channels key (leaving only broadcast enabled).
    [[PFInstallation currentInstallation] setObject:@[@""] forKey:kKKInstallationChannelsKey];
    [[PFInstallation currentInstallation] removeObjectForKey:kKKInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Log out
    [PFUser logOut];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.homeViewController = nil;
    self.activityViewController = nil;
    self.searchViewController = nil;
    self.myProfileViewController = nil;
}

#pragma mark - KKAppDelegate life cycle

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%s", __FUNCTION__);
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s", __FUNCTION__);
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"%s", __FUNCTION__);
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"%s", __FUNCTION__);
    [KKUtility processFacebookProfilePictureData:_data];
}

#pragma mark - ()

- (void)setupAppearance {
    NSLog(@"%s", __FUNCTION__);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.498f green:0.388f blue:0.329f alpha:1.0f]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],UITextAttributeTextColor,
                                                          [UIColor colorWithWhite:0.0f alpha:0.750f],UITextAttributeTextShadowColor,
                                                          [NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)],UITextAttributeTextShadowOffset,
                                                          nil]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"kkBackgroundNavBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[UIImage imageNamed:@"kkRegularNavBarButton.png"] forState:UIControlStateNormal];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[UIImage imageNamed:@"kkRegularNavBarButtonSelected.png"] forState:UIControlStateHighlighted];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"kkBackButtonNavBar.png"]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"kkBackButtonNavBarSelected.png"]
                                                      forState:UIControlStateSelected
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0f],UITextAttributeTextColor,
                                                          [UIColor colorWithWhite:0.0f alpha:0.750f],UITextAttributeTextShadowColor,
                                                          [NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)],UITextAttributeTextShadowOffset,
                                                          nil] forState:UIControlStateNormal];
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:32.0f/255.0f green:19.0f/255.0f blue:16.0f/255.0f alpha:1.0f]];
}

- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:ReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostName: @"api.parse.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions {
    //    NSLog(@"%s", __FUNCTION__);
    //    If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KKAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if ([PFUser currentUser]) {
//            if the push notification payload references a photo, we will attempt to push this view controller into view
            NSString *photoObjectId = [remoteNotificationPayload objectForKey:kKKPushPayloadPhotoObjectIdKey];
            NSString *fromObjectId = [remoteNotificationPayload objectForKey:kKKPushPayloadFromUserObjectIdKey];
            if (photoObjectId && photoObjectId.length > 0) {
//                check if this photo is already available locally.
                
                PFObject *targetPhoto = [PFObject objectWithoutDataWithClassName:kKKPhotoClassKey objectId:photoObjectId];
                for (PFObject *photo in self.homeViewController.objects) {
                    if ([photo.objectId isEqualToString:photoObjectId]) {
                        NSLog(@"Found a local copy");
                        targetPhoto = photo;
                        break;
                    }
                }
                
//                if we have a local copy of this photo, this won't result in a network fetch
                [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:KKHomeTabBarItemIndex];
                        [self.tabBarController setSelectedViewController:homeNavigationController];
                        
                        KKPhotoDetailsViewController *detailViewController = [[KKPhotoDetailsViewController alloc] initWithPhoto:object];
                        [homeNavigationController pushViewController:detailViewController animated:YES];
                    }
                }];
            } else if (fromObjectId && fromObjectId.length > 0) {
//                load fromUser's profile
                
                PFQuery *query = [PFUser query];
                query.cachePolicy = kPFCachePolicyCacheElseNetwork;
                [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                    if (!error) {
                        UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:KKHomeTabBarItemIndex];
                        [self.tabBarController setSelectedViewController:homeNavigationController];
                        
                        KKAccountViewController *accountViewController = [[KKAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                        [accountViewController setUser:(PFUser *)user];
                        [homeNavigationController pushViewController:accountViewController animated:YES];
                    }
                }];
                
            }
        }
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    //    NSLog(@"%s", __FUNCTION__);
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    //    NSLog(@"%s", __FUNCTION__);
    if ([KKUtility userHasValidFacebookData:[PFUser currentUser]]) {
        NSLog(@"User has valid Facebook data, granting permission to use app.");
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];
        
        [self.navController dismissModalViewControllerAnimated:YES];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleActionURL:(NSURL *)url {
    //    NSLog(@"%s", __FUNCTION__);
    if ([[url host] isEqualToString:kKKLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    }
    
    return NO;
}

//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    //    NSLog(@"%s", __FUNCTION__);
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    //    NSLog(@"Reachability changed: %@", curReach);
    networkStatus = [curReach currentReachabilityStatus];
    
    if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
        // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
        // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
        [self.homeViewController loadObjects];
    }
}

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    //    NSLog(@"%s", __FUNCTION__);
    if ([result boolValue]) {
        NSLog(@"Kollections successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"Kollections failed to subscribe to push notifications on the broadcast channel.");
    }
}

@end
