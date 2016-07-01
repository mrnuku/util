//
//  NSObject+PropertyReflection.m
//  util
//
//  Created by mrnuku on 28/05/16.
//
//

#import "NSObject+PropertyReflection.h"
#import "objc/runtime.h"

@implementation NSObject (PropertyReflection)

+ (NSArray *)listPropertyNames:(BOOL)excludeReadOnly  {
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
    NSMutableArray<NSString *> *result = [NSMutableArray arrayWithCapacity:outCount];
    
    for (unsigned int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        
        if (!propName) {
            continue;
        }
        
        if (!excludeReadOnly || ![[@(property_getAttributes(property)) componentsSeparatedByString:@","] containsObject:@"R"]) {
            [result addObject:@(propName)];
        }
    }
    
    free(properties);
    return result.copy;
}

- (id)reflectedCopy {
    id object = [self.class new];
    NSArray *properties = [self.class listPropertyNames:YES];
    
    for (NSString *key in properties) {
        id value = [self valueForKey:key];
        
        if (value) {
            [object setValue:value forKey:key];
        }
    }
    
    return object;
}

- (NSString *)reflectedDescription {
    NSArray<NSString *> *properties = [self.class listPropertyNames:NO];
    NSMutableString *desc = [NSMutableString new];
    
    for (NSString *propertyName in properties) {
        id value = [self valueForKey:propertyName];
        
        if (value) {
            if (desc.length) {
                [desc appendString:@", "];
            }
            
            [desc appendString:propertyName];
            [desc appendFormat:@": \"%@\"", value];
        }
    }
    
    return desc.copy;
}

@end
