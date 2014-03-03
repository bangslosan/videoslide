//
//  SCPhotoItemView.m
//  SlideshowCreator
//
//  Created 10/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotoItemView.h"

@implementation SCPhotoItemView

@synthesize photoImgView = _photoImgView;
@synthesize checkMarkView = _checkMarkView;
@synthesize checkMarkImgView = _checkMarkImgView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib
{
    
}

@end
