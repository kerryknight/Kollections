//
//  KKEditPhotoViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

@interface KKEditPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) BOOL isProfilePhoto;//we don't want to upload per usual if this is the case

- (id)initWithImage:(UIImage *)aImage;

@end
