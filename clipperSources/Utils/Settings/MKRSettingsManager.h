//
// Created by Anton Zlotnikov on 18.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kMKRSaveClippedVideoKey = @"saveClippedVideo";
static NSString *const kMKRSaveOriginalVideoKey = @"saveOriginalVideo";

@interface MKRSettingsManager : NSObject
+ (void)checkDefaultSettings;

+ (void)setBoolValue:(BOOL)value forKey:(NSString *)key;

+ (BOOL)getBoolValueForKey:(NSString *)key;
@end