//
//  MKRCustomVideoCompositionInstruction.h
//  clipper
//
//  Created by Mikhail Zinov on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MKRCustomVideoCompositionInstruction : NSObject <AVVideoCompositionInstruction>

@property CMPersistentTrackID foregroundTrackID;
@property CMPersistentTrackID backgroundTrackID;

- (id)initPassThroughTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange;
- (id)initTransitionWithSourceTrackIDs:(NSArray*)sourceTrackIDs forTimeRange:(CMTimeRange)timeRange;

@end