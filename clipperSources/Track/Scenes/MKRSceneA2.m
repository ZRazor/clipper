//
//  MKRSceneA2.m
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneA2.h"
#import "MKRAudioUnits.h"

@implementation MKRSceneA2

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier];
    if (!self) {
        return nil;
    }
    [self setBarsCount:1];
    return self;
}

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    for (int i = 0; i < 4; i++) {
        MKRBar *bar = [barManager getBarWithQuantsLength:@(self.barsCount * 4 * barManager.QPB) withHighestGain:NO];
        if (bar == nil) {
            return NO;
        }
        [self.bars addObject:bar];
    }
    
    return YES;
}

//- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andResultCursorPtr:(CMTime *)resultCursorPtr andMSPQ:(double)MSPQ andAutomations:(NSMutableArray<MKRAutomationLane *> *)automations {
//    CMTime startAt = *resultCursorPtr;
//    [super makeComposition:composition withBarAssets:barsAssets andResultCursorPtr:resultCursorPtr andMSPQ:MSPQ andAutomations:automations];
//    CMTime endAt = *resultCursorPtr;
//    
//    MKRAutomationLane *lf = [self automationFor:kMKRUnit_Lowpass andParameter:kLowPassParam_CutoffFrequency in:automations];
//    MKRAutomationLane *lr = [self automationFor:kMKRUnit_Lowpass andParameter:kLowPassParam_Resonance in:automations];
//    [lr addPointAt:startAt withValue:@30];
//    [lr addPointAt:CMTimeSubtract(endAt, CMTimeMakeWithSeconds(0.001, 600000)) withValue:@30];
//    [lr addPointAt:endAt withValue:@0];
//    
//    CMTime currentTime = startAt;
//    CMTime time0125 = CMTimeMultiplyByRatio(CMTimeSubtract(endAt, startAt), 1, 8);
//    for (int i = 0; i < 9; i++) {
//        NSNumber *value;
//        if (i % 2 == 0) {
//            value = @22500;
//        } else {
//            value = @10;
//        }
//        [lf addPointAt:currentTime withValue:value];
//        currentTime = CMTimeAdd(currentTime, time0125);
//    }
//}

@end
