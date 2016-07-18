//
// Created by Anton Zlotnikov on 18.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRSettingsManager.h"


@implementation MKRSettingsManager {

}

+ (void)checkDefaultSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:kMKRSaveClippedVideoKey]) {
        [defaults setValue:@(NO) forKey:kMKRSaveClippedVideoKey];
    }
    if (![defaults valueForKey:kMKRSaveOriginalVideoKey]) {
        [defaults setValue:@(YES) forKey:kMKRSaveOriginalVideoKey];
    }
}

+ (void)setBoolValue:(BOOL)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(value) forKey:key];
}

+ (BOOL)getBoolValueForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [defaults valueForKey:key];
    return [value boolValue];
}

@end