//
//  KKLocationController.h
//  AnyPhoto
//
//  Created by Hector Ramos on 4/9/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKLocationController : NSObject <CLLocationManagerDelegate>
@property (strong, readonly) CLLocation *lastLocation;
@property (nonatomic, strong) NSString *lastLocationName;
@property (copy) KKLocationUpdateBlock locationUpdateBlock;

+ (KKLocationController*)sharedInstance;
+ (id)allocWithZone:(NSZone *)zone;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
