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
            [self.contentView setBackgroundColor:[UIColor mkr_darkRedColor]];
        } else {
            [self.contentView setBackgroundColor:[UIColor mkr_darkGrayColor]];
        }
    } else {
        if (self.selected) {
            [self.contentView setBackgroundColor:[UIColor mkr_redColor]];
        } else {
            [self.contentView setBackgroundColor:[UIColor mkr_lightGrayColor]];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.contentView setBackgroundColor:[UIColor mkr_redColor]];
    } else {
        [self.contentView setBackgroundColor:[UIColor mkr_lightGrayColor]];
    }
}

@end
