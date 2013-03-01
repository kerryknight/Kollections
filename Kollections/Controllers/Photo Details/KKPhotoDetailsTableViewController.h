//
//  KKPhotoDetailViewController.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKPhotoDetailsHeaderView.h"
#import "KKBaseTextCell.h"
#import "SRRefreshView.h"

@protocol KKPhotoDetailsTableViewControllerDelegate <NSObject>
@optional

@end

@interface KKPhotoDetailsTableViewController : PFQueryTableViewController <UITextFieldDelegate, KKPhotoDetailsHeaderViewDelegate, KKBaseTextCellDelegate, SRRefreshDelegate>

@property (nonatomic, strong) id<KKPhotoDetailsTableViewControllerDelegate> delegate;

- (id)initWithPhoto:(PFObject*)aPhoto;

@end
