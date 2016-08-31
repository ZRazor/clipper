//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MKRFiltersManager.h"

@interface MKRExportProcessor : NSObject

+ (void)exportMutableCompositionToDocuments:(AVMutableComposition *)asset isPortrait:(BOOL)videoIsPortrait withFiltersManager:(MKRFiltersManager *)filtersManager onSuccess:(void (^)(NSURL *assertUrl))success onFailure:(void (^)(NSError *error))failure;

+ (void)exportAudioFromMutableCompositionToDocuments:(AVMutableComposition *)asset onSuccess:(void (^)(NSURL *assertUrl))success onFailure:(void (^)(NSError *error))failure;

+ (CGAffineTransform)prefferedTransformFromAsset:(AVAsset *)asset;

+ (BOOL)isVideoPortrait:(AVAsset *)asset;

+ (NSURL *)generateFilePathWithFormat:(NSString *)formatName;

@end