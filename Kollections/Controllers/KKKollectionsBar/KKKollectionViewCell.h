//
//  KKKollectionViewCell.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKKollectionTitleLabel;

@interface KKKollectionViewCell : UITableViewCell {
    
}

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) KKKollectionTitleLabel *titleLabel;

@end
