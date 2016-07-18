//
//  MKRSceneA2.m
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneA2.h"

@implementation MKRSceneA2

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier];
    if (!self) {
        return nil;
    }
    [self setBarsCount:1];
    return self;
}

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    for (int i = 0; i < 4; i++) {
        MKRBar *bar = [barManager getBarWithQuantsLength:@(self.barsCount * 4 * barManager.QPB) withHighestGain:NO];
        if (bar == nil) {
            return NO;
        }
        [self.bars addObject:bar];
    }
    
    return YES;
}

@end
