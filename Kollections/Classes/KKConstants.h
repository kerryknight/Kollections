//
//  KKConstants.h
//  Kollections
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

typedef enum {
	KKHomeTabBarItemIndex = 0,
    KKSearchTabBarItemIndex = 1,
	KKEmptyTabBarItemIndex = 2,
	KKActivityTabBarItemIndex = 3,
    KKMyProfileTabBarItemIndex = 4
} KKTabBarControllerViewControllerIndex;

#pragma mark - API keys
extern NSString *const kKKParseApplicationID;
extern NSString *const kKKParseApplicationClientKey;
extern NSString *const kKKFacebookAppID;
extern NSString *const kKKTwitterConsumerKey;
extern NSString *const kKKTwitterConsumerSecret;

#define kKKParseEmployeeAccounts [NSArray array]

#define mark - UI Element Positions
#define kKKBarButtonItemLeftFrame CGRectMake(10.0f, 5.0f, 63.0f, 33.0f) 
#define kKKBarButtonItemRightFrame CGRectMake(247.0f, 5.0f, 63.0f, 33.0f) 
#define kDisplayTableCellContentWidth 289.0f
#define kDisplayTableCellContentX 16.0f
#define kDisplayTableHeaderHeight 40.0f
#define kDisplayTableFooterHeight 10.0f
#define kDisplayTableContentRowHeight 100.0f
#define kSETUP_TEXT_OBJECT_WIDTH 280
#define kSETUP_MAX_FOOTNOTE_LINE_LENGTH  40
#define kSETUP_ADDITIONAL_LINE_HEIGHT 20

#pragma mark - Colors
#define kBlack [UIColor colorWithRed:7.0f/255.0f green:6.0f/255.0f blue:6.0f/255.0f alpha:1.0f] //#070606
#define kCreme [UIColor colorWithRed:234.0f/255.0f green:232.0f/255.0f blue:229.0f/255.0f alpha:1.0f] //#eae8e5
#define kGray1 [UIColor colorWithRed:210.0f/255.0f green:209.0f/255.0f blue:206.0f/255.0f alpha:1.0f] //#d2d1ce
#define kGray2 [UIColor colorWithRed:190.0f/255.0f green:197.0f/255.0f blue:192.0f/255.0f alpha:1.0f] //#bec5c0
#define kGray3 [UIColor colorWithRed:173.0f/255.0f green:169.0f/255.0f blue:164.0f/255.0f alpha:1.0f] //#ada9a4
#define kGray4 [UIColor colorWithRed:129.0f/255.0f green:128.0f/255.0f blue:126.0f/255.0f alpha:1.0f] //#81807e
#define kGray5 [UIColor colorWithRed:101.0f/255.0f green:101.0f/255.0f blue:101.0f/255.0f alpha:1.0f] //#656565
#define kGray6 [UIColor colorWithRed:63.0f/255.0f green:63.0f/255.0f blue:64.0f/255.0f alpha:1.0f] //#3f3f40
#define kMint1 [UIColor colorWithRed:190.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f] //#beeeee
#define kMint2 [UIColor colorWithRed:163.0f/255.0f green:209.0f/255.0f blue:205.0f/255.0f alpha:1.0f] //#a3d1cd
#define kMint3 [UIColor colorWithRed:149.0f/255.0f green:219.0f/255.0f blue:218.0f/255.0f alpha:1.0f] //#95dbda
#define kMint4 [UIColor colorWithRed:74.0f/255.0f green:165.0f/255.0f blue:164.0f/255.0f alpha:1.0f] //#4aa5a4
#define kTan1  [UIColor colorWithRed:190.0f/255.0f green:182.0f/255.0f blue:166.0f/255.0f alpha:1.0]

#pragma mark - Fonts
#define kSetupEntryFont [UIFont fontWithName:@"Helvetica-Light" size:14]
#define kSetupFooterFont [UIFont fontWithName:@"Helvetica-LightOblique" size:12]
#define kSetupStringCharacterLimit  40
#define kSetupLongStringCharacterLimit  100


#pragma mark - NSUserDefaults
extern NSString *const kKKUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kKKUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Default App Settings
extern int const kKKMinimumPasswordLength;

#pragma mark - Launch URLs
extern NSString *const kKKLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const KKAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const KKUtilityUserFollowingChangedNotification;
extern NSString *const KKUtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const KKUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const KKTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const KKTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const KKPhotoDetailsTableViewControllerUserDeletedPhotoNotification;
extern NSString *const KKPhotoDetailsTableViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const KKPhotoDetailsTableViewControllerUserCommentedOnPhotoNotification;
extern NSString *const KKKollectionSetupTableDidCreateKollectionNotification;
extern NSString *const KKKollectionSetupTableDidEditKollectionNotification;


