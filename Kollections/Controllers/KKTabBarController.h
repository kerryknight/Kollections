//
//  KKTabBarController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/15/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKEditPhotoViewController.h"

@protocol KKTabBarControllerDelegate;

@interface KKTabBarController : UITabBarController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

- (BOOL)shouldPresentPhotoCaptureController;

@end

@protocol KKTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;

@end