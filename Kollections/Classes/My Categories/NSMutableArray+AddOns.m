//
//  NSMutableArray+AddOns.m
//  Kollections
//
//  Created by Kerry Knight on 1/21/13.
//  Copyright (c) 2013 Kerry Knight. All rights reserved.
//

#import "NSMutableArray+AddOns.h"

@implementation NSMutableArray (AddOns)

- (void)addUniqueObject:(id)object {
    if (![self containsObject:object])
        [self addObject:object];
}

- (void)addUniqueObject:(id)object atIndex:(NSUInteger)index {
    if (![self containsObject:object])
        [self insertObject:object atIndex:index];
}

@end
