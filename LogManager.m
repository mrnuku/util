//
//  LogManager.m
//  util
//
//  Created by Bálint Róbert on 24/11/15.
//  Copyright © 2015 Incepteam. All rights reserved.
//

#import "LogManager.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "UtilMacros.h"
#import <UIKit/UIKit.h>

size_t memoryUsage(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    if (kerr == KERN_SUCCESS) {
        return info.resident_size;
    }
    
    TestLog(@"memoryUsage: task_info failed '%s'", mach_error_string(kerr));
    
    return 0;
}

double memoryUsageMegabytes() {
    size_t bytes = memoryUsage();
    static double denom = 1024 * 1024;
    return (double)bytes / denom;
}

NSString *platform(BOOL stripModel) {
    char temp[256] = { 0 };
    size_t size;
    char *machine;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    if (size >= sizeof(temp)) {
        machine = alloca(size);
    }
    else {
        machine = temp;
    }
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    for (size_t i = 0; i < size; i++) {
        if (machine[i] == ',') {
            machine[i] = '.';
        }
    }
    
    char* output = machine;
    
    if (stripModel) {
        for (; output[0]; output++) {
            if (isdigit(*output)) {
                break;
            }
        }
    }
    
    NSString *platform = [NSString stringWithCString:output encoding:NSUTF8StringEncoding];
    
    //if (size >= sizeof(temp)) free(machine);
    
    return platform;
}

// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).

BOOL isDebuggerAttached(void) {
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    // Call sysctl.
    
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    
    // We're being debugged if the P_TRACED flag is set.
    
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

FILE *redirectConsole(NSString *name) {
    if (!isDebuggerAttached()) {
        NSString *logPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
        return freopen([logPath fileSystemRepresentation], "a+", stderr);
    }
    return NULL;
}

int copyFile(const char *fn1, const char *fn2) {
    char            buffer[BUFSIZ];
    size_t          n, all = 0;
    
    FILE *fp1;
    FILE *fp2;
    
    if ((fp1 = fopen(fn1, "rb")) == 0) {
        TestLog(@"copyFile: cannot open file %s for reading", fn1);
        return 0;
    }
    
    if ((fp2 = fopen(fn2, "wb")) == 0) {
        TestLog(@"copyFile: cannot open file %s for writing", fn2);
        fclose(fp1);
        return 0;
    }
    
    while ((n = fread(buffer, sizeof(char), sizeof(buffer), fp1)) > 0) {
        
        if (fwrite(buffer, sizeof(char), n, fp2) != n) {
            TestLog(@"copyFile: write failed");
            break;
        }
        
        all += n;
    }
    
    fclose(fp1);
    fclose(fp2);
    
    TestLog(@"copyFile: '%s' -> '%s' copied %zu bytes", fn1, fn2, all);
    
    return all > 0;
}

@implementation LogManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
        //#ifdef DEBUG
        self.redirectedFileName = [NSString stringWithFormat:@"console-%@.log", [UIDevice currentDevice].identifierForVendor.UUIDString];
        self.redirectedFile = redirectConsole(self.redirectedFileName);
        TestLog(@"=== LogManager initialized ===");
        TestLog(@"NSDocumentDirectory: %@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject);
        TestLog(@"Current memory usage: %.2f", memoryUsageMegabytes());
        //#endif
    }
    
    return self;
}

@end
