//
//  KKPhotoDetailsViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPhotoDetailsTableViewController.h"

@interface KKPhotoDetailsViewController : UIViewController <KKPhotoDetailsTableViewControllerDelegate, UIScrollViewDelegate> {
    
}

@property (nonatomic, strong) PFObject *photo;

@end
