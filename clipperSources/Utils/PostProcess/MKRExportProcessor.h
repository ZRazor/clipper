//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MKRExportProcessor : NSObject

+ (void)exportMutableCompositionToDocuments:(AVMutableComposition *)asset prefferedTransform:(CGAffineTransform)transform onSuccess:(void (^)(NSURL *assertUrl))success onFailure:(void (^)(NSError *error))failure;

+ (void)exportAudioFromMutableCompositionToDocuments:(AVMutableComposition *)asset onSuccess:(void (^)(NSURL *assertUrl))success onFailure:(void (^)(NSError *error))failure;

+ (BOOL)isVideoPortrait:(AVAsset *)asset;

+ (NSURL *)generateFilePathWithFormat:(NSString *)formatName;

@end