//
//  NSMutableArray+AddOns.h
//  Kollections
//
//  Created by Kerry Knight on 1/21/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (AddOns)

- (void)addUniqueObject:(id)object;
- (void)addUniqueObject:(id)object atIndex:(NSUInteger)index;

@end
