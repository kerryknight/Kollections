//
//  KKKollectionsBarViewController.h
//  Kollections
//
//  Created by Kerry Knight on 1/8/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    KKKollectionTypeMyPublic = 0,
    KKKollectionTypeMyPrivate,
    KKKollectionTypeSubscribedPublic,
    KKKollectionTypeSubscribedPrivate
} KKKollectionType;

@protocol KKKollectionsBarViewControllerDelegate <NSObject>
@optional
- (void)didSelectKollectionBarItemAtIndex:(NSInteger)index ofKollectionType:(KKKollectionType)type shouldCreateNew:(BOOL)yesOrNo;
@end

@interface KKKollectionsBarViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
}

@property (nonatomic, strong) id<KKKollectionsBarViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *kollections;
@property (nonatomic, strong) NSString *identifier;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
