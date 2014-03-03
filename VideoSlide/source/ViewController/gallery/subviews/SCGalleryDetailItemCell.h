//
//  SCGalleryDetailItemCell.h
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCItemGridViewCell.h"

@protocol SCGalleryDetailItemCell <NSObject>

- (void)didSelectPlayAtIndex:(int)index;

@end

@interface SCGalleryDetailItemCell : SCItemGridViewCell

@property (nonatomic, strong) IBOutlet UIImageView  *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UIView       *previewView;

@property (nonatomic, strong) IBOutlet UILabel      *nameLb;
@property (nonatomic, strong) IBOutlet UILabel      *timeLb;
@property (nonatomic, strong) IBOutlet UILabel      *numberPhoto;

@property (nonatomic, strong) NSURL     *playURL;
@property (nonatomic)         int       index ;

@property (nonatomic, strong) SCSlideShowModel  *slideShow;

@property (nonatomic, weak) id<SCGalleryDetailItemCell>  delegate;

- (void)setDataWith:(SCSlideShowComposition*)slideShowData andImage:(UIImage*)img;
- (void)updateWithData:(SCSlideShowModel*)slideShow thumbnail:(UIImage*)thumbnail;
- (void)playVideo;
- (void)stopVideo;
- (void)pauseVideo;
@end
