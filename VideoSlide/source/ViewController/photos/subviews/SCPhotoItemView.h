//
//  SCPhotoItemView.h
//  SlideshowCreator
//
//  Created 10/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCItemGridViewCell.h"

@interface SCPhotoItemView : SCItemGridViewCell

@property (nonatomic, strong) IBOutlet UIImageView  *photoImgView;
@property (nonatomic, strong) IBOutlet UIView       *checkMarkView;
@property (nonatomic, strong) IBOutlet UIImageView  *checkMarkImgView;

@end
