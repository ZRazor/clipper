//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRExportProcessor.h"
#import "MKRAudioPostProcessor.h"


@implementation MKRExportProcessor {

}

+ (void)exportMutableCompositionToDocuments:(AVMutableComposition *)asset onSuccess:(void (^)(NSURL *assertUrl))success onFailure:(void (^)(NSError *error))failure {
    AVMutableAudioMix *audioMix = [MKRAudioPostProcessor postProcessAudioForMutableComposition:asset];
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    [export setOutputFileType:AVFileTypeQuickTimeMovie];
    [export setAudioMix:audioMix];

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES);
    NSString* documentsPath = paths[0];

    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSString *exportURL = [NSString stringWithFormat:@"%@/export_%@.mov", documentsPath, UUID];
    NSURL *outputURL = [NSURL fileURLWithPath:exportURL];
    export.outputURL = outputURL;

    [export exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = export.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                NSError *exportError = export.error;
                NSLog(@"AVAssetExportSessionStatusFailed: %@", exportError);
                failure([NSError errorWithDomain:@"MayakRed" code:1 userInfo:nil]);
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"AVAssetExportSessionStatusCompleted--");
                success(outputURL);
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
                NSLog(@"AVAssetExportSessionStatusUnknown");
                failure([NSError errorWithDomain:@"MayakRed" code:2 userInfo:nil]);
                break;
            }
            case AVAssetExportSessionStatusExporting: {
                NSLog(@"AVAssetExportSessionStatusExporting");
                break;
            }
            case AVAssetExportSessionStatusCancelled: {
                NSLog(@"AVAssetExportSessionStatusCancelled");
                failure([NSError errorWithDomain:@"MayakRed" code:3 userInfo:nil]);
                break;
            }
            case AVAssetExportSessionStatusWaiting: {
                NSLog(@"AVAssetExportSessionStatusWaiting");
                break;
            }
            default: {
                NSLog(@"didn't get export status");
                failure([NSError errorWithDomain:@"MayakRed" code:4 userInfo:nil]);
                break;
            }
        }
    }];
}

@end