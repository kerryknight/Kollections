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
extern NSString *const KKPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const KKPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const KKPhotoDetailsViewControllerUserCommentedOnPhotoNotification;


#pragma mark - User Info Keys
extern NSString *const KKPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kKKEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kKKInstallationUserKey;
extern NSString *const kKKInstallationChannelsKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kKKActivityClassKey;

// Field keys
extern NSString *const kKKActivityTypeKey;
extern NSString *const kKKActivityFromUserKey;
extern NSString *const kKKActivityToUserKey;
extern NSString *const kKKActivityContentKey;
extern NSString *const kKKActivityPhotoKey;

// Type values
extern NSString *const kKKActivityTypeLike;
extern NSString *const kKKActivityTypeFollow;
extern NSString *const kKKActivityTypeComment;
extern NSString *const kKKActivityTypeJoined;


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


#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kKKPhotoClassKey;

// Field keys
extern NSString *const kKKPhotoPictureKey;
extern NSString *const kKKPhotoThumbnailKey;
extern NSString *const kKKPhotoUserKey;
extern NSString *const kKKPhotoOpenGraphIDKey;


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