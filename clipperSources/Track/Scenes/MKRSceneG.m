//
//  MKRSceneG.m
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneG.h"
#import "MKRAudioUnits.h"

@implementation MKRSceneG

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:YES];
    if (!bar) {
        return NO;
    }
    [self.bars addObject:bar];
    return YES;
}

- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andResultCursorPtr:(CMTime *)resultCursorPtr andMSPQ:(double)MSPQ andAutomations:(NSMutableArray *)automations andFiltersManager:(MKRFiltersManager *)filtersManager {
    MKRBar *bar = self.bars[0];
    AVMutableComposition *barAsset = [barsAssets objectForKey:@(bar.identifier)];
    MKRAutomationLane *pitchAutomation = [MKRScene automationFor:kMKRUnit_TimePitch andParameter:kNewTimePitchParam_Pitch in:automations];
    MKRAutomationLane *distAutomation = [MKRScene automationFor:kMKRUnit_Distortion andParameter:kDistortionParam_FinalMix in:automations];
    
    CMTimeRange barTimeRange = CMTimeRangeMake(kCMTimeZero, barAsset.duration);
    CMTime barStartAt = *resultCursorPtr;
    [distAutomation addPointAt:barStartAt withValue:@10];

    [self makeCompositionBar:composition withBarAsset:barAsset andWithBar:bar andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:barTimeRange usingAutoComplete:YES];
    
    CMTime bar05 = CMTimeSubtract(*resultCursorPtr, barStartAt);
    [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar05 resultCursorPtr:resultCursorPtr];
    
    CMTime bar025 = CMTimeMultiplyByRatio(bar05, 1, 4);
    for (int i = 0; i < 4; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar025 resultCursorPtr:resultCursorPtr];
    }
    
    [pitchAutomation addPointAt:*resultCursorPtr withValue:@0];
    
    CMTime bar0125 = CMTimeMultiplyByRatio(bar025, 1, 2);
    for (int i = 0; i < 8; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar0125 resultCursorPtr:resultCursorPtr];
        if (i == 2) {
            [pitchAutomation addPointAt:*resultCursorPtr withValue:@2400];
        }
    }
    
    [pitchAutomation addPointAt:*resultCursorPtr withValue:@0];
    [distAutomation addPointAt:*resultCursorPtr withValue:@0];
    [pitchAutomation addPointAt:CMTimeAdd(*resultCursorPtr, CMTimeMakeWithSeconds(0.001, 6000000)) withValue:@0];
}

@end
