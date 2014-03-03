//
//  SCPhotoAlbumCell.h
//  SlideshowCreator
//
//  Created 11/19/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCPhotoAlbumCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView       *coverImgView;
@property (nonatomic,strong) IBOutlet UILabel           *albumMetaLb;
@property (nonatomic,strong) IBOutlet UILabel           *albumNumberPhotosLb;

@end
