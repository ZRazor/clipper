//
//  MKRRecordButton.m
//  clipper
//
//  Created by Anton Zlotnikov on 14.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRRecordButton.h"
#import "UIColor+MKRColor.h"

@implementation MKRRecordButton


- (void)drawRect:(CGRect)rect {
    [self setBackgroundColor:[UIColor mkr_mainColor]];
    [self.layer setBorderColor:[UIColor mkr_mainColor].CGColor];
    [self.layer setBorderWidth:1.f];
    [self.layer setCornerRadius:33.f];
    [self setClipsToBounds:YES];
}

- (void)clickRecording {
    self.isRecording = !self.isRecording;
//    if (self.isRecording) {
//        [self setBackgroundColor:[UIColor mkr_redColor]];
//    } else {
//        [self setBackgroundColor:[UIColor mkr_lightGrayColor]];
//    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (!enabled) {
        [self setBackgroundColor:[UIColor clearColor]];
    } else {
        if (self.isRecording) {
            [self setBackgroundColor:[UIColor mkr_redColor]];
        } else {
            [self setBackgroundColor:[UIColor mkr_lightGrayColor]];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        if (self.isRecording) {
            [self setBackgroundColor:[UIColor mkr_darkRedColor]];
        } else {
            [self setBackgroundColor:[UIColor mkr_darkGrayColor]];
        }
    } else {
        if (self.isRecording) {
            [self setBackgroundColor:[UIColor mkr_redColor]];
        } else {
            [self setBackgroundColor:[UIColor mkr_lightGrayColor]];
        }
    }
}

@end
