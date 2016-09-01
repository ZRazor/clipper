//
//  MKRBar.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRBar.h"

@interface MKRBar()

@property (readwrite, nonatomic) NSInteger identifier;

@end


static NSInteger globalIdentifier = 0;

@implementation MKRBar

-(instancetype)initWithSequence:(NSMutableArray<MKRProcessedInterval *> *)sequence andQuantsLength:(NSInteger)quantsLength andError:(double)error andTotalQuantsLength:(NSInteger)totalQuantsLength {
    self = [super init];
    if (!self) {
        return nil;
    }

    [self setSequence:[sequence copy]];
    [self setUsed:NO];
    [self setQuantsLength:quantsLength];
    [self setError:error];
    [self setTotalQuantsLength:totalQuantsLength];
    [self setIdentifier:globalIdentifier++];
    
    return self;
}

- (double)getAverageGainForSequence {
    if (![self.sequence count]) {
        return 0;
    }
    double gainSum = 0;
    for (MKRProcessedInterval *interval in self.sequence) {
        gainSum += interval.averageGain;
    }
    return gainSum / [self.sequence count];
}

- (BOOL)isUsed {
    if (self.used) {
        return YES;
    }
    for (MKRProcessedInterval *interval in self.sequence) {
        if (interval.useCount > 0) {
            return YES;
        }
    }
    return NO;
}

- (void)use {
    self.used = YES;
    for (MKRProcessedInterval *interval in self.sequence) {
        [interval use];
    }
}

@end
