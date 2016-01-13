//
//  UtilMacros.h
//  Utils
//
//  Created by Bálint Róbert on 13/01/16.
//  Copyright (c) 2016 IncepTech Ltd All rights reserved.
//

#ifndef UtilMacros_h
#define UtilMacros_h

#ifdef DEBUG
#define TestLog(x, ...) NSLog((x), ##__VA_ARGS__)
#else
#define TestLog(x, ...)
#endif

#define LocalizedString(x)                              NSLocalizedString(x, null)

#define SYSTEM_VERSION_EQUAL_TO(v)                      ([[UIDevice currentDevice].systemVersion compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)                  ([[UIDevice currentDevice].systemVersion compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)      ([[UIDevice currentDevice].systemVersion compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                     ([[UIDevice currentDevice].systemVersion compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)         ([[UIDevice currentDevice].systemVersion compare:v options:NSNumericSearch] != NSOrderedDescending)

#define PLATFORM_VERSION_EQUAL_TO(v)                    ([platform(YES) compare:v options:NSNumericSearch] == NSOrderedSame)
#define PLATFORM_VERSION_GREATER_THAN(v)                ([platform(YES) compare:v options:NSNumericSearch] == NSOrderedDescending)
#define PLATFORM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)    ([platform(YES) compare:v options:NSNumericSearch] != NSOrderedAscending)
#define PLATFORM_VERSION_LESS_THAN(v)                   ([platform(YES) compare:v options:NSNumericSearch] == NSOrderedAscending)
#define PLATFORM_VERSION_LESS_THAN_OR_EQUAL_TO(v)       ([platform(YES) compare:v options:NSNumericSearch] != NSOrderedDescending)

#define PLATFORM_IS_IPHONE                              ([[UIDevice currentDevice].model hasPrefix:@"iPhone"])
#define PLATFORM_IS_IPAD                                ([[UIDevice currentDevice].model hasPrefix:@"iPad"])

#endif
