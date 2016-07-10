//
//  MKRTrack.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRTrack.h"
#import "MKRScene.h"
#import "MKRSceneA.h"
#import "MKRSceneB.h"

@implementation MKRTrack {
    NSMutableArray<MKRScene *> *scenes;
    NSMutableArray<MKRScene *> *structure;
    MKRBarManager *barManager;
}

-(instancetype)initWithMetaDataPath:(NSString *)metaDataPath andFeaturesInterval:(NSMutableArray<MKRInterval *> *)features{
    self = [super init];
    if (!self) {
        return nil;
    }
    scenes = [NSMutableArray<MKRScene *> new];
    structure = [NSMutableArray<MKRScene *> new];
    
    NSDictionary *metaData = [[NSDictionary alloc] initWithContentsOfFile:metaDataPath];
    [self setBPM:[[metaData valueForKey:@"BPM"] longValue]];
    [self setQPB:[[metaData valueForKey:@"QPB"] longValue]];
    [self calcMSPQ];
    barManager = [[MKRBarManager alloc] initWithFeaturesIntervals:features andMSPQ:self.MSPQ andQPB:self.QPB];
    
    NSMutableArray<NSString *> *metaDataScenes = [metaData mutableArrayValueForKey:@"Scenes"];
    NSMutableArray<NSNumber *> *metaDataStructure = [metaData mutableArrayValueForKey:@"Structure"];
    NSInteger identifier = 0;
    for (NSString *metaDataScene in metaDataScenes) {
        MKRScene *scene;
        //TODO: refactor using scene factory
        if ([metaDataScene isEqualToString:@"SceneA"]) {
            scene = [[MKRSceneA alloc] initWithIdentifier:identifier++];
        } else if ([metaDataScene isEqualToString:@"SceneB"]) {
            scene = [[MKRSceneB alloc] initWithIdentifier:identifier++];
        } else {
            @throw ([NSException exceptionWithName:@"Unknown scene type" reason:@"Unknown scene type in track meta data" userInfo:nil]);
        }
        [scenes addObject:scene];
    }
    for (NSNumber *structureSceneIdentifier in metaDataStructure) {
        if ([scenes count] <= [structureSceneIdentifier longValue] || [structureSceneIdentifier longValue] < 0) {
            @throw ([NSException exceptionWithName:@"Unknown scene identifier" reason:@"Unknown scene identifier in track structure" userInfo:nil]);
        }
        [structure addObject:scenes[[structureSceneIdentifier longValue]]];
    }
    
    return self;
}

-(void)calcMSPQ {
    [self setMSPQ:(1000.0 * 60.0  / self.BPM / self.QPB)];
}

-(BOOL)fillScenes {
    for (MKRScene *scene in scenes) {
        if (![scene fillBarsWithBarManager:barManager]) {
            return NO;
        }
    }
    return YES;
}

-(AVMutableComposition *)processVideo:(AVAsset *)original {
    NSMutableDictionary *barsAssets = [NSMutableDictionary new];
    for (NSInteger i = 0; i < [barManager.registeredBars count]; i++) {
        MKRBar *bar = barManager.registeredBars[i];
        if (!bar.used) {
            continue;
        }
        AVMutableComposition *barComposition = [AVMutableComposition composition];
        CMTime barCursor = kCMTimeZero;
        for (NSInteger j = 0; j < [bar.sequence count]; j++) {
            MKRProcessedInterval *interval = bar.sequence[j];
            CMTime intervalStart = CMTimeMakeWithSeconds(interval.start / 1000.0, 1000.0);
            CMTime intervalEnd = CMTimeMakeWithSeconds(interval.end / 1000.0, 1000.0);
            CMTimeRange range = CMTimeRangeMake(intervalStart, intervalEnd);
            [barComposition insertTimeRange:range ofAsset:original atTime:barCursor error:nil];
            NSLog(@"bar length = %f", CMTimeGetSeconds([barComposition duration]));
            
            CMTime notProcessedEnd = CMTimeAdd(barCursor, CMTimeSubtract(intervalEnd, intervalStart));
            CMTimeRange rangeInBar = CMTimeRangeMake(barCursor, notProcessedEnd);
            CMTime neededDuration = CMTimeMakeWithSeconds(interval.length * interval.speedFactor / 1000.0, 1000);
            [barComposition scaleTimeRange:rangeInBar toDuration:neededDuration];
            barCursor = CMTimeAdd(barCursor, neededDuration);
        }
        [barsAssets setObject:barComposition forKey:@(bar.identifier)];
    }
    
    AVMutableComposition *result = [AVMutableComposition composition];
    CMTime resultCursor = kCMTimeZero;
    for (MKRScene *scene in structure) {
        for (MKRBar *bar in scene.bars) {
            AVMutableComposition *barAsset = [barsAssets objectForKey:@(bar.identifier)];
            if (barAsset == nil) {
                @throw([NSException exceptionWithName:@"Bar asset not found" reason:@"Bar asset not found" userInfo:nil]);
            }
            CMTimeRange barTimeRange = CMTimeRangeMake(kCMTimeZero, [barAsset duration]);
            [result insertTimeRange:barTimeRange ofAsset:barAsset atTime:resultCursor error:nil];
            resultCursor = CMTimeAdd(resultCursor, [barAsset duration]);
        }
    }
    
    NSLog(@"result track duration = %f", CMTimeGetSeconds([result duration]));
    
    return result;
}

@end
