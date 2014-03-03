//
//  SCAudioAutomation.h
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCComposition.h"
#import "SCVolumeRampModel.h"

@interface SCVolumeRampComposition : SCComposition

@property (nonatomic, strong) SCVolumeRampModel *model;
@property (nonatomic) BOOL  enable;
@property (nonatomic) float startVolume;
@property (nonatomic) float endVolume;

+ (id)volumeAutomationWithTimeRange:(CMTimeRange)timeRange startVolume:(CGFloat)startVolume endVolume:(CGFloat)endVolume;


@end
