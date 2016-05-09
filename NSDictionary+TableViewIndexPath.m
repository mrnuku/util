//
//  NSDictionary+TableViewIndexPath.m
//  util
//
//  Created by Bálint Róbert on 31/03/16.
//  Copyright © 2016 mrnuku. All rights reserved.
//

#import "NSDictionary+TableViewIndexPath.h"
#import <UIKit/UIKit.h>

@implementation NSDictionary (TableViewIndexPath)

/** collects a set of indicies where all sections are unique and rows are undefined
 * @return NSMutableArray with the result
 */
- (NSMutableArray<NSIndexPath *> *)_getUniqueSectionIndicies {
    __block NSMutableArray<NSIndexPath *> *temp = [NSMutableArray new];
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key1, id obj1, BOOL *stop1) {
        NSUInteger idx = [temp indexOfObjectPassingTest:^BOOL(NSIndexPath *obj2, NSUInteger idx2, BOOL *stop2) {
            return (*stop2 = key1.section == obj2.section);
        }];
        
        if (idx == NSNotFound) {
            [temp addObject:key1];
        }
    }];
    
    return temp;
}

- (NSInteger)numberOfUniqueSections {
    return [self _getUniqueSectionIndicies].count;
}

- (NSInteger)maximumIndexOfSections {
    NSArray<NSIndexPath *> *uniqueSectionIndicies = [self _getUniqueSectionIndicies];
    NSInteger maximum = 0;
    
    for (NSIndexPath *path in uniqueSectionIndicies) {
        maximum = MAX(maximum, path.section);
    }
    
    return maximum;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    __block NSInteger count = 0;
    __block NSInteger maximum = 0;
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, id obj, BOOL *stop) {
        if (key.section == section) {
            maximum = MAX(maximum, key.row);
            count++;
        }
    }];
    
    if (count) {
        NSAssert((maximum + 1) == count, @"Found non-continous index set");
    }
    
    return count;
}

@end

@implementation NSMutableDictionary (TableViewIndexPath)

- (void)addArrayAsNewSection:(NSArray *)array {
    NSInteger numSections = [self numberOfUniqueSections];
    
    for (NSInteger i = 0; i < array.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:numSections];
        id obj = [array objectAtIndex:i];
        
        [self setObject:obj forKey:indexPath];
    }
}

- (void)removeSection:(NSInteger)section {
    __block NSMutableArray<NSIndexPath *> *temp = [NSMutableArray new];
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, id obj, BOOL *stop) {
        if (key.section == section) {
            [temp addObject:key];
        }
    }];
    
    for (NSIndexPath *path in temp) {
        [self removeObjectForKey:path];
    }
}

- (void)replaceSection:(NSInteger)section withArray:(NSArray *)array {
    [self removeSection:section];
    
    for (NSInteger i = 0; i < array.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        id obj = [array objectAtIndex:i];
        
        [self setObject:obj forKey:indexPath];
    }
}

- (BOOL)removeIndexPath:(NSIndexPath *)indexPath {
    __block NSMutableArray<NSIndexPath *> *temp = [NSMutableArray new];
    __block NSInteger numRowsInSection = 0;
    
    // get upper indicies
    [self enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, id obj, BOOL *stop) {
        BOOL sameSection = key.section == indexPath.section;
        
        if (sameSection) {
            numRowsInSection++;
            
            if (key.row > indexPath.row) {
                [temp addObject:key];
            }
        }
    }];
    
    // get old objects
    NSArray *oldObjects = [self objectsForKeys:temp notFoundMarker:[NSNull null]];
    [self removeObjectsForKeys:temp];
    [self removeObjectForKey:indexPath];
    
    // move row ids
    for (NSUInteger i = 0; i < temp.count; i++) {
        NSIndexPath *key = [temp objectAtIndex:i];
        id obj = [oldObjects objectAtIndex:i];
        NSIndexPath *newKey = [NSIndexPath indexPathForRow:key.row - 1 inSection:key.section];
        
        [self setObject:obj forKey:newKey];
    }
    
    // move sections if this was the last object
    if (numRowsInSection == 1) {
        // get upper sections
        [self enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, id obj, BOOL *stop) {
            if (key.section > indexPath.section) {
                [temp addObject:key];
            }
        }];
        
        oldObjects = [self objectsForKeys:temp notFoundMarker:[NSNull null]];
        [self removeObjectsForKeys:temp];
        
        for (NSUInteger i = 0; i < temp.count; i++) {
            NSIndexPath *key = [temp objectAtIndex:i];
            id obj = [oldObjects objectAtIndex:i];
            NSIndexPath *newKey = [NSIndexPath indexPathForRow:key.row inSection:key.section - 1];
            
            [self setObject:obj forKey:newKey];
        }
        
        return YES;
    }
    
    return NO;
}

@end
