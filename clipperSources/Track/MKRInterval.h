//
//  MKRInterval.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKRInterval : NSObject

@property (readonly, nonatomic) NSInteger start;
@property (readonly, nonatomic) NSInteger end;
@property (readonly, nonatomic) double averageGain;
@property (readwrite, nonatomic) NSInteger useCount;

/*!
 @abstract
    Returns length of the interval in milliseconds
 */
- (NSInteger)length;
- (void)use;

- (instancetype)initWithStart:(NSInteger)start andEnd:(NSInteger)end andAverageGain:(double)averageGain;

@end
