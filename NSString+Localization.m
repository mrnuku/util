//
//  NSString+Localization.m
//  Pods
//
//  Created by mrnuku on 01/07/16.
//
//

#import "NSString+Localization.h"

@implementation NSString (Localization)

- (instancetype)localized {
    NSString *localizedString = NSLocalizedString(self, null);
    
    if (!localizedString.length || [localizedString isEqualToString:self]) {
#ifdef DEBUG
        localizedString = [NSString stringWithFormat:@"#%@#", self];
#else
        localizedString = self;
#endif
    }
    
    return localizedString;
}

@end
