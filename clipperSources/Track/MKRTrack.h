//
//  MKRTrack.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKRTrack : NSObject

@property (nonatomic) NSMutableArray *scenes;
@property (nonatomic) NSInteger BPM;
@property (nonatomic) NSInteger QPB;
@property (nonatomic) double MSPQ;
@property (nonatomic) const Byte *samples;

-(instancetype)initWithScenes:(NSMutableArray *)scenes andBPM:(NSInteger)BPM andQPB:(NSInteger)QPB andSamples:(const Byte *)samples;

-(instancetype)initWithBPM:(NSInteger)BPM andQPB:(NSInteger)QPB;

@end
