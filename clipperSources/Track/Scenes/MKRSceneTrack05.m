//
//  MKRSceneTrack05.m
//  clipper
//
//  Created by dev on 20.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneTrack05.h"
#import "MKRAudioUnits.h"

@implementation MKRSceneTrack05

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar1 = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar2 = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:YES];
    MKRBar *bar3 = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar4 = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:NO];
    if (bar1 == nil || bar2 == nil || bar3 == nil || bar4 == nil) {
        return NO;
    }
    [self.bars addObject:bar1];
    [self.bars addObject:bar2];
    [self.bars addObject:bar3];
    [self.bars addObject:bar4];
    
    return YES;
}

- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andResultCursorPtr:(CMTime *)resultCursorPtr andMSPQ:(double)MSPQ andAutomations:(NSMutableArray<MKRAutomationLane *> *)automations andFiltersManager:(MKRFiltersManager *)filtersManager {
    CMTime start = *resultCursorPtr;
    AVMutableComposition *asset1 = [barsAssets objectForKey:@(self.bars[0].identifier)];
    AVMutableComposition *asset2 = [barsAssets objectForKey:@(self.bars[1].identifier)];
    AVMutableComposition *asset3 = [barsAssets objectForKey:@(self.bars[2].identifier)];
    AVMutableComposition *asset4 = [barsAssets objectForKey:@(self.bars[3].identifier)];
    
    [self makeCompositionBar:composition withBarAsset:asset1 andWithBar:self.bars[0] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) usingAutoComplete:YES];
    
    CMTime d1 = CMTimeSubtract(*resultCursorPtr, start);
    CMTime d05 = CMTimeMultiplyByRatio(d1, 1, 2);
    CMTime d025 = CMTimeMultiplyByRatio(d05, 1, 2);
    CMTime d075 = CMTimeMultiplyByRatio(d025, 3, 1);
    
    for (int i = 0; i < 3; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:start duration:d025 resultCursorPtr:resultCursorPtr];
    }
    [self insertTimeRange:composition ofAsset:composition startAt:d075 duration:d025 resultCursorPtr:resultCursorPtr];
    [self insertTimeRange:composition ofAsset:composition startAt:start duration:d1 resultCursorPtr:resultCursorPtr];
    [self makeCompositionBar:composition withBarAsset:asset2 andWithBar:self.bars[1] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) usingAutoComplete:YES];
    
    start = *resultCursorPtr;
    [self makeCompositionBar:composition withBarAsset:asset3 andWithBar:self.bars[2] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset3.duration) usingAutoComplete:YES];
    for (int i = 0; i < 3; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:start duration:d025 resultCursorPtr:resultCursorPtr];
    }
    [self insertTimeRange:composition ofAsset:composition startAt:CMTimeAdd(start, d075) duration:d025 resultCursorPtr:resultCursorPtr];
    [self insertTimeRange:composition ofAsset:composition startAt:start duration:d1 resultCursorPtr:resultCursorPtr];
    [self makeCompositionBar:composition withBarAsset:asset4 andWithBar:self.bars[3] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset4.duration) usingAutoComplete:YES];
}

@end
