//
//  SCAudipModel.h
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCompositionModel.h"
#import "SCVolumeRampModel.h"

@interface SCAudioModel : SCCompositionModel

@property (nonatomic, strong) NSString  *audioFileURL;
@property (nonatomic, strong) NSString  *audioID;
@property (nonatomic)         float     volume;
@property (nonatomic, strong) SCVolumeRampModel *fadeIn;
@property (nonatomic, strong) SCVolumeRampModel *fadeOut;
@property (nonatomic, strong) SCVolumeRampModel *normal;

@end
