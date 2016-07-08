//
//  MKRInterval.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRInterval.h"

@interface MKRInterval()

@property (readwrite, nonatomic) NSInteger start;
@property (readwrite, nonatomic) NSInteger end;

@end

@implementation MKRInterval

- (instancetype)initWithStart:(NSInteger)start andEnd:(NSInteger)end {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setStart:start];
    [self setEnd:end];
    
    return self;
}

- (NSInteger)length {
    return self.end - self.start;
}

@end
