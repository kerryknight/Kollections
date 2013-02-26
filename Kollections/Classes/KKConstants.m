//
//  KKConstants.m
//  Kollections
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "KKConstants.h"

#pragma mark - API keys
NSString *const kKKParseApplicationID           = @"Jv76GJn1SMaqkexXQWiO41enTxhsPaB6uybce1eb";
NSString *const kKKParseApplicationClientKey    = @"SiYXIwtpg1WtnycS4KV19QHQDPBaclKe05rScQjO";
NSString *const kKKFacebookAppID                = @"133566976797599";
NSString *const kKKTwitterConsumerKey           = @"Sud9crv4umTDRXDzIJELA";
NSString *const kKKTwitterConsumerSecret        = @"1C4tmO120pNAYzLMQ5B4TXqoBhNVx67uNaKY8Uzc6k";

#pragma mark - NSUserDefaults
NSString *const kKKUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.kerryknight.Kollections.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kKKUserDefaultsCacheFacebookFriendsKey                     = @"com.kerryknight.Kollections.userDefaults.cache.facebookFriends";

#pragma mark - Default App Settings
int const kKKMinimumPasswordLength = 6;

#pragma mark - Launch URLs

NSString *const kKKLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const KKAppDelegateApplicationDidReceiveRemoteNotification           = @"com.kerryknight.Kollections.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const KKUtilityUserFollowingChangedNotification                      = @"com.kerryknight.Kollections.utility.userFollowingChanged";
NSString *const KKUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.kerryknight.Kollections.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const KKUtilityDidFinishProcessingProfilePictureNotification         = @"com.kerryknight.Kollections.utility.didFinishProcessingProfilePictureNotification";
NSString *const KKTabBarControllerDidFinishEditingPhotoNotification            = @"com.kerryknight.Kollections.tabBarController.didFinishEditingPhoto";
NSString *const KKTabBarControllerDidFinishImageFileUploadNotification         = @"com.kerryknight.Kollections.tabBarController.didFinishImageFileUploadNotification";
NSString *const KKPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.kerryknight.Kollections.photoDetailsViewController.userDeletedPhoto";
NSString *const KKPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.kerryknight.Kollections.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const KKPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.kerryknight.Kollections.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";

NSString *const KKKollectionSetupTableDidCreateKollectionNotification          =
    @"com.kerryknight.Kollections.setupTableViewController.createdKollectionNotification";
NSString *const KKKollectionSetupTableDidEditKollectionNotification          =
@"com.kerryknight.Kollections.setupTableViewController.editKollectionNotification";


#pragma mark - User Info Keys
NSString *const KKPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kKKEditPhotoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kKKInstallationUserKey = @"user";
NSString *const kKKInstallationChannelsKey = @"channels";

#pragma mark - Kollection Class
// Class key
NSString *const kKKKollectionClassKey = @"Kollection";

// Field keys
NSString *const kKKKollectionUserKey = @"user";
NSString *const kKKKollectionTitleKey = @"title";
NSString *const kKKKollectionCategoryKey = @"category";
NSString *const kKKKollectionIsPrivateKey = @"isPrivate";
NSString *const kKKKollectionPayoutKey = @"payout";
NSString *const kKKKollectionDescriptionKey = @"description";
NSString *const kKKKollectionCoverPhotoKey = @"coverPhotoMedium";
NSString *const kKKKollectionCoverPhotoThumbnailKey = @"coverPhotoThumbnail";

// Type values

#pragma mark - Activity Class
// Class key
NSString *const kKKActivityClassKey = @"Activity";

// Field keys
NSString *const kKKActivityTypeKey        = @"type";
NSString *const kKKActivityFromUserKey    = @"fromUser";
NSString *const kKKActivityToUserKey      = @"toUser";
NSString *const kKKActivityContentKey     = @"content";
NSString *const kKKActivityPhotoKey       = @"photo";
NSString *const kKKActivityAwardKey       = @"award";
NSString *const kKKActivityKollectionKey  = @"kollection";
NSString *const kKKActivitySubjectKey     = @"subject";

// Type values
NSString *const kKKActivityTypeLike       = @"like";
NSString *const kKKActivityTypeFollow     = @"follow";
NSString *const kKKActivityTypeComment    = @"comment";
NSString *const kKKActivityTypeJoined     = @"joined";
NSString *const kKKActivityTypeCreated    = @"created";//created a kollection
NSString *const kKKActivityTypeSubmitted  = @"submitted";//submitted a photo
NSString *const kKKActivityTypeAccepted   = @"accepted";//accepted a photo submission
NSString *const kKKActivityTypeRejected   = @"rejected";//rejected a photo submission
NSString *const kKKActivityTypeExpired    = @"expired";//didn't moderate photo in time so it was released

#pragma mark - User Class
// Field keys
NSString *const kKKUserDisplayNameKey                          = @"displayName";
NSString *const kKKUserFacebookIDKey                           = @"facebookId";
NSString *const kKKUserPhotoIDKey                              = @"photoId";
NSString *const kKKUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kKKUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kKKUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kKKUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kKKUserPrivateChannelKey                       = @"channel";
NSString *const kKKUserAdditionalKey                           = @"additional";

#pragma mark - Photo Class
// Class key
NSString *const kKKPhotoClassKey = @"Photo";

// Field keys
NSString *const kKKPhotoPictureKey         = @"image";
NSString *const kKKPhotoThumbnailKey       = @"thumbnail";
NSString *const kKKPhotoUserKey            = @"user";
NSString *const kKKPhotoOpenGraphIDKey     = @"fbOpenGraphID";

#pragma mark - PhotoSubject Class
// Class key
NSString *const kKKPhotoSubjectClassKey    = @"PhotoSubject";

// Field keys
NSString *const kKKPhotoSubjectPhotoKey    = @"photo";
NSString *const kKKPhotoSubjectSubjectKey  = @"subject";

#pragma mark - Category Class
// Class key
NSString *const kKKCategoryClassKey        = @"Category";

// Field keys
NSString *const kKKCategoryTitleKey        = @"title";

#pragma mark - Subject Class
// Class key
NSString *const kKKSubjectClassKey         = @"Subject";

// Field keys
NSString *const kKKSubjectTitleKey         = @"title";
NSString *const kKKSubjectDescriptionKey   = @"description";
NSString *const kKKSubjectPayoutKey        = @"payout";
NSString *const kKKSubjectKollectionKey    = @"kollection";

#pragma mark - Cached Photo Attributes
// keys
NSString *const kKKPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kKKPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kKKPhotoAttributesLikersKey               = @"likers";
NSString *const kKKPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kKKPhotoAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kKKUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kKKUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kKKPushPayloadPayloadTypeKey          = @"p";
NSString *const kKKPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kKKPushPayloadActivityTypeKey     = @"t";
NSString *const kKKPushPayloadActivityLikeKey     = @"l";
NSString *const kKKPushPayloadActivityCommentKey  = @"c";
NSString *const kKKPushPayloadActivityFollowKey   = @"f";

NSString *const kKKPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kKKPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kKKPushPayloadPhotoObjectIdKey    = @"pid";
