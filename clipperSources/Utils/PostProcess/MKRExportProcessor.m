//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRExportProcessor.h"
#import "MKRAudioPostProcessor.h"


@implementation MKRExportProcessor {

}

+ (void)exportMutableCompositionToDocuments:(AVMutableComposition *)asset
                          layerInstructions:(NSArray<AVMutableVideoCompositionInstruction *> *)instructions
                                  onSuccess:(void (^)(NSURL *assertUrl))success
                                  onFailure:(void (^)(NSError *error))failure {
    
    AVMutableAudioMix *audioMix = [MKRAudioPostProcessor postProcessAudioForMutableComposition:asset];
    
    AVAssetTrack *videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                         ofAsset:asset
                          atTime:kCMTimeZero
                           error:nil];
    
    AVMutableCompositionTrack *videoTrack = [composition mutableTrackCompatibleWithTrack:videoAssetTrack];
    
    CMTime newDuration = CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration), videoAssetTrack.naturalTimeScale);
    
    [composition scaleTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                     toDuration:newDuration];

    AVMutableVideoCompositionLayerInstruction *instruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [instruction setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1), CMTimeMakeWithSeconds(3, 1))];
    [instruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.layerInstructions = @[instruction];
    videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, newDuration);
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / videoAssetTrack.nominalFrameRate, videoAssetTrack.naturalTimeScale); //Считаем fps для рендера
    videoComposition.renderSize = videoAssetTrack.naturalSize;
    videoComposition.instructions = @[videoCompositionInstruction];

    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition
                                      presetName:AVAssetExportPresetHighestQuality];
    
    //Пути экспорта
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES);
    NSString* documentsPath = paths[0];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    NSString *exportURL = [NSString stringWithFormat:@"%@/export_%@.mov", documentsPath, UUID];
    NSURL *outputURL = [NSURL fileURLWithPath:exportURL];
    
    //Настраиваем экспорт
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.videoComposition = videoComposition;
    exportSession.audioMix = audioMix;
    
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

@end