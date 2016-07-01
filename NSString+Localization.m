//
//  NSString+Localization.m
//  Pods
//
//  Created by mrnuku on 01/07/16.
//
//

#import "NSString+Localization.h"

NSString *kNSStringLocalizationDefaultValue = @"kNSStringLocalizationDefaultValue";

@implementation NSString (Localization)

- (instancetype)localized {
    NSString *localizedString = NSLocalizedStringWithDefaultValue(self, nil, [NSBundle mainBundle], kNSStringLocalizationDefaultValue, nil);
    
    if (localizedString == kNSStringLocalizationDefaultValue) {
#ifdef DEBUG
        localizedString = [NSString stringWithFormat:@"#%@#", self];
#else
        localizedString = self;
#endif
    }
    
    return localizedString;
}

@end
