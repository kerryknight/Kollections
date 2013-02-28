//
//  KKPhotosBarViewController.h
//  Photos
//
//  Created by Kerry Knight on 1/8/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKPhotosBarViewControllerDelegate <NSObject>
- (void)didSelectPhotoBarItemAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface KKPhotosBarViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
}

@property (nonatomic, strong) id<KKPhotosBarViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, assign) NSInteger section;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
