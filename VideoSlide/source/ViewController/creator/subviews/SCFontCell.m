//
//  SCFontCell.m
//  SlideshowCreator
//
//  Created 10/17/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCFontCell.h"

@implementation SCFontCell
@synthesize fontNameLb;
@synthesize checkMarkImg;

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
