//
//  MKRCustomVideoCompositionInstruction.m
//  clipper
//
//  Created by Mikhail Zinov on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRCustomVideoCompositionInstruction.h"

@implementation MKRCustomVideoCompositionInstruction

@synthesize timeRange = _timeRange;
@synthesize enablePostProcessing = _enablePostProcessing;
@synthesize containsTweening = _containsTweening;
@synthesize requiredSourceTrackIDs = _requiredSourceTrackIDs;
@synthesize passthroughTrackID = _passthroughTrackID;

- (id)initPassThroughTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange
{
    self = [super init];
    if (self) {
        _passthroughTrackID = passthroughTrackID;
        _requiredSourceTrackIDs = nil;
        _timeRange = timeRange;
        _containsTweening = FALSE;
        _enablePostProcessing = FALSE;
    }
    
    return self;
}

- (id)initTransitionWithSourceTrackIDs:(NSArray *)sourceTrackIDs forTimeRange:(CMTimeRange)timeRange
{
    self = [super init];
    if (self) {
        _requiredSourceTrackIDs = sourceTrackIDs;
        _passthroughTrackID = kCMPersistentTrackID_Invalid;
        _timeRange = timeRange;
        _containsTweening = TRUE;
        _enablePostProcessing = FALSE;
    }
    
    return self;
}


@end
