//
//  MKRSceneTrack04.m
//  clipper
//
//  Created by dev on 19.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneTrack04.h"
#import "MKRAudioUnits.h"

@implementation MKRSceneTrack04

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *longBar = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:NO];
    MKRBar *shortBar = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:YES];
    MKRBar *distBar1 = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:NO];
    MKRBar *distBar2 = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:NO];
    if (longBar == nil || shortBar == nil || distBar1 == nil || distBar2 == nil) {
        return NO;
    }
    [self.bars addObject:longBar];
    [self.bars addObject:shortBar];
    [self.bars addObject:distBar1];
    [self.bars addObject:distBar2];
    
    return YES;
}

- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andResultCursorPtr:(CMTime *)resultCursorPtr andMSPQ:(double)MSPQ andAutomations:(NSMutableArray<MKRAutomationLane *> *)automations {
    AVMutableComposition *longAsset = [barsAssets objectForKey:@(self.bars[0].identifier)];
    [self makeCompositionBar:composition withBarAsset:longAsset andWithBar:self.bars[0] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, longAsset.duration) usingAutoComplete:YES];
    
    
    CMTime riseStart = *resultCursorPtr;
    AVMutableComposition *shortAsset = [barsAssets objectForKey:@(self.bars[1].identifier)];
    [self makeCompositionBar:composition withBarAsset:shortAsset andWithBar:self.bars[1] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, shortAsset.duration) usingAutoComplete:YES];
    
    CMTime d025 = CMTimeMultiplyByRatio(CMTimeSubtract(*resultCursorPtr, riseStart), 1, 4);
    CMTime d0125 = CMTimeMultiplyByRatio(d025, 1, 2);
    CMTime d00625 = CMTimeMultiplyByRatio(d0125, 1, 2);
    
    for (int i = 0; i < 4; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:riseStart duration:d025 resultCursorPtr:resultCursorPtr];
    }
    
    for (int i = 0; i < 4; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:riseStart duration:d0125 resultCursorPtr:resultCursorPtr];
    }
    
    for (int i = 0; i < 8; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:riseStart duration:d00625 resultCursorPtr:resultCursorPtr];
    }
    
    AVMutableComposition *distAsset1 = [barsAssets objectForKey:@(self.bars[2].identifier)];
    AVMutableComposition *distAsset2 = [barsAssets objectForKey:@(self.bars[3].identifier)];
    
    [self makeCompositionBar:composition withBarAsset:distAsset1 andWithBar:self.bars[2] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, distAsset1.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:distAsset2 andWithBar:self.bars[3] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, distAsset2.duration) usingAutoComplete:YES];
    
    MKRAutomationLane *pitch = [MKRScene automationFor:kMKRUnit_TimePitch andParameter:kNewTimePitchParam_Pitch in:automations];
    [pitch addPointAt:CMTimeMakeWithSeconds(7.344f, 600000) withValue:@0];
    [pitch addPointAt:CMTimeMakeWithSeconds(8, 600000) withValue:@2400];
    [pitch addPointAt:CMTimeMakeWithSeconds(8.02, 600000) withValue:@0];
    
    MKRAutomationLane *delay = [MKRScene automationFor:kMKRUnit_Delay andParameter:kDelayParam_WetDryMix in:automations];
    [delay addPointAt:CMTimeMakeWithSeconds(11.6, 600000) withValue:@50];
    [delay addPointAt:CMTimeMakeWithSeconds(15.2, 600000) withValue:@50];
    [delay addPointAt:CMTimeMakeWithSeconds(15.5, 600000) withValue:@0];
    
    MKRAutomationLane *dist = [MKRScene automationFor:kMKRUnit_Distortion andParameter:kDistortionParam_FinalMix in:automations];
    [dist addPointAt:CMTimeMakeWithSeconds(8, 600000) withValue:@65];
    [dist addPointAt:CMTimeMakeWithSeconds(11.7, 600000) withValue:@65];
    [dist addPointAt:CMTimeMakeWithSeconds(12, 600000) withValue:@0];
}

@end
