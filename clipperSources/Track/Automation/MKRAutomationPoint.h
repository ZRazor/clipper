//
//  MKRAutomationPoint.h
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MKRAutomationPoint : NSObject

@property (nonatomic) NSNumber *value;
@property (nonatomic) CMTime position;

- (instancetype)initWithTime:(CMTime)time andValue:(NSNumber *)value;

@end
