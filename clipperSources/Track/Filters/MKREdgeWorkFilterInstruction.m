//
//  MKREdgeWorkFilterInstruction.m
//  clipper
//
//  Created by dev on 02.09.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKREdgeWorkFilterInstruction.h"

@implementation MKREdgeWorkFilterInstruction {
    CIFilter *filter;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CIEdgeWork"
                  withInputParameters: @{
                                         @"inputRadius": @3,
                                         }];
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}

@end
