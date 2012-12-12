//
//  KKPhotoHeaderView.h
//  Kollections
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

typedef enum {
    KKPhotoHeaderButtonsNone = 0,
    KKPhotoHeaderButtonsLike = 1 << 0,
    KKPhotoHeaderButtonsComment = 1 << 1,
    KKPhotoHeaderButtonsUser = 1 << 2,
    
    KKPhotoHeaderButtonsDefault = KKPhotoHeaderButtonsLike | KKPhotoHeaderButtonsComment | KKPhotoHeaderButtonsUser
} KKPhotoHeaderButtons;

@protocol KKPhotoHeaderViewDelegate;

@interface KKPhotoHeaderView : UIView

/*! @name Creating Photo Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (id)initWithFrame:(CGRect)frame buttons:(KKPhotoHeaderButtons)otherButtons;

/// The photo associated with this view
@property (nonatomic,strong) PFObject *photo;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) KKPhotoHeaderButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Like Photo button
@property (nonatomic,readonly) UIButton *likeButton;

/// The Comment On Photo button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <KKPhotoHeaderViewDelegate> delegate;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated photo is liked by the user
 */
- (void)setLikeStatus:(BOOL)liked;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableLikeButton:(BOOL)enable;

@end


/*!
 The protocol defines methods a delegate of a KKPhotoHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol KKPhotoHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)photoHeaderView:(KKPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the like photo button is tapped
 @param photo the PFObject for the photo that is being liked or disliked
 */
- (void)photoHeaderView:(KKPhotoHeaderView *)photoHeaderView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo;

/*!
 Sent to the delegate when the comment on photo button is tapped
 @param photo the PFObject for the photo that will be commented on
 */
- (void)photoHeaderView:(KKPhotoHeaderView *)photoHeaderView didTapCommentOnPhotoButton:(UIButton *)button photo:(PFObject *)photo;

@end