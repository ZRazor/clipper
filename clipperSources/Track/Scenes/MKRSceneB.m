//
//  MKRSceneB.m
//  clipper
//
//  Created by dev on 09.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneB.h"

@implementation MKRSceneB

-(BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar = [barManager getBarWithQuantsLength:@(4 * 2 * barManager.QPB)];
    if (bar == nil) {
        return NO;
    }
    [self.bars addObject:bar];
    
    return YES;
}

-(void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(NSInteger)MSPQ {
    NSLog(@"scene identifier = %ld", self.identifier);
    MKRBar *bar = self.bars[0];
    CMTime barStart = *resultCursorPtr;
    AVMutableComposition *barAsset = [barsAssets objectForKey:@(bar.identifier)];
    CMTimeRange barTimeRange = CMTimeRangeMake(kCMTimeZero, barAsset.duration);
    [self makeCompositionBar:composition withBarAsset:barAsset andWithBar:bar andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:barTimeRange usingAutoComplete:YES];

    CMTime processedBarDuration = CMTimeSubtract(*resultCursorPtr, barStart);
    CMTime bar05 = CMTimeMultiplyByRatio(processedBarDuration, 1, 2);
    CMTime bar025 = CMTimeMultiplyByRatio(processedBarDuration, 1, 4);
    CMTime bar0125 = CMTimeMultiplyByRatio(processedBarDuration, 1, 8);
    CMTime bar00625 = CMTimeMultiplyByRatio(processedBarDuration, 1, 16);

    [self insertTimeRange:composition ofAsset:composition startAt:barStart duration:processedBarDuration resultCursorPtr:resultCursorPtr];
    [self insertTimeRange:composition ofAsset:composition startAt:barStart duration:bar05 resultCursorPtr:resultCursorPtr];
    for (int i = 0; i < 2; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStart duration:bar025 resultCursorPtr:resultCursorPtr];
    }
    for (int i = 0; i < 4; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStart duration:bar0125 resultCursorPtr:resultCursorPtr];
    }
    for (int i = 0; i < 8; i++) {
        [self insertTimeRange:composition ofAsset:composition startAt:barStart duration:bar00625 resultCursorPtr:resultCursorPtr];
    }
}

@end
