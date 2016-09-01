//
//  MKRSceneTrack07.m
//  clipper
//
//  Created by dev on 01.09.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneTrack07.h"
#import "MKRColorFadeFilterInstruction.h"
#import "MKRColorGlitchInstruction.h"

@implementation MKRSceneTrack07

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar1 = [barManager getBarWithQuantsLength:@(4 * 1 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar2 = [barManager getBarWithQuantsLength:@(4 * 1 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar3 = [barManager getBarWithQuantsLength:@(2 * 1 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar4 = [barManager getBarWithQuantsLength:@(2 * 1 * barManager.QPB) withHighestGain:NO];

    MKRBar *bar5 = [barManager getBarWithQuantsLength:@(4 * 1 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar6 = [barManager getBarWithQuantsLength:@(4 * 1 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar7 = [barManager getBarWithQuantsLength:@(2 * 1 * barManager.QPB) withHighestGain:NO];
    MKRBar *bar8 = [barManager getBarWithQuantsLength:@(2 * 1 * barManager.QPB) withHighestGain:NO];

    MKRBar *bar9 = [barManager getBarWithQuantsLength:@(4 * 3 * barManager.QPB) withHighestGain:NO];

    if (bar1 == nil || bar2 == nil || bar3 == nil || bar4 == nil || bar5 == nil || bar6 == nil || bar7 == nil || bar8 == nil || bar9 == nil) {
        return NO;
    }
    [self.bars addObject:bar1];
    [self.bars addObject:bar2];
    [self.bars addObject:bar3];
    [self.bars addObject:bar4];
    [self.bars addObject:bar5];
    [self.bars addObject:bar6];
    [self.bars addObject:bar7];
    [self.bars addObject:bar8];
    [self.bars addObject:bar9];

    return YES;
}

- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andResultCursorPtr:(CMTime *)resultCursorPtr andMSPQ:(double)MSPQ andAutomations:(NSMutableArray<MKRAutomationLane *> *)automations andFiltersManager:(MKRFiltersManager *)filtersManager {
    //    CMTime start = *resultCursorPtr;
    AVMutableComposition *asset0 = [barsAssets objectForKey:@(self.bars[0].identifier)];
    AVMutableComposition *asset1 = [barsAssets objectForKey:@(self.bars[1].identifier)];
    AVMutableComposition *asset2 = [barsAssets objectForKey:@(self.bars[2].identifier)];
    AVMutableComposition *asset3 = [barsAssets objectForKey:@(self.bars[3].identifier)];

    AVMutableComposition *asset4 = [barsAssets objectForKey:@(self.bars[4].identifier)];
    AVMutableComposition *asset5 = [barsAssets objectForKey:@(self.bars[5].identifier)];
    AVMutableComposition *asset6 = [barsAssets objectForKey:@(self.bars[6].identifier)];
    AVMutableComposition *asset7 = [barsAssets objectForKey:@(self.bars[7].identifier)];

    AVMutableComposition *asset8 = [barsAssets objectForKey:@(self.bars[8].identifier)];

    [self makeCompositionBar:composition withBarAsset:asset0 andWithBar:self.bars[0] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset0.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset1 andWithBar:self.bars[1] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset0 andWithBar:self.bars[0] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset0.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset2 andWithBar:self.bars[2] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset3 andWithBar:self.bars[3] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset3.duration) usingAutoComplete:YES];

    [self makeCompositionBar:composition withBarAsset:asset4 andWithBar:self.bars[4] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset4.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset5 andWithBar:self.bars[5] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset5.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset4 andWithBar:self.bars[4] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset4.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset6 andWithBar:self.bars[6] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset6.duration) usingAutoComplete:YES];
    [self makeCompositionBar:composition withBarAsset:asset7 andWithBar:self.bars[7] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset7.duration) usingAutoComplete:YES];

    [self insertTimeRange:composition ofAsset:composition startAt:kCMTimeZero duration:*resultCursorPtr resultCursorPtr:resultCursorPtr];

    [self makeCompositionBar:composition withBarAsset:asset8 andWithBar:self.bars[8] andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, asset8.duration) usingAutoComplete:YES];


    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:7111 andEndTime:8888]];
    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:8888 andEndTime:10665]];
    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:10665 andEndTime:12442]];
    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:12442 andEndTime:14219]];
    [filtersManager addInstruction:[[MKRColorFadeFilterInstruction alloc] initWithStartTime:0 andEndTime:500 andFadeIn:YES]];
    [filtersManager addInstruction:[[MKRColorFadeFilterInstruction alloc] initWithStartTime:30000 andEndTime:33832 andFadeIn:NO]];
}

@end
