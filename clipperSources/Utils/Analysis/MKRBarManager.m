//
//  MKRBarManager.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRBarManager.h"
#import "MKRInterval.h"
#import "MKRProcessedInterval.h"
#import "MKRBar.h"

@implementation MKRBarManager{
    NSMutableDictionary *cache;
}

-(instancetype)initWithTrack:(MKRTrack *)track andFeaturesIntervals:(NSMutableArray<MKRInterval *> *)features {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    cache = [NSMutableDictionary new];
    
    [self setTrack:track];
    [self setFeatures:[features mutableCopy]];
    return self;
}

-(NSMutableArray<MKRBar *> *)getBarsWithQuantsLength:(NSNumber *)quantsLength {
    if (cache[quantsLength] == nil) {
        NSLog(@"MKRBarManager.getBarsWithQuantsLength has no cache for quantsLength %lu", [quantsLength longValue]);
        [cache setObject:[self getBarsImplWithQuantsLength:quantsLength] forKey:quantsLength];
    }
    NSMutableArray<MKRBar *> *result = [cache objectForKey:quantsLength];
    NSLog(@"MKRBarManager.getBarsWithQuantsLength return %lu bars", [result count]);
    return result;
}

-(MKRProcessedInterval *)calculateIntervalWithLeft:(double)left andRight:(double)right andBarErrorPtr:(double *)barErrorPtr {
    double msLength = right - left;
    double quantsLength = round(msLength / self.track.MSPQ);
    double warpedMsLength = quantsLength * self.track.MSPQ;
    double speedFactor = msLength / warpedMsLength;
    *barErrorPtr += fabs(warpedMsLength - msLength);
    MKRProcessedInterval *interval = [[MKRProcessedInterval alloc] initWithStart:left andEnd:right andSpeedFactor:speedFactor andQuantsLength:quantsLength andMsLength:msLength andWarpedMsLength:warpedMsLength];
    
    return interval;
    
}

-(NSMutableArray<MKRBar *> *)getBarsImplWithQuantsLength:(NSNumber *)quantsLength {
    NSMutableArray<MKRBar *> *bars = [NSMutableArray new];
    long realQuantsLength = [quantsLength longValue];
    for (int i = 0; i < [self.features count]; i++) {
        NSMutableArray<MKRProcessedInterval *> *currentIntervalSequence = [NSMutableArray new];
        int currentIntervalQuants = 0;
        double mergeLeftMs = self.features[i].end;
        double totalBarError = 0;
        for (int j = i; j < [self.features count]; j++) {
            double leftMs = self.features[j].start;
            if (leftMs - mergeLeftMs > 0) {
                MKRProcessedInterval *foundInterval = [self calculateIntervalWithLeft:mergeLeftMs andRight:leftMs andBarErrorPtr:&totalBarError];
                if (currentIntervalQuants + foundInterval.quantsLength > realQuantsLength) {
                    break;
                }
                [currentIntervalSequence addObject:foundInterval];
                currentIntervalQuants += foundInterval.quantsLength;
                double barError = totalBarError + (realQuantsLength - currentIntervalQuants) * self.track.MSPQ + foundInterval.speedFactor * 100;
                MKRBar *bar = [[MKRBar alloc] initWithSequence:currentIntervalSequence andQuantsLength:currentIntervalQuants andError:barError andTotalQuantsLength:realQuantsLength];
                [bars addObject:bar];
            }
            MKRProcessedInterval *foundInterval = [self calculateIntervalWithLeft:self.features[j].start andRight:self.features[j].end andBarErrorPtr:&totalBarError];
            if (currentIntervalQuants + foundInterval.quantsLength > realQuantsLength) {
                break;
            }
            mergeLeftMs = foundInterval.start;
            [currentIntervalSequence addObject:foundInterval];
            currentIntervalQuants += foundInterval.quantsLength;
            double barError = totalBarError + (realQuantsLength - currentIntervalQuants) * self.track.MSPQ + foundInterval.speedFactor * 100;
            MKRBar *bar = [[MKRBar alloc] initWithSequence:currentIntervalSequence andQuantsLength:currentIntervalQuants andError:barError andTotalQuantsLength:realQuantsLength];
            [bars addObject:bar];
        }
    }
    
    [bars sortUsingComparator:^NSComparisonResult(MKRBar *obj1, MKRBar *obj2) {
        return obj1.error >= obj2.error;
    }];
    
    return bars;
}

@end
