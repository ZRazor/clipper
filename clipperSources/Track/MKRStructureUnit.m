//
// Created by Anton Zlotnikov on 15.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRStructureUnit.h"
#import "MKRScene.h"


@implementation MKRStructureUnit {
    MKRScene *scene;
    Float64 startTime;
    Float64 endTime;
}

- (instancetype)initWithScene:(MKRScene *)aScene {
    self = [super init];
    if (!self) {
        return nil;
    }
    scene = aScene;

    return self;
}

- (MKRScene *)getScene {
    return scene;
}

- (void)setTimeIntervalWithStartTime:(Float64)start andEndTime:(Float64)end {
    startTime = start;
    endTime = end;
}

- (Float64)getStartTime {
    return startTime;
}

- (Float64)getEndTime {
    return endTime;
}

@end