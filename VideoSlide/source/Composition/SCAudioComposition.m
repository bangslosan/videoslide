//
//  SCAudioComposition.m
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCAudioComposition.h"

@implementation SCAudioComposition
@synthesize model = _model;
@synthesize fadeIn = _fadeIn;
@synthesize fadeOut = _fadeOut;
@synthesize volumeRamps = _volumeRamps;
@synthesize volume = _volume;
@synthesize normal = _normal;


- (id)initWithURL:(NSURL *)url fadeInTime:(float)fadeInTime fadeOutTime:(float)fadeOutTime
{
    self = [super initWithURL:url];
    if(self)
    {
        self.model = [[SCAudioModel alloc]init];
        self.volume = 1;

        self.volumeRamps = [[NSMutableArray alloc]init];
        self.normal =  [SCVolumeRampComposition volumeAutomationWithTimeRange:CMTimeRangeMake(CMTimeMake(0, SC_VIDEO_OUTPUT_FPS), self.duration)
                                                                  startVolume:self.volume
                                                                    endVolume:self.volume];
        [self.volumeRamps addObject:self.normal];

        if(CMTimeGetSeconds(self.timeRange.duration) >= (fadeOutTime + fadeInTime))
        {
            self.fadeIn = [SCVolumeRampComposition volumeAutomationWithTimeRange:CMTimeRangeMake(CMTimeMake(0, SC_VIDEO_OUTPUT_FPS), CMTimeMake(fadeInTime * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS))
                                                                     startVolume:0
                                                                       endVolume:self.volume];
            
            self.fadeOut = [SCVolumeRampComposition volumeAutomationWithTimeRange:CMTimeRangeMake(CMTimeSubtract(self.timeRange.duration, CMTimeMake(fadeOutTime*SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS)), CMTimeMake(fadeOutTime *SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS))
                                                                      startVolume:self.volume
                                                                        endVolume:0];
            
            [self.volumeRamps addObject:self.normal];
            [self.volumeRamps addObject:self.fadeIn];
            [self .volumeRamps addObject:self.fadeOut];
        }
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super initWithURL:url];
    if(self)
    {
        self.model = [[SCAudioModel alloc]init];
        self.volume = 1;

        self.volumeRamps = [[NSMutableArray alloc]init];
        self.normal =  [SCVolumeRampComposition volumeAutomationWithTimeRange:CMTimeRangeMake(CMTimeMake(0, SC_VIDEO_OUTPUT_FPS), self.duration)
                                                                  startVolume:self.volume
                                                                    endVolume:self.volume];
        [self.volumeRamps addObject:self.normal];
        

        if(CMTimeGetSeconds(self.timeRange.duration) >= 6)
        {
            self.fadeIn = [SCVolumeRampComposition volumeAutomationWithTimeRange:CMTimeRangeMake(CMTimeMake(0, SC_VIDEO_OUTPUT_FPS), CMTimeMake(SC_AUDIO_FADE_DEFAULT_DURATION * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS))
                                                                     startVolume:0
                                                                       endVolume:self.volume];
            
            self.fadeOut = [SCVolumeRampComposition volumeAutomationWithTimeRange:CMTimeRangeMake(CMTimeSubtract(self.timeRange.duration, CMTimeMake(SC_AUDIO_FADE_DEFAULT_DURATION * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS)), CMTimeMake(SC_AUDIO_FADE_DEFAULT_DURATION * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS))
                                                                      startVolume:self.volume
                                                                        endVolume:0];
            [self.volumeRamps addObject:self.fadeIn];
            [self .volumeRamps addObject:self.fadeOut];

        }
    }
    
    return self;
}

- (id)initWithModel:(SCCompositionModel *)model
{
    self = [super initWithModel:model];
    if(self)
    {
        if([model isKindOfClass:[SCAudioModel class]])
        {
            self.model = (SCAudioModel*)model;
            [self getInfoFromModel];
            //create asset
            self.asset = [AVURLAsset URLAssetWithURL:self.url options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];

        }
    }
    
    return self;
}

+ (id)audioCompositionWithURL:(NSURL *)url fadeInTime:(float)fadeInTime fadeOutTime:(float)fadeOutTime
{
    return [[self alloc] initWithURL:url fadeInTime:fadeInTime fadeOutTime:fadeOutTime];
}

+ (id)audioCompositionWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];

}

