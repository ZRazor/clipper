//
//  MKRBarManager.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRBarManager.h"
#import "MKRProcessedInterval.h"

@implementation MKRBarManager{
    NSMutableDictionary *cache;
}

-(instancetype)initWithFeaturesIntervals:(NSMutableArray<MKRInterval *> *)features andMSPQ:(double)MSPQ andQPB:(NSInteger)QPB {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setMSPQ:MSPQ];
    [self setQPB:QPB];
    [self setFeatures:[features mutableCopy]];
    [self setRegisteredBars:[NSMutableArray<MKRBar *> new]];
    cache = [NSMutableDictionary new];
    
    return self;
}

-(NSMutableArray<MKRBar *> *)getBarsWithQuantsLength:(NSNumber *)quantsLength {
    if (cache[quantsLength] == nil) {
        [cache setObject:[self getBarsImplWithQuantsLength:quantsLength] forKey:quantsLength];
    }
    NSMutableArray<MKRBar *> *result = [cache objectForKey:quantsLength];
    return result;
}

-(MKRProcessedInterval *)calculateIntervalWithLeft:(double)left andRight:(double)right andBarErrorPtr:(double *)barErrorPtr {
    double msLength = right - left;
    double quantsLength = round(msLength / self.MSPQ);
    double warpedMsLength = quantsLength * self.MSPQ;
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
                double barError = totalBarError + (realQuantsLength - currentIntervalQuants) * self.MSPQ;
                MKRBar *bar = [[MKRBar alloc] initWithSequence:currentIntervalSequence andQuantsLength:currentIntervalQuants andError:barError andTotalQuantsLength:realQuantsLength];
                [self.registeredBars addObject:bar];
                [bars addObject:bar];
            }
            MKRProcessedInterval *foundInterval = [self calculateIntervalWithLeft:self.features[j].start andRight:self.features[j].end andBarErrorPtr:&totalBarError];
            if (currentIntervalQuants + foundInterval.quantsLength > realQuantsLength) {
                break;
            }
            mergeLeftMs = foundInterval.end;
            [currentIntervalSequence addObject:foundInterval];
            currentIntervalQuants += foundInterval.quantsLength;
            double barError = totalBarError + (realQuantsLength - currentIntervalQuants) * self.MSPQ;
            MKRBar *bar = [[MKRBar alloc] initWithSequence:currentIntervalSequence andQuantsLength:currentIntervalQuants andError:barError andTotalQuantsLength:realQuantsLength];
            [self.registeredBars addObject:bar];
            [bars addObject:bar];
        }
    }
    
    [bars sortUsingComparator:^NSComparisonResult(MKRBar *obj1, MKRBar *obj2) {
        return obj1.error >= obj2.error;
    }];
    
    return bars;
}

-(MKRBar *)getBarWithQuantsLength:(NSNumber *)quantsLength {
    NSMutableArray<MKRBar *> *bars = [self getBarsWithQuantsLength:quantsLength];
    MKRBar *result = nil;
    for (NSInteger i = 0; i < [bars count]; i++) {
        if (!bars[i].used) {
            result = bars[i];
            break;
        }
    }
    
    if (!result) {
        result = [bars count] > 0 ? bars[0] : nil;
    }
    
    if (result) {
        [result setUsed:YES];
    }
    
    return result;
}

@end
