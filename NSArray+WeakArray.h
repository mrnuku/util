//
//  NSMutableArray+WeakArray.h
//

#import <Foundation/Foundation.h>

///
/// Category on NSArray that provides read methods for weak pointers
/// NOTE: These methods may scan the whole array
///
@interface NSArray(WeakArray)

- (__weak id)weakObjectForIndex:(NSUInteger)index;
-(id<NSFastEnumeration>)weakObjectsEnumerator;

@end

///
/// Category on NSMutableArray that provides write methods for weak pointers
/// NOTE: These methods may scan the whole array
///
@interface NSMutableArray (FRSWeakArray)

-(void)addWeakObject:(id)object;
-(void)removeWeakObject:(id)object;

-(void)cleanWeakObjects;

@end
