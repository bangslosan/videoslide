//
//  SCPhotoAlbumCell.m
//  SlideshowCreator
//
//  Created 11/19/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotoAlbumCell.h"

@implementation SCPhotoAlbumCell
@synthesize albumMetaLb;
@synthesize coverImgView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
