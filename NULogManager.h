//
//  LogManager.h
//  util
//
//  Created by Bálint Róbert on 24/11/15.
//  Copyright © 2015 Incepteam. All rights reserved.
//

#import "Manager.h"
#import <stdio.h>

size_t memoryUsage(void);
double memoryUsageMegabytes();
BOOL isDebuggerAttached(void);
NSString *platform(BOOL stripModel);
int copyFile(const char *fn1, const char *fn2);

@interface LogManager : NUManager

@property (nonatomic, strong) NSString *redirectedFileName;
@property (nonatomic) FILE *redirectedFile;

- (void)doFlush;

@end
