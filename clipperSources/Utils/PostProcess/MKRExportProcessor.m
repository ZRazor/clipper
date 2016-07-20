//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRExportProcessor.h"
#import "MKRCustomVideoCompositor.h"

@implementation MKRExportProcessor {
}

+ (NSURL *)generateFilePathWithFormat:(NSString *)formatName {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES);
    NSString* documentsPath = paths[0];
    
    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSString *name = [NSString stringWithFormat:@"export_%@.%@", UUID, formatName];
    NSURL *URL = [NSURL fileURLWithPath:[documentsPath stringByAppendingPathComponent:name]];
    
    return URL;
}


+ (void)exportMutableCompositionToDocuments:(AVMutableComposition *)asset prefferedTransform:(CGAffineTransform)transform withFiltersManager:(MKRFiltersManager *)filtersManager onSuccess:(void (^)(NSURL *assertUrl))success onFailure:(void (^)(NSError *error))failure {

    AVMutableCompositionTrack *compositionVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].lastObject;
    if (compositionVideoTrack) {
        [compositionVideoTrack setPreferredTransform:transform];
    }
    
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                         ofAsset:asset
                          atTime:kCMTimeZero
                           error:nil];

    AVMutableCompositionTrack *videoTrack = [composition mutableTrackCompatibleWithTrack:compositionVideoTrack];
    [videoTrack setPreferredTransform:transform];

    CMTime newDuration = CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration), compositionVideoTrack.naturalTimeScale);

    [composition scaleTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                     toDuration:newDuration];

    AVMutableVideoCompositionLayerInstruction *instruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.layerInstructions = @[instruction];
    videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, newDuration);
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / compositionVideoTrack.nominalFrameRate, compositionVideoTrack.naturalTimeScale); //Считаем fps для рендера
    videoComposition.renderSize = compositionVideoTrack.naturalSize;
    videoComposition.instructions = @[videoCompositionInstruction];
    videoComposition.customVideoCompositorClass = [MKRCustomVideoCompositor class];

    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition
                                      presetName:AVAssetExportPresetHighestQuality];
    
    
    NSURL *outputURL = [self generateFilePathWithFormat:@"mov"];
    
    //Настраиваем экспорт
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.videoComposition = videoComposition;
    [(MKRCustomVideoCompositor *)exportSession.customVideoCompositor setFiltersManager:filtersManager];
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                int exportStatus = exportSession.status;
                switch (exportStatus) {
                    case AVAssetExportSessionStatusFailed: {
                        NSError *exportError = exportSession.error;
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

+ (void)exportAudioFromMutableCompositionToDocuments:(AVMutableComposition *)asset onSuccess:(void (^)(NSURL *assertUrl))success onFailure:(void (^)(NSError *error))failure {
    AVMutableComposition *audioComposition = [[AVMutableComposition alloc] init];
    NSArray<AVMutableCompositionTrack *> *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    for (AVMutableCompositionTrack *track in tracks) {
        AVMutableCompositionTrack *newTrack = [audioComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:track.trackID];
        [newTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:track atTime:kCMTimeZero error:nil];
    }
    
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:audioComposition presetName:AVAssetExportPresetAppleM4A];
    [export setOutputFileType:AVFileTypeAppleM4A];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES);
    NSString* documentsPath = paths[0];
    
    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSString *exportURL = [NSString stringWithFormat:@"%@/export_%@.m4a", documentsPath, UUID];
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

+ (BOOL)isVideoPortrait:(AVAsset *)asset {
    BOOL isPortrait = NO;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count]) {
        AVAssetTrack *videoTrack = tracks[0];
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {

            isPortrait = YES;
        }
        // LandscapeRight
        if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            isPortrait = NO;
        }
        // LandscapeLeft
        if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            isPortrait = NO;
        }
    }
    return isPortrait;
}

@end