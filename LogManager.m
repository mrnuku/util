//
//  LogManager.m
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 24/11/15.
//  Copyright © 2015 Incepteam. All rights reserved.
//

#import "LogManager.h"
#if HERO
#import "CommunicationManager.h"
#endif
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

@implementation LogManager {
    NSString *redirectedFileName;
    FILE *redirectedFile;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
//#ifdef DEBUG
        redirectedFileName = [NSString stringWithFormat:@"console-%@.log", [UIDevice currentDevice].identifierForVendor.UUIDString];
        redirectedFile = redirectConsole(redirectedFileName);
        TestLog(@"=== LogManager initialized ===");
        TestLog(@"NSDocumentDirectory: %@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject);
//#endif
    }
    
    return self;
}

#if HERO
- (void)uploadLogWithCompletion:(void (^ _Nullable)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!redirectedFile) {
            if (completion) {
                completion();
            }
            
            return;
        }
        
        CommunicationManager *commManager = [CommunicationManager manager];
        
        NSURL *url = [[NSURL URLWithString:kBaseUrlStr] URLByAppendingPathComponent:kImageAssetWithoutDataEndPointStr];
        NSURL *imageAssetEndPointUrl = [url URLByAppendingPathComponent:redirectedFileName.stringByDeletingPathExtension];
        
        fflush(stderr);
        fflush(redirectedFile);
        
        NSString *shadowDate = [[NSDate date].description stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *uploadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:shadowDate];
        NSString *logFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:redirectedFileName];
        
        if (!copyFile(logFilePath.UTF8String, uploadingFilePath.UTF8String)) {
            return;
        }
        
        NSURLComponents *fileUrlComp = [NSURLComponents componentsWithString:uploadingFilePath];
        fileUrlComp.scheme = @"file";
        NSURL *fileUrl = fileUrlComp.URL;
        NSString * mimeTypeStr = @"text/plain";
        
        TestLog(@"%@ %@: log upload starting: '%@'", NSStringFromClass(self.class), NSStringFromSelector(_cmd), redirectedFileName);
        
        [commManager.sessionManager
         POST:imageAssetEndPointUrl.absoluteString
         parameters:nil
         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
             [formData
              appendPartWithFileURL:fileUrl
              name:@"image"
              fileName:redirectedFileName
              mimeType:mimeTypeStr
              error:nil];
         }
         success:^(NSURLSessionDataTask *task, id responseObject) {
             TestLog(@"%@ %@: log upload successfull", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
             
             if (completion) {
                 completion();
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             TestLog(@"%@ %@: log upload failed", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
             
             if (completion) {
                 completion();
             }
         }];
        
        // NODE CRASH TEST
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            FILE *fp2;
//            if ((fp2 = fopen(uploadingFilePath.UTF8String, "a+"))) {
//                fprintf(fp2, "NODE_CRASH\n");
//                fclose(fp2);
//            }
//        });
        
    });
}
#endif

- (void)resetUploadedState {
    
}

@end
