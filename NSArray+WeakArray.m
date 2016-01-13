//
//  NSMutableArray+WeakArray.m
//

#import "NSArray+WeakArray.h"

///
/// A wrapper for a weak pointer, meant to allow for arrays of weak references (that don't suck)
///
@interface WAArrayWeakPointer : NSObject

@property (nonatomic, weak) NSObject *object;

@end

@implementation WAArrayWeakPointer

@end


@implementation NSArray (WeakArray)

///
/// Returns the weakly referenced object at the given index
///
-(__weak id)weakObjectForIndex:(NSUInteger)index
{
    WAArrayWeakPointer *ptr = [self objectAtIndex:index];
    return ptr.object;
}

///
/// Gets the weak pointer for the given object reference
///
-(WAArrayWeakPointer *)weakPointerForObject:(id)object
{
    // Linear search for the object in question
    for (WAArrayWeakPointer *ptr in self) {
        if(ptr) {
            if(ptr.object == object) {
                return ptr;
            }
        }
    }
    
    return nil;
}

///
/// Returns a fast enumeration collection for all of the weakly referenced objects in this collection
///
-(id<NSFastEnumeration>)weakObjectsEnumerator
{
    NSMutableArray *enumerator = [[NSMutableArray alloc] init];
    for (WAArrayWeakPointer *ptr in self) {
        if(ptr && ptr.object) {
            [enumerator addObject:ptr.object];
        }
    }
    return enumerator;
}

@end

@implementation NSMutableArray (FRSWeakArray)

///
/// Adds a weak reference to the given object to the collection
///
-(void)addWeakObject:(id)object
{
    if(!object)
        return;
    
    WAArrayWeakPointer *ptr = [[WAArrayWeakPointer alloc] init];
    ptr.object = object;
    [self addObject:ptr];
    
    [self cleanWeakObjects];
}

///
/// Removes a weakly referenced object from the collection
///
-(void)removeWeakObject:(id)object
{
    if(!object)
        return;
    
    // Find the underlying object in the array
    WAArrayWeakPointer *ptr = [self weakPointerForObject:object];
    
    if(ptr) {
        
        [self removeObject:ptr];
    
        [self cleanWeakObjects];
    }
}

///
/// Cleans the collection of any lost weak objects
///
-(void)cleanWeakObjects
{
    // Build a list of dead references
    NSMutableArray *toBeRemoved = [[NSMutableArray alloc] init];
    for (WAArrayWeakPointer *ptr in self) {
        if(ptr && !ptr.object) {
            [toBeRemoved addObject:ptr];
        }
    }
    
    // Remove the dead references from the collection
    for(WAArrayWeakPointer *ptr in toBeRemoved) {
        [self removeObject:ptr];
    }
}

@end