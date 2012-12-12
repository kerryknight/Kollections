//
//  KKImageView.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/14/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

@interface KKImageView : UIImageView

@property (nonatomic, strong) UIImage *placeholderImage;

- (void) setFile:(PFFile *)file;

@end
