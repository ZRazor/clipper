//
//  MKRSceneTrack06.m
//  clipper
//
//  Created by dev on 31.08.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneTrack06.h"
#import "MKRColorGlitchInstruction.h"
#import "MKRColorPosterizeFilterInstruction.h"
#import "MKRColorFadeFilterInstruction.h"

@implementation MKRSceneTrack06

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar1 = [barManager getBarWithQuantsLength:@(4 * 2 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar2 = [barManager getBarWithQuantsLength:@(4 * 1 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar3 = [barManager getBarWithQuantsLength:@(4 * 1 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar4 = [barManager getBarWithQuantsLength:@(4 * 2 * barManager.QPB) withHighestGain:NO];
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
//    CMTime start = *resultCursorPtr;
    AVMutableComposition *asset1 = [barsAssets objectForKey:@(self.bars[0].identifier)];
    AVMutableComposition *asset2 = [barsAssets objectForKey:@(self.bars[1].identifier)];
    AVMutableComposition *asset3 = [barsAssets objectForKey:@(self.bars[2].identifier)];
    AVMutableComposition *asset4 = [barsAssets objectForKey:@(self.bars[3].identifier)];

    [self makeCompositionBar:composition withBarAsset:asset1 andWithBar:self.bars[0] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset2 andWithBar:self.bars[1] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset3 andWithBar:self.bars[2] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset3.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset4 andWithBar:self.bars[3] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset4.duration) usingAutoComplete:YES];


    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:0 andEndTime:1263]];
    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:2526 andEndTime:1263 + 2526]];
    [filtersManager addInstruction:[[MKRColorPosterizeFilterInstruction alloc] initWithStartTime:0 andEndTime:1263]];
    [filtersManager addInstruction:[[MKRColorFadeFilterInstruction alloc] initWithStartTime:11000 andEndTime:15157 andFadeIn:NO]];
    [filtersManager addInstruction:[[MKRColorFadeFilterInstruction alloc] initWithStartTime:0 andEndTime:500 andFadeIn:YES]];
}

@end