#pragma mark - User Info Keys
extern NSString *const KKPhotoDetailsTableViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kKKEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kKKInstallationUserKey;
extern NSString *const kKKInstallationChannelsKey;

#pragma mark - PFObject Kollection Class
// Class key
extern NSString *const kKKKollectionClassKey;

// Field keys
extern NSString *const kKKKollectionTitleKey;
extern NSString *const kKKKollectionUserKey;
extern NSString *const kKKKollectionCategoryKey;
extern NSString *const kKKKollectionIsPrivateKey;
extern NSString *const kKKKollectionPayoutKey;
extern NSString *const kKKKollectionDescriptionKey;
extern NSString *const kKKKollectionCoverPhotoKey;
extern NSString *const kKKKollectionCoverPhotoThumbnailKey;

#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kKKActivityClassKey;

// Field keys
extern NSString *const kKKActivityTypeKey;
extern NSString *const kKKActivityFromUserKey;
extern NSString *const kKKActivityToUserKey;
extern NSString *const kKKActivityContentKey;
extern NSString *const kKKActivityPhotoKey;
extern NSString *const kKKActivityAwardKey;
extern NSString *const kKKActivityKollectionKey;
extern NSString *const kKKActivitySubjectKey;

// Type values
extern NSString *const kKKActivityTypeLike;
extern NSString *const kKKActivityTypeFollow;
extern NSString *const kKKActivityTypeComment;
extern NSString *const kKKActivityTypeJoined;
extern NSString *const kKKActivityTypeCreated;//created a kollection
extern NSString *const kKKActivityTypeSubmitted;//submitted a photo
extern NSString *const kKKActivityTypeAccepted;//accepted a photo submission
extern NSString *const kKKActivityTypeRejected;//rejected a photo submission
extern NSString *const kKKActivityTypeExpired;//didn't moderate photo in time so it was released


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kKKUserDisplayNameKey;
extern NSString *const kKKUserFacebookIDKey;
extern NSString *const kKKUserPhotoIDKey;
extern NSString *const kKKUserProfilePicSmallKey;
extern NSString *const kKKUserProfilePicMediumKey;
extern NSString *const kKKUserFacebookFriendsKey;
extern NSString *const kKKUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kKKUserPrivateChannelKey;
extern NSString *const kKKUserAdditionalKey;


#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kKKPhotoClassKey;

// Field keys
extern NSString *const kKKPhotoPictureKey;
extern NSString *const kKKPhotoThumbnailKey;
extern NSString *const kKKPhotoUserKey;
extern NSString *const kKKPhotoOpenGraphIDKey;
extern NSString *const kKKPhotoLocationKey;

#pragma mark - PFObject Category Class
// Class key
extern NSString *const kKKCategoryClassKey;

// Field keys
extern NSString *const kKKCategoryTitleKey;
extern NSString *const kKKCategoryObjectIdKey;

#pragma mark - PFObject Subject Class
// Class key
extern NSString *const kKKSubjectClassKey;

// Field keys
extern NSString *const kKKSubjectTitleKey;
extern NSString *const kKKSubjectDescriptionKey;
extern NSString *const kKKSubjectPayoutKey;
extern NSString *const kKKSubjectKollectionKey;
extern NSString *const kKKSubjectOrderingKey;


#pragma mark - Cached Photo Attributes
// keys
extern NSString *const kKKPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kKKPhotoAttributesLikeCountKey;
extern NSString *const kKKPhotoAttributesLikersKey;
extern NSString *const kKKPhotoAttributesCommentCountKey;
extern NSString *const kKKPhotoAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kKKUserAttributesPhotoCountKey;
extern NSString *const kKKUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kKKPushPayloadPayloadTypeKey;
extern NSString *const kKKPushPayloadPayloadTypeActivityKey;

extern NSString *const kKKPushPayloadActivityTypeKey;
extern NSString *const kKKPushPayloadActivityLikeKey;
extern NSString *const kKKPushPayloadActivityCommentKey;
extern NSString *const kKKPushPayloadActivityFollowKey;

extern NSString *const kKKPushPayloadFromUserObjectIdKey;
extern NSString *const kKKPushPayloadToUserObjectIdKey;
extern NSString *const kKKPushPayloadPhotoObjectIdKey;