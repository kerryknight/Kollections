//
//  KKPhotoDetailViewController.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKPhotoDetailsHeaderView.h"
#import "KKBaseTextCell.h"

@interface KKPhotoDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, KKPhotoDetailsHeaderViewDelegate, KKBaseTextCellDelegate>

@property (nonatomic, strong) PFObject *photo;

- (id)initWithPhoto:(PFObject*)aPhoto;

@end
