//
//  MKRVolumeAnalyzer.h
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MKRVolumeAnalyzer : NSObject

+ (Float64)getAudioAverageVolumesRatioOfA:(NSURL *)aURL andB:(NSURL *)bURL;

@end
