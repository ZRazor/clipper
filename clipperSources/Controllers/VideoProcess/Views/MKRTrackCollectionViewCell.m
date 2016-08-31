//
//  MKRTrackCollectionViewCell.m
//  clipper
//
//  Created by Anton Zlotnikov on 14.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRTrackCollectionViewCell.h"
#import "UIColor+MKRColor.h"
#import "CALayer+RuntimeAttribute.h"

@implementation MKRTrackCollectionViewCell

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        if (self.selected) {
            [self.layer setBorderIBColor:[UIColor mkr_darkRedColor]];
        } else {
            [self.layer setBorderIBColor:[UIColor mkr_darkRedColor]];
        }
    } else {
        if (self.selected) {
            [self.layer setBorderIBColor:[UIColor mkr_redColor]];
        } else {
            [self.layer setBorderIBColor:[UIColor clearColor]];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.layer setBorderIBColor:[UIColor mkr_redColor]];
    } else {
        [self.layer setBorderIBColor:[UIColor clearColor]];
    }
}

@end
