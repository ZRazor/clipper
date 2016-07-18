//
//  MKRSceneA1.m
//  clipper
//
//  Created by dev on 12.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneA1.h"

@implementation MKRSceneA1

-(instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier];
    if (!self) {
        return nil;
    }
    [self setBarsCount:2];
    return self;
}

- (NSArray<AVMutableVideoCompositionInstruction *>*)getPostVideoLayerInstractins {
    return @[];
}

@end
