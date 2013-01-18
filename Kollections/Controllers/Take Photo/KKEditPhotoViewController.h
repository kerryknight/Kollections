//
//  KKEditPhotoViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

typedef enum {
    KKEditPhotoViewPhotoTypeRegularPhoto = 0,
    KKEditPhotoViewPhotoTypeProfilePhoto,
    KKEditPhotoViewPhotoTypeKollectionPhoto
} KKEditPhotoViewPhotoType;

@interface KKEditPhotoViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) KKEditPhotoViewPhotoType photoType;//used to determine how to process the photo

- (id)initWithImage:(UIImage *)aImage;

@end
