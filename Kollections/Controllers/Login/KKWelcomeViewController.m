//
//  KKWelcomeViewController.m
//  Kollections
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKWelcomeViewController.h"
#import "KKAppDelegate.h"

@implementation KKWelcomeViewController

#pragma mark - UIViewController
- (void)loadView {
    NSLog(@"%s", __FUNCTION__);
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [backgroundImageView setImage:[UIImage imageNamed:@"Default.png"]];
    self.view = backgroundImageView;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    
    /**************************************************************************************************/
    //HERE IS WHERE I COULD CHECK TO SEE IF THE USER HAS EVER OPENED THE APP AND SHOW A WALKTHROUGH
    //TUTORIAL PRIOR TO GETTING THEM TO LOG IN; I SHOULD ALLOW THEM TO SKIP IT AND GO STRAIGHT TO THE
    //LOGIN OR SIGN-UP VIEW CONTROLLER FROM THIS TOO  //UPDATE
    /**************************************************************************************************/
    
    
    /**************************************************************************************************/
    /**************************************************************************************************/
    
    // If not logged in, present login view controller
    if (![PFUser currentUser]) {
        [(KKAppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
        return;
    }
    
    // Present Kollections UI
    [(KKAppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}


#pragma mark - ()

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
        [(KKAppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    // Check if user is missing a Facebook ID
    if ([KKUtility userHasValidFacebookData:[PFUser currentUser]]) {
        // User has Facebook ID.
        
        // refresh Facebook friends on each launch
        PF_FBRequest *request = [PF_FBRequest requestForMyFriends];
        [request setDelegate:(KKAppDelegate*)[[UIApplication sharedApplication] delegate]];
        [request startWithCompletionHandler:nil];
    } else {
        NSLog(@"User missing Facebook ID; Should check to see if they connected via Facebook first before querying again.");
        PF_FBRequest *request = [PF_FBRequest requestForGraphPath:@"me/?fields=name,picture,email"];
        [request setDelegate:(KKAppDelegate*)[[UIApplication sharedApplication] delegate]];
        [request startWithCompletionHandler:nil];
    }
}

@end
