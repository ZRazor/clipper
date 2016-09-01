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
    NSMutableDictionary<NSString *, MKRProcessedInterval *> *intervalsCache;
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

    intervalsCache = [NSMutableDictionary<NSString *, MKRProcessedInterval *> new];
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

-(MKRProcessedInterval *)calculateIntervalWithLeft:(double)left
                                          andRight:(double)right
                                    andAverageGain:(double)averageGain
                                    andBarErrorPtr:(double *)barErrorPtr {
    NSString *key = [NSString stringWithFormat:@"%.20lf;%.20lf", left, right];
    if (intervalsCache[key] == nil) {
        double msLength = right - left;
        double quantsLength = MAX(round(msLength / self.MSPQ), 1);
        double warpedMsLength = quantsLength * self.MSPQ;
        double speedFactor = msLength / warpedMsLength;
        *barErrorPtr += fabs(warpedMsLength - msLength);
        MKRProcessedInterval *interval = [[MKRProcessedInterval alloc] initWithStart:left
                                                                              andEnd:right
                                                                      andAverageGain:averageGain
                                                                      andSpeedFactor:speedFactor
                                                                     andQuantsLength:quantsLength
                                                                         andMsLength:msLength
                                                                   andWarpedMsLength:warpedMsLength];
        [intervalsCache setObject:interval forKey:key];
    }

    return intervalsCache[key];
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
                //TODO calc gain for non-voiced intervals
                MKRProcessedInterval *foundInterval = [self calculateIntervalWithLeft:mergeLeftMs
                                                                             andRight:leftMs
                                                                       andAverageGain:0
                                                                       andBarErrorPtr:&totalBarError];
                if (currentIntervalQuants + foundInterval.quantsLength > realQuantsLength) {
                    break;
                }
                [currentIntervalSequence addObject:foundInterval];
                currentIntervalQuants += foundInterval.quantsLength;
                double barError = totalBarError + (realQuantsLength - currentIntervalQuants) * self.MSPQ;
                MKRBar *bar = [[MKRBar alloc] initWithSequence:currentIntervalSequence
                                               andQuantsLength:currentIntervalQuants
                                                      andError:barError
                                          andTotalQuantsLength:realQuantsLength];
                [self.registeredBars addObject:bar];
                [bars addObject:bar];
            }
            MKRProcessedInterval *foundInterval = [self calculateIntervalWithLeft:self.features[j].start
                                                                         andRight:self.features[j].end
                                                                   andAverageGain:self.features[j].averageGain
                                                                   andBarErrorPtr:&totalBarError];
            if (currentIntervalQuants + foundInterval.quantsLength > realQuantsLength) {
                break;
            }
            mergeLeftMs = foundInterval.end;
            [currentIntervalSequence addObject:foundInterval];
            currentIntervalQuants += foundInterval.quantsLength;
            double barError = totalBarError + (realQuantsLength - currentIntervalQuants) * self.MSPQ;
            MKRBar *bar = [[MKRBar alloc] initWithSequence:currentIntervalSequence
                                           andQuantsLength:currentIntervalQuants
                                                  andError:barError
                                      andTotalQuantsLength:realQuantsLength];
            [self.registeredBars addObject:bar];
            [bars addObject:bar];
        }
    }
    
    [bars sortUsingComparator:^NSComparisonResult(MKRBar *obj1, MKRBar *obj2) {
        if (obj1.error > obj2.error) {
            return NSOrderedDescending;
        }

        if (obj1.error < obj2.error) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    return bars;
}

-(MKRBar *)getBarWithQuantsLength:(NSNumber *)quantsLength withHighestGain:(BOOL)highestGain {
    NSMutableArray<MKRBar *> *bars = [self getBarsWithQuantsLength:quantsLength];
    if (highestGain) {
        [bars sortUsingComparator:^NSComparisonResult(MKRBar *obj1, MKRBar *obj2) {
            double gain1 = [obj1 getAverageGainForSequence];
            double gain2 = [obj2 getAverageGainForSequence];
            if (gain1 > gain2) {
                return NSOrderedAscending;
            }

            if (gain1 < gain2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
    }
    
    BOOL preferNotUsed = !highestGain;
    
    MKRBar *result = nil;
    for (NSInteger i = 0; i < [bars count]; i++) {
        if (preferNotUsed) {
            if (![bars[i] isUsed]) {
                result = bars[i];
                break;
            }
        } else {
            result = bars[i];
            break;
        }
    }
    
    if (!result) {
        result = [bars count] > 0 ? bars[0] : nil;
    }
    
    if (result) {
        [result use];
    }
    
    if (highestGain) {
        NSLog(@"Selected Bar with gain %lf", [result getAverageGainForSequence]);
    }
    
    return result;
}

@end
