//
//  NSArray+Class.m
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 05/06/15.
//  Copyright (c) 2015 Incepteam. All rights reserved.
//

#import "NSArray+Class.h"

@implementation NSArray (Class)

- (NSEnumerator *)objectEnumeratorForClass:(Class)clss {
    NSMutableArray *classObjects = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    for (id obj in self) {
        if ([obj isKindOfClass:clss]) {
            [classObjects addObject:obj];
        }
    }
    
    return classObjects.objectEnumerator;
}

- (NSArray *)objectsForClass:(Class)clss {
    return [self objectEnumeratorForClass:clss].allObjects;
}

@end
