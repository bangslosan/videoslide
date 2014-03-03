//
//  SCPhotoSettingManager.m
//  SlideshowCreator
//
//  Created 11/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotoSettingManager.h"

static SCPhotoSettingManager *instance;

@implementation SCPhotoSettingManager
@synthesize photoChooseType = _photoChooseType;
@synthesize albumListType = _albumListType;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.photoChooseType = SCEnumPhotoChooseTypeMultiple;
        self.albumListType = SCEnumAlbumListTypeNormal;
        
    }
    return self;
}

+ (SCPhotoSettingManager*)getInstance
{
    @synchronized([SCPhotoSettingManager class])
    {
        if(!instance)
            instance = [[self alloc] init];
        return instance;
    }
    
    return nil;
    
}

@end
