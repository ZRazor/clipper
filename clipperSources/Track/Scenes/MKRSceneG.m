//
//  MKRSceneG.m
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneG.h"

@implementation MKRSceneG

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:YES];
    if (!bar) {
        return NO;
    }
    [self.bars addObject:bar];
    return YES;
}

- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andResultCursorPtr:(CMTime *)resultCursorPtr andMSPQ:(double)MSPQ andAutomations:(NSMutableArray *)automations {
    MKRBar *bar = self.bars[0];
    AVMutableComposition *barAsset = [barsAssets objectForKey:@(bar.identifier)];
    CMTimeRange barTimeRange = CMTimeRangeMake(kCMTimeZero, barAsset.duration);
    CMTime barStartAt = *resultCursorPtr;
    [self makeCompositionBar:composition withBarAsset:barAsset andWithBar:bar andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:barTimeRange usingAutoComplete:YES];
    
    CMTime bar05 = CMTimeSubtract(*resultCursorPtr, barStartAt);
    [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar05 resultCursorPtr:resultCursorPtr];
    
    CMTime bar025 = CMTimeMultiplyByRatio(bar05, 1, 4);
    for (int i = 0; i < 4; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar025 resultCursorPtr:resultCursorPtr];
    }
    
//    MKRAutomationLane *pitchAutomation;
//    for (MKRAutomationLane *automation in automations) {
//        if (automation.audioUnitIdentifier == kMKRUnit_TimePitch && automation.parameterID == kNewTimePitchParam_Pitch) {
//            pitchAutomation = automation;
//            break;
//        }
//    }
//    [pitchAutomation addPointAt:*resultCursorPtr withValue:@0];
    
    CMTime bar0125 = CMTimeMultiplyByRatio(bar025, 1, 2);
    for (int i = 0; i < 8; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar0125 resultCursorPtr:resultCursorPtr];
    }
    
//    CMTime bar00625 = CMTimeMultiplyByRatio(bar0125, 1, 2);
//    for (int i = 0; i < 16; i++) {
//        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar00625 resultCursorPtr:resultCursorPtr];
//    }
    
//    [pitchAutomation addPointAt:*resultCursorPtr withValue:@2400];
//    [pitchAutomation addPointAt:CMTimeAdd(*resultCursorPtr, CMTimeMakeWithSeconds(0.001, 600000)) withValue:@0];
}

@end
