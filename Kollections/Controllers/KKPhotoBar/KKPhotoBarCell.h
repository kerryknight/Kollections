//
//  KKPhotoBarCell.h
//  Kollections
//
//  Created by Kerry Knight on 1/29/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPhotosBarViewController.h"

@interface KKPhotoBarCell : UITableViewCell

@property (nonatomic, strong) KKPhotosBarViewController *kb;
@property (nonatomic, strong) UILabel *noPhotosLabel;

@end
