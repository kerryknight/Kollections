//
//  KKPhotoDetailsHeaderView.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

@protocol KKPhotoDetailsHeaderViewDelegate;

@interface KKPhotoDetailsHeaderView : UIView

/*! @name Managing View Properties */

/// The photo displayed in the view
@property (nonatomic, strong, readonly) PFObject *photo;

/// The user that took the photo
@property (nonatomic, strong, readonly) PFUser *photographer;

/// Array of the users that liked the photo
@property (nonatomic, strong) NSArray *likeUsers;

/// Heart-shaped like button
@property (nonatomic, strong, readonly) UIButton *likeButton;

/*! @name Delegate */
@property (nonatomic, strong) id<KKPhotoDetailsHeaderViewDelegate> delegate;

+ (CGRect)rectForView;

- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto;
- (id)initWithFrame:(CGRect)frame photo:(PFObject*)aPhoto photographer:(PFUser*)aPhotographer likeUsers:(NSArray*)theLikeUsers;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;
@end

/*!
 The protocol defines methods a delegate of a KKPhotoDetailsHeaderView should implement.
 */
@protocol KKPhotoDetailsHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the photograper
 */
- (void)photoDetailsHeaderView:(KKPhotoDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end