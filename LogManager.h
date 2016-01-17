//
//  LogManager.h
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 24/11/15.
//  Copyright © 2015 Incepteam. All rights reserved.
//

#import "Manager.h"

size_t memoryUsage(void);
double memoryUsageMegabytes();
BOOL isDebuggerAttached(void);

@interface LogManager : Manager

#if HERO
- (void)uploadLogWithCompletion:(void (^ _Nullable)(void))completion;
#endif
- (void)resetUploadedState;

@end
