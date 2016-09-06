//
//  MKRSceneTrack08.m
//  clipper
//
//  Created by dev on 02.09.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneTrack08.h"
#import "MKRColorFadeFilterInstruction.h"
#import "MKRColorGlitchInstruction.h"
#import "MKREdgeWorkFilterInstruction.h"
#import "MKRComicEffectFilterInstruction.h"
#import "MKREdgesFilterInstruction.h"

@implementation MKRSceneTrack08

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *intro = [barManager getBarWithQuantsLength:@(4 * 1 * barManager.QPB) withHighestGain:NO];
    // versus part 1
    MKRBar *a = [barManager getBarWithQuantsLength:@(2.5 * barManager.QPB) withHighestGain:NO];
    MKRBar *b = [barManager getBarWithQuantsLength:@(0.25 * barManager.QPB) withHighestGain:NO];
    MKRBar *c = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:NO];

    //versus part 2
    MKRBar *a1 = [barManager getBarWithQuantsLength:@(2.5 * barManager.QPB) withHighestGain:NO];
    MKRBar *b1 = [barManager getBarWithQuantsLength:@(0.25 * barManager.QPB) withHighestGain:NO];
    MKRBar *c1 = [barManager getBarWithQuantsLength:@(4 * barManager.QPB) withHighestGain:NO];

    if (intro == nil || a == nil || b == nil || c == nil || a1 == nil || b1 == nil || c1 == nil) {
        return NO;
    }
    [self.bars addObject:intro];
    [self.bars addObject:a];
    [self.bars addObject:b];
    [self.bars addObject:c];
    [self.bars addObject:a1];
    [self.bars addObject:b1];
    [self.bars addObject:c1];

    return YES;
}

- (void)insertVersusToComposition:(AVMutableComposition *)composition
                             andA:(AVMutableComposition *)aA
                             andB:(AVMutableComposition *)bA
                             andC:(AVMutableComposition *)cA andCBar:(MKRBar *)c
               andResultCursorPtr:(CMTime *)resultCursorPtr
                          andMSPQ:(double)MSPQ {
    [self insertTimeRange:composition ofAsset:aA startAt:kCMTimeZero duration:aA.duration resultCursorPtr:resultCursorPtr];
    for (int i = 0; i < 6; i++) {
        [self insertTimeRange:composition ofAsset:bA startAt:kCMTimeZero duration:bA.duration resultCursorPtr:resultCursorPtr];
    }
    [self makeCompositionBar:composition withBarAsset:cA andWithBar:c andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:CMTimeRangeMake(kCMTimeZero, cA.duration) usingAutoComplete:YES];
}

- (void)insertDropToComposition:(AVMutableComposition *)composition
                           andA:(AVMutableComposition *)aA
                           andB:(AVMutableComposition *)bA
                           andC:(AVMutableComposition *)cA
             andResultCursorPtr:(CMTime *)resultCursorPtr
              andFiltersManager:(MKRFiltersManager *)filtersManager
                        andMSPQ:(double)MSPQ {
    [self insertTimeRange:composition ofAsset:aA startAt:kCMTimeZero duration:CMTimeMultiplyByRatio(aA.duration, 2 * 7, 5 * 8) resultCursorPtr:resultCursorPtr];

    CMTime xDuration = CMTimeMultiplyByRatio(aA.duration, 1, 5);
    CMTime endAt = CMTimeAdd(*resultCursorPtr, xDuration);

    [filtersManager addInstruction:[[MKREdgeWorkFilterInstruction alloc] initWithStartTime:CMTimeGetSeconds(*resultCursorPtr) * 1000.0 andEndTime:CMTimeGetSeconds(endAt) * 1000.0]];
    [self insertTimeRange:composition ofAsset:aA startAt:kCMTimeZero duration:xDuration resultCursorPtr:resultCursorPtr];

    endAt = CMTimeAdd(*resultCursorPtr, xDuration);
    [filtersManager addInstruction:[[MKRComicEffectFilterInstruction alloc] initWithStartTime:CMTimeGetSeconds(*resultCursorPtr) * 1000.0 andEndTime:CMTimeGetSeconds(endAt) * 1000.0]];
    [self insertTimeRange:composition ofAsset:aA startAt:kCMTimeZero duration:xDuration resultCursorPtr:resultCursorPtr];

    endAt = CMTimeAdd(*resultCursorPtr, xDuration);
    [filtersManager addInstruction:[[MKREdgesFilterInstruction alloc] initWithStartTime:CMTimeGetSeconds(*resultCursorPtr) * 1000.0 andEndTime:CMTimeGetSeconds(endAt) * 1000.0]];
    [self insertTimeRange:composition ofAsset:aA startAt:kCMTimeZero duration:CMTimeMultiplyByRatio(aA.duration, 1 * 5, 5 * 4) resultCursorPtr:resultCursorPtr];
    for (int i = 0; i < 2; i++) {
        [self insertTimeRange:composition ofAsset:bA startAt:kCMTimeZero duration:bA.duration resultCursorPtr:resultCursorPtr];
    }
    [self insertTimeRange:composition ofAsset:aA startAt:kCMTimeZero duration:CMTimeMultiplyByRatio(aA.duration, 2, 5) resultCursorPtr:resultCursorPtr];
    for (int i = 0; i < 4; i++) {
        [self insertTimeRange:composition ofAsset:aA startAt:kCMTimeZero duration:CMTimeMultiplyByRatio(aA.duration, 1, 10) resultCursorPtr:resultCursorPtr];
    }
    [self insertTimeRange:composition ofAsset:cA startAt:kCMTimeZero duration:CMTimeMultiplyByRatio(cA.duration, 3, 4) resultCursorPtr:resultCursorPtr];
}