#pragma mark - save/load process
- (void)updateModel
{
    [self clearModel];
    self.model.duration         = CMTimeGetSeconds(self.duration);
    self.model.startTime        = CMTimeGetSeconds(self.timeRange.start);
    self.model.startTimeInTimeLine = CMTimeGetSeconds(self.startTimeInTimeline);
    self.model.name             = self.name;
    self.model.volume           = self.volume;
    self.model.audioFileURL     = self.url.path;
    self.model.projectURL       = self.projectURL.path;
    self.model.audioID          = self.mediaID;
    //fade in model
    [self.fadeIn updateModel];
    self.model.fadeIn = self.fadeIn.model;
    
    //fade out model
    [self.fadeOut updateModel];
    self.model.fadeOut = self.fadeOut.model;
    
    //volume model model
    [self.normal updateModel];
    self.model.normal = self.normal.model;

}

- (void)getInfoFromModel
{
    if(self.model)
    {
        self.volumeRamps = [[NSMutableArray alloc]init];
        self.volume = self.model.volume;
        self.normal  = [[SCVolumeRampComposition alloc] initWithModel:self.model.normal];
        [self.volumeRamps addObject:self.normal];


        if(self.model.audioFileURL && !self.model.audioID)
        {
            self.url = [NSURL fileURLWithPath:self.model.audioFileURL];
        }
        //for music with song from itunes
        else if(self.model.audioID)
        {
            self.mediaID = self.model.audioID;
            //get song from itunes that is available
            MPMediaQuery *everything = [[MPMediaQuery alloc] init];
            NSArray *itemsFromGenericQuery = [everything items];
            for(MPMediaItem *mediaItem in itemsFromGenericQuery)
            {
                NSString *songID = ((NSNumber*)[mediaItem valueForProperty: MPMediaItemPropertyPersistentID]).stringValue;
                if([self.mediaID isEqualToString:songID])
                {
                    self.url = [mediaItem valueForProperty: MPMediaItemPropertyAssetURL];
                    break;
                }
            }
            
            self.fadeIn = [[SCVolumeRampComposition alloc] initWithModel:self.model.fadeIn];
            self.fadeOut = [[SCVolumeRampComposition alloc] initWithModel:self.model.fadeOut];
            
            [self.volumeRamps addObject:self.fadeIn];
            [self .volumeRamps addObject:self.fadeOut];

        }
    }
}

- (void)clearModel
{
    if(self.model)
    {
        [self.model clearAll];
        self.model = nil;
    }
    
    self.model = [[SCAudioModel alloc] init];
}


#pragma mark - instance methods

- (NSString *)mediaType
{
	return AVMediaTypeAudio;
}



- (void)updateVolumeRamp
{
    self.fadeIn.endVolume = self.volume;
    self.fadeOut.startVolume = self.volume;
    
    if(self.normal)
    {
        self.normal.timeRange = CMTimeRangeMake(self.startTimeInTimeline, self.timeRange.duration);
        self.normal.startVolume = self.volume;
        self.normal.endVolume = self.volume;
        self.normal.enable = YES;
    }
    
    if(SC_AUDIO_FADE_DEFAULT_DURATION * 2 <= CMTimeGetSeconds(self.timeRange.duration))
    {
        if(self.fadeIn)
            self.fadeIn.timeRange = CMTimeRangeMake(self.startTimeInTimeline, CMTimeMake(SC_AUDIO_FADE_DEFAULT_DURATION * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS));
        if(self.fadeOut)
            self.fadeOut.timeRange = CMTimeRangeMake(CMTimeSubtract(CMTimeAdd(self.startTimeInTimeline, self.timeRange.duration), CMTimeMake(SC_AUDIO_FADE_DEFAULT_DURATION * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS)), CMTimeMake(SC_AUDIO_FADE_DEFAULT_DURATION * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS));
    }
    else if(CMTimeGetSeconds(self.timeRange.duration) < 6 && CMTimeGetSeconds(self.timeRange.duration) > 5)
    {
        if(self.fadeIn)
            self.fadeIn.timeRange = CMTimeRangeMake(self.startTimeInTimeline, CMTimeMake((CMTimeGetSeconds(self.timeRange.duration)/2) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS));
        if(self.fadeOut)
            self.fadeOut.timeRange = CMTimeRangeMake(CMTimeSubtract(CMTimeAdd(self.startTimeInTimeline, self.timeRange.duration), CMTimeMake((CMTimeGetSeconds(self.timeRange.duration)/2) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS)), CMTimeMake((CMTimeGetSeconds(self.timeRange.duration)/2) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS));
    }
    else
    {
        self.fadeIn.enable = NO;
        self.fadeOut.enable = NO;
    }
    
    
}

#pragma mark - clear all info

- (void)clearAll
{
    [super clearAll];
    self.model = nil;
    
    if(self.volumeRamps.count > 0)
        [self.volumeRamps removeAllObjects];
    self.volumeRamps = nil;
    
    self.fadeIn = nil;
    self.fadeOut = nil;
    self.normal = nil;
    
}


@end
