//
//  SCPhotoSettingManager.h
//  SlideshowCreator
//
//  Created 11/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@interface SCPhotoSettingManager : SCBaseManager

@property (nonatomic,assign) SCEnumPhotoChooseType  photoChooseType;
@property (nonatomic,assign) SCEnumAlbumListType    albumListType;

- (id)init;
+ (SCPhotoSettingManager*)getInstance;
@end
