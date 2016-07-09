//
//  MKRSceneA.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRSceneA.h"
#import "MKRBar.h"

@implementation MKRSceneA : MKRScene

-(BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    MKRBar *bar1 = [barManager getBarWithQuantsLength:@(8 * barManager.QPB)];
    MKRBar *bar2 = [barManager getBarWithQuantsLength:@(8 * barManager.QPB)];
    if (bar1 == nil || bar2 == nil) {
        return NO;
    }
    [self.bars addObject:bar1];
    [self.bars addObject:bar2];
    
    return YES;
}

@end
