//
//  KKActivityCell.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/14/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKBaseTextCell.h"
@protocol KKActivityCellDelegate;

@interface KKActivityCell : KKBaseTextCell

/*!Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

/*!Set the new state. This changes the background of the cell. */
- (void)setIsNew:(BOOL)isNew;

@end


/*!
 The protocol defines methods a delegate of a KKBaseTextCell should implement.
 */
@protocol KKActivityCellDelegate <KKBaseTextCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(KKActivityCell *)cellView didTapActivityButton:(PFObject *)activity;

@end