- (void)insertImageInComposition:(AVMutableComposition *)composition andStartAt:(CMTime)startAt andEndAt:(CMTime)endAt {
    AVMutableCompositionTrack *imageTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    NSString * bangPath = [[NSBundle mainBundle] pathForResource:@"bang" ofType:@"png" inDirectory:@"assets/tracks"];
    NSURL *URL = [NSURL fileURLWithPath:bangPath];
    NSData *bangData = [NSData dataWithContentsOfURL:URL];
    CIImage *bang = [CIImage imageWithData:bangData];
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contents = (id)bang;


}

- (void)makeComposition:(AVMutableComposition *)composition
          withBarAssets:(NSMutableDictionary *)barsAssets
     andResultCursorPtr:(CMTime *)resultCursorPtr
                andMSPQ:(double)MSPQ
         andAutomations:(NSMutableArray<MKRAutomationLane *> *)automations
      andFiltersManager:(MKRFiltersManager *)filtersManager {
    AVMutableComposition *introA = [barsAssets objectForKey:@(self.bars[0].identifier)];
    AVMutableComposition *aA = [barsAssets objectForKey:@(self.bars[1].identifier)];
    AVMutableComposition *bA = [barsAssets objectForKey:@(self.bars[2].identifier)];
    AVMutableComposition *cA = [barsAssets objectForKey:@(self.bars[3].identifier)];
    AVMutableComposition *a1A = [barsAssets objectForKey:@(self.bars[4].identifier)];
    AVMutableComposition *b1A = [barsAssets objectForKey:@(self.bars[5].identifier)];
    AVMutableComposition *c1A = [barsAssets objectForKey:@(self.bars[6].identifier)];

    MKRBar *intro = self.bars[0];
    MKRBar *c = self.bars[3];
    MKRBar *c1 = self.bars[6];

    [self makeCompositionBar:composition
                withBarAsset:introA
                  andWithBar:intro
      andWithResultCursorPtr:resultCursorPtr
                 andWithMSPQ:MSPQ
             andWithBarRange:CMTimeRangeMake(kCMTimeZero, introA.duration)
           usingAutoComplete:YES];

    //VERSUS 1.1
    [self insertVersusToComposition:composition
                               andA:aA
                               andB:bA
                               andC:cA
                            andCBar:c
                 andResultCursorPtr:resultCursorPtr
                            andMSPQ:MSPQ];
    [self insertVersusToComposition:composition
                               andA:aA
                               andB:bA
                               andC:cA
                            andCBar:c
                 andResultCursorPtr:resultCursorPtr
                            andMSPQ:MSPQ];
    //VERSUS 1.2
    [self insertVersusToComposition:composition
                               andA:a1A
                               andB:b1A
                               andC:c1A
                            andCBar:c1
                 andResultCursorPtr:resultCursorPtr
                            andMSPQ:MSPQ];
    [self insertVersusToComposition:composition
                               andA:a1A
                               andB:b1A
                               andC:c1A
                            andCBar:c1
                 andResultCursorPtr:resultCursorPtr
                            andMSPQ:MSPQ];

    //DROP 1.1
    [self insertDropToComposition:composition
                             andA:aA
                             andB:bA
                             andC:cA
               andResultCursorPtr:resultCursorPtr
                andFiltersManager:filtersManager
                          andMSPQ:MSPQ];
    [self insertDropToComposition:composition
                             andA:aA
                             andB:bA
                             andC:cA
               andResultCursorPtr:resultCursorPtr
                andFiltersManager:filtersManager
                          andMSPQ:MSPQ];
    //DROP 1.2
    [self insertDropToComposition:composition
                             andA:a1A
                             andB:b1A
                             andC:c1A
               andResultCursorPtr:resultCursorPtr
                andFiltersManager:filtersManager
                          andMSPQ:MSPQ];
    [self insertDropToComposition:composition
                             andA:a1A
                             andB:b1A
                             andC:c1A
               andResultCursorPtr:resultCursorPtr
                andFiltersManager:filtersManager
                          andMSPQ:MSPQ];
//    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:7111 andEndTime:8888]];
//    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:8888 andEndTime:10665]];
//    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:10665 andEndTime:12442]];
//    [filtersManager addInstruction:[[MKRColorGlitchInstruction alloc] initWithStartTime:12442 andEndTime:14219]];
    [filtersManager addInstruction:[[MKRColorFadeFilterInstruction alloc] initWithStartTime:0 andEndTime:1800 andFadeIn:YES]];
    [filtersManager addInstruction:[[MKRColorFadeFilterInstruction alloc] initWithStartTime:31500 andEndTime:37245 andFadeIn:NO andThreshold:0.5]];
}

@end
