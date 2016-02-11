//
//  Manager.m
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 12/05/15.
//  Copyright (c) 2015 Incepteam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Manager.h"

NSMutableDictionary *managersDict = nil;

@implementation Manager

+ (instancetype)manager {
    // thread safe but lockless after init
    if (!managersDict) {
        // use global object for locking
        @synchronized ([UIApplication sharedApplication]) {
            if (!managersDict) {
                managersDict = [NSMutableDictionary new];
            }
        }
    }
    
    NSString *className = NSStringFromClass([self class]);
    id managerObject = [managersDict objectForKey:className];
    
    // thread safe but lockless after init
    if (!managerObject) {
        // wait for others
        @synchronized(managersDict) {
            managerObject = [managersDict objectForKey:className];
        }
        
        // initialize an instance and block others
        @synchronized(managersDict) {
            if (!managerObject) {
                managerObject = [self new];
                [managersDict setObject:managerObject forKey:className];
            }
        }
    }
    
    return managerObject;
}

+ (instancetype)sharedInstance {
    // thread safe but lockless after init
    if (!managersDict) {
        // use global object for locking
        @synchronized ([UIApplication sharedApplication]) {
            if (!managersDict) {
                managersDict = [NSMutableDictionary new];
            }
        }
    }
    
    NSString *className = NSStringFromClass([self class]);
    id managerObject = [managersDict objectForKey:className];
    
    // thread safe but lockless after init
    if (!managerObject) {
        // wait for others
        @synchronized(managersDict) {
            managerObject = [managersDict objectForKey:className];
        }
        
        // initialize an instance and block others
        @synchronized(managersDict) {
            if (!managerObject) {
                managerObject = [self new];
                [managersDict setObject:managerObject forKey:className];
            }
        }
    }
    
    return managerObject;
}

+ (void)clearManager{
    NSString *className = NSStringFromClass([self class]);
    [managersDict removeObjectForKey:className];
}

@end
