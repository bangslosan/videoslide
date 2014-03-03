//
//  SCVolumeRampModel.h
//  SlideshowCreator
//
//  Created 10/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCompositionModel.h"

@interface SCVolumeRampModel : SCCompositionModel

@property (nonatomic) BOOL  enable;
@property (nonatomic) float startVolume;
@property (nonatomic) float endVolume;

@end
