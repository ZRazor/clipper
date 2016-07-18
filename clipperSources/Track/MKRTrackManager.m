//
// Created by Anton Zlotnikov on 18.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRTrackManager.h"

@implementation MKRTrackManager {
    NSMutableArray<NSString *> *tracksNames;
}

static NSString *const kMKRTracksPath = @"assets/tracks";

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    tracksNames = [NSMutableArray new];
    NSArray *plists = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"plist" subdirectory:kMKRTracksPath];
    for (NSURL *url in plists) {
        [tracksNames addObject:[[url URLByDeletingPathExtension] lastPathComponent]];
    }

    return self;
}

- (NSInteger)tracksCount {
    return [tracksNames count];
}

- (NSString *)trackNameForRow:(NSInteger)row {
    return tracksNames[row];
}

- (NSString *)pathForMetaDesc:(NSString *)trackName {
    return [[NSBundle mainBundle] pathForResource:trackName ofType:@"plist" inDirectory:kMKRTracksPath];
}

- (NSString *)pathForPlayback:(NSString *)trackName {
    return [[NSBundle mainBundle] pathForResource:trackName ofType:@"wav" inDirectory:kMKRTracksPath];
}


@end