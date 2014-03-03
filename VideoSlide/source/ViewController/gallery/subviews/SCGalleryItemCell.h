//
//  SCGalleryItemCell.h
//  SlideshowCreator
//
//  Created 10/28/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCItemGridViewCell.h"

@interface SCGalleryItemCell : SCItemGridViewCell

@property (nonatomic, strong) IBOutlet UIImageView  *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel      *nameLb;
@property (nonatomic, strong) IBOutlet UILabel      *dateCreatedLb;
@property (nonatomic, strong) SCSlideShowModel *slideShow;

- (void)setDataWithImage:(UIImage*)img  name:(NSString*)name date:(NSString*)date;
- (void)updateWithData:(SCSlideShowModel*)slideShow thumbnail:(UIImage*)thumbnail;

@end
