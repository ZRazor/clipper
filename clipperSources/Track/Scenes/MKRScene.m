//
//  MKRScene.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRScene.h"

@interface MKRScene()

@property (readwrite, nonatomic) NSInteger identifier;

@end

static AVAsset *blank;

@implementation MKRScene

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setBars:[NSMutableArray<MKRBar *> new]];
    [self setIdentifier:identifier];
    
    return self;
}

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    @throw([NSException exceptionWithName:NSInternalInconsistencyException reason:@"You must override this method in subclass" userInfo:nil]);
}

- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(double)MSPQ {
//    NSLog(@"scene identifier = %ld", self.identifier);
    for (MKRBar *bar in self.bars) {
        AVMutableComposition *barAsset = [barsAssets objectForKey:@(bar.identifier)];
    
        CMTimeRange barTimeRange = CMTimeRangeMake(kCMTimeZero, barAsset.duration);
        [self makeCompositionBar:composition withBarAsset:barAsset andWithBar:bar andWithResultCursorPtr:resultCursorPtr andWithMSPQ:MSPQ andWithBarRange:barTimeRange usingAutoComplete:YES];

//        NSLog(@"bar id: %ld d: %f td: %f ql: %ld tql: %ld", bar.identifier, CMTimeGetSeconds(barAsset.duration), CMTimeGetSeconds(*resultCursorPtr), bar.quantsLength, bar.totalQuantsLength);
    }
}

- (void)makeCompositionBar:(AVMutableComposition *)composition withBarAsset:(AVMutableComposition *)barAsset andWithBar:(MKRBar *)bar andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(double)MSPQ andWithBarRange:(CMTimeRange)barTimeRange usingAutoComplete:(BOOL)autoComplete {
    
    if (barAsset == nil) {
        @throw([NSException exceptionWithName:@"Bar asset not found" reason:@"Bar asset not found" userInfo:nil]);
    }
    [self insertTimeRange:composition ofAsset:barAsset startAt:barTimeRange.start duration:barTimeRange.duration resultCursorPtr:resultCursorPtr];
    
    if (bar.totalQuantsLength > bar.quantsLength && autoComplete) {
        NSInteger quantsRemainder = bar.totalQuantsLength - bar.quantsLength;
        CMTime remainder = CMTimeMakeWithSeconds(quantsRemainder * MSPQ / 1000.0, 600000);
        [self insertEmptyInComposition:composition startAt:*resultCursorPtr duration:remainder];
//        [composition insertEmptyTimeRange:CMTimeRangeMake(*resultCursorPtr, remainder)];
        *resultCursorPtr = CMTimeAdd(*resultCursorPtr, remainder);
        NSLog(@"Shift cursor to %f", CMTimeGetSeconds(*resultCursorPtr));
    }
}

-(void)insertTimeRange:(AVMutableComposition *)composition ofAsset:(AVAsset *)asset startAt:(CMTime)startAt duration:(CMTime)duration resultCursorPtr:(CMTime *)resultCursorPtr {
    NSLog(@"Insert: [%f, %f] of [%f] at [%f]", CMTimeGetSeconds(startAt), CMTimeGetSeconds(duration), CMTimeGetSeconds(asset.duration), CMTimeGetSeconds(*resultCursorPtr));
    CMTime realDuration = CMTimeSubtract(CMTimeMinimum(duration, asset.duration), CMTimeMakeWithSeconds(1 / 1000.0, 600000));
    NSLog(@"RD: %f D: %f", CMTimeGetSeconds(realDuration), CMTimeGetSeconds(duration));
    CMTimeRange barTimeRange = CMTimeRangeMake(startAt, realDuration);
    NSLog(@"BarTimeRange = [%f, %f]", CMTimeGetSeconds(barTimeRange.start), CMTimeGetSeconds(barTimeRange.duration));
    
    NSError *insertionError;
    [composition insertTimeRange:barTimeRange ofAsset:asset atTime:*resultCursorPtr error:&insertionError];
    if (insertionError) {
        NSLog(@"insertion error = %@", insertionError);
    }
    
    [self insertEmptyInComposition:composition startAt:CMTimeAdd(*resultCursorPtr, realDuration) duration:CMTimeSubtract(duration, realDuration)];
    *resultCursorPtr = CMTimeAdd(*resultCursorPtr, duration);
    NSLog(@"cursor at %f", CMTimeGetSeconds(*resultCursorPtr));
}

- (void)insertEmptyInComposition:(AVMutableComposition *)composition startAt:(CMTime)startAt duration:(CMTime)duration {
    if (CMTimeGetSeconds(duration) == 0) {
        return;
    }
    if (blank) {
        NSString *blankPath = [[NSBundle mainBundle] pathForResource:@"blank_1080p" ofType:@"mp4"];
        blank = [AVAsset assetWithURL:[NSURL fileURLWithPath:blankPath]];
    }
    if (CMTimeCompare(duration, blank.duration) <= 0) {
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofAsset:blank atTime:startAt error:nil];
    } else {
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, blank.duration) ofAsset:blank atTime:startAt error:nil];
        [composition scaleTimeRange:CMTimeRangeMake(startAt, blank.duration) toDuration:duration];
    }
}

@end
