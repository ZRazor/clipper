//
//  MKRBar.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRProcessedInterval.h"

@interface MKRBar : NSObject

@property (nonatomic) NSMutableArray<MKRProcessedInterval *> *sequence;
@property (nonatomic) NSInteger quantsLength;
@property (nonatomic) double error;
@property (nonatomic) NSInteger totalQuantsLength;
@property (readonly, nonatomic) NSInteger identifier;
@property (nonatomic) BOOL used;

- (instancetype)initWithSequence:(NSMutableArray<MKRProcessedInterval *> *)sequence andQuantsLength:(NSInteger)quantsLength andError:(double)error andTotalQuantsLength:(NSInteger)totalQuantsLength;

- (double)getAverageGainForSequence;
@end
