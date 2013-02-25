//
//  KKPhotoBarCell.m
//  Kollections
//
//  Created by Kerry Knight on 1/29/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "KKPhotoBarCell.h"

@implementation KKPhotoBarCell

@synthesize kb, noPhotosLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.kb = [[KKPhotosBarViewController alloc] init];
        kb.view.frame = self.contentView.frame;
        [self.contentView addSubview:kb.view];
        
        self.noPhotosLabel = [[UILabel alloc] init];
        [self.noPhotosLabel setTextColor:kGray4];
        self.noPhotosLabel.textAlignment = UITextAlignmentCenter;
        self.noPhotosLabel.frame = CGRectMake(18.0f, 0.0f, self.contentView.bounds.size.width - 36.0f, 124.0f);
        self.noPhotosLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.noPhotosLabel.numberOfLines = 5;
        [self.noPhotosLabel setFont:[UIFont fontWithName:@"OriyaSangamMN" size:14]];
        [self.noPhotosLabel setBackgroundColor:[UIColor clearColor]];
        self.noPhotosLabel.hidden = YES;
        [self.contentView addSubview:self.noPhotosLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
