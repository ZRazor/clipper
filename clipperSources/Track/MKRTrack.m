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
#import "MKRSceneC.h"
#import "MKRStructureUnit.h"

@implementation MKRTrack {
    NSMutableArray<MKRScene *> *scenes;
    NSMutableArray<MKRStructureUnit *> *structure;
    MKRBarManager *barManager;
}

- (instancetype)initWithMetaDataPath:(NSString *)metaDataPath andFeaturesInterval:(NSMutableArray<MKRInterval *> *)features{
    self = [super init];
    if (!self) {
        return nil;
    }
    scenes = [NSMutableArray<MKRScene *> new];
    structure = [NSMutableArray<MKRStructureUnit *> new];
    [self setFiltersManager:[[MKRFiltersManager alloc] init]];

    NSDictionary *metaData = [[NSDictionary alloc] initWithContentsOfFile:metaDataPath];
    [self setBPM:[[metaData valueForKey:@"BPM"] longValue]];
    [self setQPB:[[metaData valueForKey:@"QPB"] longValue]];
    [self calcMSPQ];
    barManager = [[MKRBarManager alloc] initWithFeaturesIntervals:features andMSPQ:self.MSPQ andQPB:self.QPB];

    NSMutableArray<NSString *> *metaDataScenes = [metaData mutableArrayValueForKey:@"Scenes"];
    NSMutableArray<NSNumber *> *metaDataStructure = [metaData mutableArrayValueForKey:@"Structure"];
    NSInteger identifier = 0;
    for (NSString *metaDataScene in metaDataScenes) {
        Class sceneClass = NSClassFromString(metaDataScene);
        MKRScene *scene = [[sceneClass alloc] initWithIdentifier:identifier++];
        if (!scene) {
            @throw ([NSException exceptionWithName:@"Unknown scene type" reason:@"Unknown scene type in track meta data" userInfo:nil]);
        }
        [scenes addObject:scene];
    }
    for (NSNumber *structureSceneIdentifier in metaDataStructure) {
        if ([scenes count] <= [structureSceneIdentifier longValue] || [structureSceneIdentifier longValue] < 0) {
            @throw ([NSException exceptionWithName:@"Unknown scene identifier" reason:@"Unknown scene identifier in track structure" userInfo:nil]);
        }
        MKRStructureUnit *structureUnit = [[MKRStructureUnit alloc] initWithScene:scenes[[structureSceneIdentifier longValue]]];
        [structure addObject:structureUnit];
    }

    return self;
}

- (void)calcMSPQ {
    [self setMSPQ:(1000.0 * 60.0  / self.BPM / self.QPB)];
}

- (BOOL)fillScenes {
    for (MKRScene *scene in scenes) {
        if (![scene fillBarsWithBarManager:barManager]) {
            return NO;
        }
    }
    return YES;
}

- (void)prepareAutomations {
    [self setAutomations:[[NSMutableArray alloc] init]];
    [self.automations addObject:[[MKRAutomationLane alloc] initWithAudioUnitIdentifier:kMKRUnit_TimePitch andParameterID:kNewTimePitchParam_Pitch]];
    [self.automations addObject:[[MKRAutomationLane alloc] initWithAudioUnitIdentifier:kMKRUnit_Lowpass andParameterID:kLowPassParam_CutoffFrequency]];
    [self.automations addObject:[[MKRAutomationLane alloc] initWithAudioUnitIdentifier:kMKRUnit_Lowpass andParameterID:kLowPassParam_Resonance]];
    [self.automations addObject:[[MKRAutomationLane alloc] initWithAudioUnitIdentifier:kMKRUnit_Distortion andParameterID:kDistortionParam_FinalMix]];
    [self.automations addObject:[[MKRAutomationLane alloc] initWithAudioUnitIdentifier:kMKRUnit_Delay andParameterID:kDelayParam_WetDryMix]];
}

- (AVMutableComposition *)processVideo:(AVAsset *)original {
    NSMutableDictionary *barsAssets = [NSMutableDictionary new];
    NSLog(@"-----------BARS FILLING-----------");
    for (NSInteger i = 0; i < [barManager.registeredBars count]; i++) {
        MKRBar *bar = barManager.registeredBars[i];
        if (!bar.used) {
            continue;
        }
        AVMutableComposition *barComposition = [AVMutableComposition composition];
        CMTime barCursor = kCMTimeZero;
        NSLog(@"bar.identifier = %ld", bar.identifier);
        for (NSInteger j = 0; j < [bar.sequence count]; j++) {
            MKRProcessedInterval *interval = bar.sequence[j];
            NSLog(@"%f [%ld, %ld] q=%ld wms=%f", CMTimeGetSeconds(barCursor), interval.start, interval.end, interval.quantsLength, interval.warpedMsLength / 1000.0);
            CMTime intervalStart = CMTimeMakeWithSeconds(interval.start / 1000.0, 6000000.0);
            CMTime intervalEnd = CMTimeMakeWithSeconds(interval.end / 1000.0, 6000000.0);
            CMTimeRange range = CMTimeRangeMake(intervalStart, CMTimeSubtract(intervalEnd, intervalStart));
            [barComposition insertTimeRange:range ofAsset:original atTime:barCursor error:nil];

            CMTimeRange rangeInBar = CMTimeRangeMake(barCursor, CMTimeSubtract(intervalEnd, intervalStart));
            CMTime neededDuration = CMTimeMakeWithSeconds(interval.warpedMsLength / 1000.0, 6000000);
            [barComposition scaleTimeRange:rangeInBar toDuration:neededDuration];
            barCursor = CMTimeAdd(barCursor, neededDuration);
        }
        [barsAssets setObject:barComposition forKey:@(bar.identifier)];
    }
    
    AVMutableComposition *result = [AVMutableComposition composition];
    NSLog(@"-----------COMPOSING-----------");
    CMTime resultCursor = kCMTimeZero;
    [self prepareAutomations];
    
    for (MKRStructureUnit *structureUnit in structure) {
        MKRScene *scene = [structureUnit getScene];
        Float64 startTime = CMTimeGetSeconds(resultCursor);
        NSLog(@"start scene id: %s %ld at %f", object_getClassName(scene), scene.identifier, startTime);
        [scene makeComposition:result withBarAssets:barsAssets andResultCursorPtr:&resultCursor andMSPQ:self.MSPQ andAutomations:self.automations andFiltersManager:self.filtersManager];
        Float64 endTime = CMTimeGetSeconds(resultCursor);
        NSLog(@"end scene at %f", endTime);
        [structureUnit setTimeIntervalWithStartTime:startTime andEndTime:endTime];
    }
    
    return result;
}

@end
