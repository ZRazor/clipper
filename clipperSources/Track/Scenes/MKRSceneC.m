//
//  MKRSceneC.m
//  clipper
//
//  Created by dev on 11.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneC.h"

@implementation MKRSceneC

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar = [barManager getBarWithQuantsLength:@(8 * 4 * barManager.QPB)];
    if (bar == nil) {
        return NO;
    }
    [self.bars addObject:bar];
    return YES;
}

- (void)makeCompositionBar:(AVMutableComposition *)composition withBarAsset:(AVMutableComposition *)barAsset andWithBar:(MKRBar *)bar andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(double)MSPQ andWithBarRange:(CMTimeRange)barTimeRange usingAutoComplete:(BOOL)autoComplete {
    if (!autoComplete) {
        [super makeCompositionBar:composition withBarAsset:barAsset andWithBar:bar andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:barTimeRange usingAutoComplete:autoComplete];
        return;
    }
    if (barAsset == nil) {
        @throw([NSException exceptionWithName:@"Bar asset not found" reason:@"Bar asset not found" userInfo:nil]);
    }
    if (bar.totalQuantsLength > bar.quantsLength) {
        NSInteger quantsRemainder = bar.totalQuantsLength - bar.quantsLength;
        CMTime remainder = CMTimeMakeWithSeconds(quantsRemainder * MSPQ / 1000.0, 60000);
        *resultCursorPtr = CMTimeAdd(*resultCursorPtr, remainder);
    }
    [self insertTimeRange:composition ofAsset:barAsset startAt:barTimeRange.start duration:barTimeRange.duration resultCursorPtr:resultCursorPtr];    
}

@end
