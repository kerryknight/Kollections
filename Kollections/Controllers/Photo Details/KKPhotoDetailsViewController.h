//
//  KKPhotoDetailsViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/9/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPhotoDetailsTableViewController.h"

@interface KKPhotoDetailsViewController : UIViewController <KKPhotoDetailsTableViewControllerDelegate> {
    
}

@property (nonatomic, strong) PFObject *photo;//we'll either pass in a single photo or an array of photos (photosArray)
@property (nonatomic, strong) NSArray *photosArray;//index 0 will contain out clicked on photo

@end
