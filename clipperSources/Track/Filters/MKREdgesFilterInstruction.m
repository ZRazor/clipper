//
//  MKREdgesFilterInstruction.m
//  clipper
//
//  Created by dev on 02.09.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKREdgesFilterInstruction.h"

@implementation MKREdgesFilterInstruction {
    CIFilter *filter;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CIEdges"
                  withInputParameters: @{
                                         @"inputIntensity": @30.0
                                         }];
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}
@end
