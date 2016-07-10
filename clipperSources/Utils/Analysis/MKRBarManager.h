//
//  MKRBarManager.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRInterval.h"
#import "MKRBar.h"

@interface MKRBarManager : NSObject

@property (nonatomic) double MSPQ;
@property (nonatomic) NSInteger QPB;
@property (nonatomic) NSMutableArray<MKRInterval *> *features;
@property (nonatomic) NSMutableArray<MKRBar *> *registeredBars;

-(instancetype)initWithFeaturesIntervals:(NSMutableArray<MKRInterval *> *)features andMSPQ:(double)MSPQ andQPB:(NSInteger)QPB;

-(NSMutableArray<MKRBar *> *)getBarsWithQuantsLength:(NSNumber *)quantsLength;
-(MKRBar *)getBarWithQuantsLength:(NSNumber *)quantsLength;

@end
