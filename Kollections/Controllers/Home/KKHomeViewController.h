//
//  KKHomeViewController.h
//  Kollections
//
//  Created by Héctor Ramos on 5/3/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKPhotoTimelineViewController.h"

@interface KKHomeViewController : KKPhotoTimelineViewController <SRRefreshDelegate> {
    
}

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;

@end
