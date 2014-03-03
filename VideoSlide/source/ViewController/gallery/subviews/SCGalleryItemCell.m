//
//  SCGalleryItemCell.m
//  SlideshowCreator
//
//  Created 10/28/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCGalleryItemCell.h"

@implementation SCGalleryItemCell

@synthesize thumbnailImageView  =_thumbnailImageView;
@synthesize nameLb = _nameLb;
@synthesize dateCreatedLb = _dateCreatedLb;
@synthesize slideShow = _slideShow;

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
   // self.thumbnailImageView.layer.cornerRadius = 8;
}

- (void)setDataWithImage:(UIImage*)img  name:(NSString*)name date:(NSString*)date;
{
    [self.thumbnailImageView setImage:img];
    self.nameLb.text = name;
    self.dateCreatedLb.text = [NSString stringWithFormat:@"Created %@",date];

}


- (void)updateWithData:(SCSlideShowModel*)slideShow thumbnail:(UIImage*)thumbnail;
{
    self.slideShow = slideShow;
    [self.thumbnailImageView setImage:thumbnail];
    self.nameLb.text = slideShow.name;
    self.dateCreatedLb.text = [NSString stringWithFormat:@"Created %@",[SCHelper dateStringFrom:slideShow.dateCreated]];
}
@end
