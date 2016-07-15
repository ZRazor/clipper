//
//  MKRAudioProcessor.h
//  clipper
//
//  Created by dev on 14.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRTrack.h"

@interface MKRAudioProcessor : NSObject

- (void)processTrack:(MKRTrack *)track andPlaybackFilePath:(NSString *)playbackPath withOriginalFilePath:(NSString *)originalPath completion:(void (^)(NSURL *audioURL))completionBlock failure:(void (^)(NSError *error))failureBlock;

- (instancetype)initWithOriginalPath:(NSString *)originalPath andPlaybackPath:(NSString *)playbackPath;

@end
