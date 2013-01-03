//
//  KKSideScrollToolBarViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/3/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKSideScrollToolBarViewControllerDelegate <NSObject>
-(void)didTouchToolbarItemAtIndex:(NSInteger)index;
@end

@interface KKSideScrollToolBarViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
}

@property (nonatomic, strong) id<KKSideScrollToolBarViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *segmentTitles;

@end
