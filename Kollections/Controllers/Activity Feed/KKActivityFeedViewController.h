//
//  KKActivityFeedViewController.h
//  Kollections
//
//  Created by Mattieu Gamache-Asselin on 5/9/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "KKActivityCell.h"

@interface KKActivityFeedViewController : UIViewController //PFQueryTableViewController <KKActivityCellDelegate>

+ (NSString *)stringForActivityType:(NSString *)activityType;

@end
