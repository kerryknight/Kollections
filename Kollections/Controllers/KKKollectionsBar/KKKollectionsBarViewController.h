//
//  KKKollectionsBarViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/8/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKKollectionsBarViewControllerDelegate <NSObject>
- (void)didTouchKollectionItemAtIndex:(NSInteger)index;
@end

@interface KKKollectionsBarViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
}

@property (nonatomic, strong) id<KKKollectionsBarViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *kollections;
@property (nonatomic, strong) NSString *identifier;
@end
