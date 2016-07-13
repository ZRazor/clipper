//
//  MKRSceneF.m
//  clipper
//
//  Created by dev on 12.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneF.h"

@implementation MKRSceneF

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar = [barManager getBarWithQuantsLength:@(2 * barManager.QPB)];
    if (!bar) {
        return NO;
    }
    [self.bars addObject:bar];
    return YES;
}

- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(double)MSPQ {
    MKRBar *bar = self.bars[0];
    AVMutableComposition *barAsset = [barsAssets objectForKey:@(bar.identifier)];
    CMTimeRange barTimeRange = CMTimeRangeMake(kCMTimeZero, barAsset.duration);
    CMTime barStartAt = *resultCursorPtr;
    [self makeCompositionBar:composition withBarAsset:barAsset andWithBar:bar andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:barTimeRange usingAutoComplete:YES];
    
    CMTime bar05 = CMTimeSubtract(*resultCursorPtr, barStartAt);
    for (int i = 0; i < 3; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar05 resultCursorPtr:resultCursorPtr];
    }
    
    CMTime bar025 = CMTimeMultiplyByRatio(bar05, 1, 2);
    for (int i = 0; i < 8; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar025 resultCursorPtr:resultCursorPtr];
    }
    
    CMTime bar0125 = CMTimeMultiplyByRatio(bar025, 1, 2);
    for (int i = 0; i < 8; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar0125 resultCursorPtr:resultCursorPtr];
    }
    
    CMTime bar00625 = CMTimeMultiplyByRatio(bar0125, 1, 2);
    for (int i = 0; i < 16; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:bar00625 resultCursorPtr:resultCursorPtr];
    }
}

@end
