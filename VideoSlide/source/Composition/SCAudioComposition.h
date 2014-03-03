//
//  SCAudioComposition.h
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCMediaComposition.h"
#import "SCVolumeRampComposition.h"

@interface SCAudioComposition : SCMediaComposition

@property (nonatomic, strong) SCAudioModel *model;
@property (nonatomic, strong) NSMutableArray          *volumeRamps;
@property (nonatomic, strong) SCVolumeRampComposition *fadeIn;
@property (nonatomic, strong) SCVolumeRampComposition *fadeOut;
@property (nonatomic, strong) SCVolumeRampComposition *normal;

@property (nonatomic)         float                    volume;


- (id)initWithURL:(NSURL *)url fadeInTime:(float)fadeInTime fadeOutTime:(float)fadeOutTime;
+ (id)audioCompositionWithURL:(NSURL *)url;
+ (id)audioCompositionWithURL:(NSURL *)url fadeInTime:(float)fadeInTime fadeOutTime:(float)fadeOutTime;
- (void)updateVolumeRamp;

@end
