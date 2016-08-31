//
//  MKRTrackCollectionViewCell.m
//  clipper
//
//  Created by Anton Zlotnikov on 14.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRTrackCollectionViewCell.h"
#import "UIColor+MKRColor.h"

@implementation MKRTrackCollectionViewCell

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        if (self.selected) {
            [self.selectionView setAlpha:0.6];
        } else {
            [self.selectionView setAlpha:0.6];
        }
    } else {
        if (self.selected) {
            [self.selectionView setAlpha:0.4];
        } else {
            [self.selectionView setAlpha:0];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.selectionView setAlpha:0.4];
    } else {
        [self.selectionView setAlpha:0];
    }
}

@end
