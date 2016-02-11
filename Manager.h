//
//  Manager.h
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 12/05/15.
//  Copyright (c) 2015 Incepteam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Manager : NSObject

/// creates a singleton manager instance
+ (instancetype)manager;
+ (instancetype)sharedInstance;

+ (void)clearManager;

@end
