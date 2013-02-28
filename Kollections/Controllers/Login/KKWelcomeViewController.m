//
//  KKWelcomeViewController.m
//  Kollections
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKWelcomeViewController.h"
#import "KKAppDelegate.h"

@interface KKWelcomeViewController () {
}

-(void)setDisplayNameEqualToAdditionalField;

@end

@implementation KKWelcomeViewController

#pragma mark - UIViewController
- (void)loadView {
//    NSLog(@"%s", __FUNCTION__);
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [backgroundImageView setImage:[UIImage imageNamed:@"Default.png"]];
    self.view = backgroundImageView;
}

- (void)viewWillAppear:(BOOL)animated {
//    NSLog(@"%s", __FUNCTION__);
    [super viewWillAppear:animated];
    
    /**************************************************************************************************/
    //HERE IS WHERE I COULD CHECK TO SEE IF THE USER HAS EVER OPENED THE APP AND SHOW A WALKTHROUGH
    //TUTORIAL PRIOR TO GETTING THEM TO LOG IN; I SHOULD ALLOW THEM TO SKIP IT AND GO STRAIGHT TO THE
    //LOGIN OR SIGN-UP VIEW CONTROLLER FROM THIS TOO  //TODO:
    /**************************************************************************************************/
    
    
    /**************************************************************************************************/
    /**************************************************************************************************/
    
    // If not logged in, present login view controller
    if (![PFUser currentUser]) {
        DLog(@"no current user welcome");
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
//    NSLog(@"%s", __FUNCTION__);
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        DLog(@"User does not exist.");
        [(KKAppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    //check what type of login we have
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //we're logged in with Facebook
        // Check if user is missing a Facebook ID
        if ([KKUtility userHasValidFacebookData:[PFUser currentUser]]) {
            // User has Facebook ID.
            
            // refresh Facebook friends on each launch
            PF_FBRequest *request = [PF_FBRequest requestForMyFriends];
            [request setDelegate:(KKAppDelegate*)[[UIApplication sharedApplication] delegate]];
            [request startWithCompletionHandler:nil];
        } else {
            DLog(@"User missing Facebook ID; Should check to see if they connected via Facebook first before querying again.");
            PF_FBRequest *request = [PF_FBRequest requestForGraphPath:@"me/?fields=name,picture,email"];
            [request setDelegate:(KKAppDelegate*)[[UIApplication sharedApplication] delegate]];
            [request startWithCompletionHandler:nil];
        }
    } /*else if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] ) {
       //we're logged in with Twitter //TODO:
    } */
    else {
        //we're logged with via a Parse account so set the displayName
        [self setDisplayNameEqualToAdditionalField];
    }
}

-(void)setDisplayNameEqualToAdditionalField {
//    NSLog(@"%s", __FUNCTION__);
    //check if it's a parse signee; if so, set their displayName field to the additional field from signup
    //check what type of login we have
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]/* && ![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]*/) {
        //the user signed up via Parse so set their displayName field which we don't set otherwise
        PFUser *user = [PFUser currentUser];
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];//use the _User table name in Parse
        [query whereKey:@"objectId" equalTo:user.objectId];
        query.limit = 1;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    PFObject *_user = [objects objectAtIndex:0];
                    
                    //check if display name is equal to the additional field; if not, save it that way
                    if ([[_user objectForKey:kKKUserAdditionalKey] isEqualToString:[_user objectForKey:kKKUserDisplayNameKey]]) {
                        //names are equal
//                        DLog(@"display names are equal");
                    } else {
                        //names not equal
//                        DLog(@"display names are not equal, so attempt to save");
                        [_user setObject:[_user objectForKey:kKKUserAdditionalKey] forKey:kKKUserDisplayNameKey];
                        [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error) {
                                //success so can update UI appropriately now
//                                DLog(@"saved displayName successfully");
                                //in lieu of making an ADDITIONAL query to Parse for what we just set, go ahead and set it locally to display name
                                [[PFUser currentUser] setObject:[_user objectForKey:kKKUserAdditionalKey] forKey:kKKUserDisplayNameKey];
                            } else {
                                //error saving displayName back to Parse
                            }
                        }];
                    }
                }
            }
        }];
    }
}

@end
