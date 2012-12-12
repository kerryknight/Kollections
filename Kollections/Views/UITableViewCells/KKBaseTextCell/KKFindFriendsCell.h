//
//  KKFindFriendsCell.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/31/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

@class KKProfileImageView;
@protocol KKFindFriendsCellDelegate;

@interface KKFindFriendsCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id<KKFindFriendsCellDelegate> delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) UIButton *followButton;

/*! Setters for the cell's content */
- (void)setUser:(PFUser *)user;

- (void)didTapUserButtonAction:(id)sender;
- (void)didTapFollowButtonAction:(id)sender;

/*! Static Helper methods */
+ (CGFloat)heightForCell;

@end

/*!
 The protocol defines methods a delegate of a KKBaseTextCell should implement.
 */
@protocol KKFindFriendsCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(KKFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser;
- (void)cell:(KKFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser;

@end
