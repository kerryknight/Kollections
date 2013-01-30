//
//  KKKollectionTableViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKPhotoBarCell.h"

typedef void(^KKObjectsLoadedCallback)(NSArray *objects);

@protocol KKKollectionTableViewControllerDelegate
@optional
- (void) kollectionTableViewControllerDidLoadSubjects:(NSArray*)subjects;
@end

@interface KKKollectionTableViewController : PFQueryTableViewController <KKPhotosBarViewControllerDelegate> {
    
}

@property (nonatomic, strong) id<KKKollectionTableViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isNetworkBusy;
@property (nonatomic, strong) NSMutableArray *subjectsWithPhotos;
@property (nonatomic, strong) NSMutableArray *subjectList;

- (id)initWithKollection:(PFObject *)kollection;
- (void)createSubjectsWithPhotosArrayWithCompletion:(KKObjectsLoadedCallback)callback;
- (void)reloadCoverPhoto;

@end
