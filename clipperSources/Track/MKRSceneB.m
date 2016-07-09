//
//  MKRSceneB.m
//  clipper
//
//  Created by dev on 09.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneB.h"

@implementation MKRSceneB

-(BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar = [barManager getBarWithQuantsLength:@(8 * barManager.MSPQ)];
    if (bar == nil) {
        return NO;
    }
    [self.bars addObject:bar];
    return YES;
}

@end
