//
//  MKRTrack.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRTrack.h"

@implementation MKRTrack

-(instancetype)initWithScenes:(NSMutableArray *)scenes andBPM:(NSInteger)BPM andQPB:(NSInteger)QPB andSamples:(const Byte *)samples {
    self = [super init];
    if (!self) {
        return nil;
    }

    [self setScenes:[scenes copy]];
    [self setBPM:BPM];
    [self setQPB:QPB];
    [self setMSPQ:(1000.0 * 60.0  / self.BPM / self.QPB)];
    [self setSamples:samples];
    
    return self;
}

-(instancetype)initWithBPM:(NSInteger)BPM andQPB:(NSInteger)QPB {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setBPM:BPM];
    [self setQPB:QPB];
    [self setMSPQ:(1000.0 * 60.0  / self.BPM / self.QPB)];
    
    return self;
}

@end
