//
//  KKKollectionViewCell.m
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKKollectionViewCell.h"
#import "KKKollectionTitleLabel.h"
#import "KKSideScrollingTableViewConstants.h"

@implementation KKKollectionViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    NSLog(@"%s", __FUNCTION__);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(kKollectionCellHorizontalInnerPadding, kKollectionCellVerticalInnerPadding, kCellWidth - kKollectionCellHorizontalInnerPadding * 2, kCellHeight - kKollectionCellVerticalInnerPadding * 2)];
        self.thumbnail.opaque = YES;
        
        [self.contentView addSubview:self.thumbnail];
        
        self.titleLabel = [[KKKollectionTitleLabel alloc] initWithFrame:CGRectMake(0, self.thumbnail.frame.size.height * 0.632, self.thumbnail.frame.size.width, self.thumbnail.frame.size.height * 0.37)];
        self.titleLabel.opaque = YES;
        [self.titleLabel setPersistentBackgroundColor:kMint3];
        self.titleLabel.textColor = kGray6;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        self.titleLabel.numberOfLines = 2;
        [self.thumbnail addSubview:self.titleLabel];
        
        self.backgroundColor = [UIColor purpleColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.thumbnail.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor greenColor];
        
        self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)reuseIdentifier {
    return @"KKKollectionViewCell";
}

@end
