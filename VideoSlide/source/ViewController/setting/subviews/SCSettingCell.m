//
//  SCSettingCell.m
//  SlideshowCreator
//
//  Created 10/5/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSettingCell.h"

@implementation SCSettingCell
@synthesize socialIconImageView;
@synthesize socialNameLb;
@synthesize statusImageView;
@synthesize cellBackgroundImage;

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
