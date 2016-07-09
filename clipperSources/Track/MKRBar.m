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

-(instancetype)initWithSequence:(NSMutableArray *)sequence andQuantsLength:(NSInteger)quantsLength andError:(double)error andTotalQuantsLength:(NSInteger)totalQuantsLength {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setUsed:NO];
    [self setQuantsLength:quantsLength];
    [self setSequence:[sequence mutableCopy]];
    [self setError:error];
    [self setTotalQuantsLength:totalQuantsLength];
    [self setIdentifier:globalIdentifier++];
    
    return self;
}

@end
