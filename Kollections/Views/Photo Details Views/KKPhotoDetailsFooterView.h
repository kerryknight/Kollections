//
//  KKPhotoDetailsFooterView.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/16/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

@interface KKPhotoDetailsFooterView : UIView

@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic) BOOL hideDropShadow;

+ (CGRect)rectForView;

@end
