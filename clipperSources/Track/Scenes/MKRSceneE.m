//
//  MKRSceneE.m
//  clipper
//
//  Created by dev on 12.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneE.h"

@implementation MKRSceneE

-(BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar = [barManager getBarWithQuantsLength:@(4 * barManager.QPB)];
    if (!bar) {
        return NO;
    }
    [self.bars addObject:bar];
    return YES;
}

-(void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(NSInteger)MSPQ {
    MKRBar *bar = self.bars[0];
    AVMutableComposition *barAsset = [barsAssets objectForKey:@(bar.identifier)];
    CMTimeRange barTimeRange = CMTimeRangeMake(kCMTimeZero, barAsset.duration);
    CMTime barStartAt = *resultCursorPtr;
    [self makeCompositionBar:composition withBarAsset:barAsset andWithBar:bar andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:barTimeRange usingAutoComplete:YES];
    
    CMTime processedBarDuration = CMTimeSubtract(*resultCursorPtr, barStartAt);
    [self insertTimeRange:composition ofAsset:composition startAt:barStartAt duration:processedBarDuration resultCursorPtr:resultCursorPtr];
}

@end