//
//  SCAudioAutomation.m
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVolumeRampComposition.h"

@implementation SCVolumeRampComposition

@synthesize model = _model;
@synthesize startVolume = _startVolume;
@synthesize endVolume   = _endVolume;
@synthesize enable      = _enable;
- (id)init
{
    self = [super init];
    if(self)
    {
        self.enable = NO;
        self.model = [[SCVolumeRampModel alloc] init];
    }
    
    return self;
}

+ (id)volumeAutomationWithTimeRange:(CMTimeRange)timeRange startVolume:(float)startVolume endVolume:(float)endVolume
{
    SCVolumeRampComposition *volume = [[SCVolumeRampComposition alloc] init];
	volume.timeRange = timeRange;
	volume.startVolume = startVolume;
	volume.endVolume = endVolume;
    volume.enable     = NO;
    volume.model = [[SCVolumeRampModel alloc] init];
	return volume;
}


- (id)initWithModel:(SCCompositionModel *)model
{
    self = [super initWithModel:model];
    if(self)
    {
        if([model isKindOfClass:[SCVolumeRampModel class]])
        {
            self.model = (SCVolumeRampModel*)model;
            [self getInfoFromModel];
        }
    }
    
    return self;
}


#pragma mark - save/load process

- (void)updateModel
{
    [self clearModel];
    self.model.startTime = CMTimeGetSeconds(self.timeRange.start);
    self.model.duration = CMTimeGetSeconds(self.timeRange.duration);
    
    self.model.startVolume = self.startVolume;
    self.model.endVolume = self.endVolume;
    self.model.enable = self.enable;
}

- (void)getInfoFromModel
{
    if(self.model)
    {
        self.startVolume = self.model.startVolume;
        self.endVolume = self.model.endVolume;
        self.timeRange = CMTimeRangeMake(CMTimeMake(self.model.startTimeInTimeLine * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS), CMTimeMake(self.model.duration * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS));
        self.enable = self.model.enable;

    }
}

- (void)clearModel
{
    if(self.model)
    {
        [self.model clearAll];
        self.model = nil;
    }
    
    self.model = [[SCVolumeRampModel alloc] init];
}

#pragma mark - clear

- (void)clearAll
{
    [super clearAll];
    self.model = nil;
}


@end
