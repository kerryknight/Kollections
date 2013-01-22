//
//  KKKollectionTableViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKKollectionsBarViewController.h"
#import "KKEditKollectionViewController.h"

@interface KKKollectionTableViewController : PFQueryTableViewController <KKKollectionsBarViewControllerDelegate, KKEditKollectionViewControllerDelegate> {
    
}

- (id)initWithKollection:(PFObject *)kollection;

@end
