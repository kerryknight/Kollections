//
//  KKPhotoTimelineViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKPhotoHeaderView.h"

@interface KKPhotoTimelineViewController : PFQueryTableViewController <KKPhotoHeaderViewDelegate>

- (KKPhotoHeaderView *)dequeueReusableSectionHeaderView;

@end
