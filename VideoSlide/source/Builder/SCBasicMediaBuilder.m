//
//  SCVideoBuilder.m
//  SlideshowCreator
//
//  Created 9/24/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBasicMediaBuilder.h"

@interface SCBasicMediaBuilder ()

@property (nonatomic, strong)   SCSlideShowComposition *slideShow;
@property (nonatomic, strong)   AVMutableComposition *composition;
@property (nonatomic, strong)   AVMutableVideoComposition *videoComposition;
@property (nonatomic, weak)     AVMutableCompositionTrack *musicTrack;
@property (nonatomic, weak)     AVMutableCompositionTrack *audioTrack;

- (AVMutableCompositionTrack*)addCompositionTrackOfType:(NSString *)mediaType forMediaItems:(NSArray *)mediaItems;
- (AVMutableCompositionTrack*)addMusicTrackWith:(NSArray*)musics;
- (AVMutableCompositionTrack*)addRecordAudioTrackWith:(NSArray*)audios;

- (AVAudioMix *)buildAudioMixForMusic;

@end

@implementation SCBasicMediaBuilder

- (id)initWithSlideShow:(SCSlideShowComposition *)slideShow;
{	self = [super init];
	if (self) {
		self.slideShow = slideShow;
	}
	return self;
}


- (id <SCBuilderCompositionProtocol>)buildMediaComposition
{    
	self.composition = [AVMutableComposition composition];
	[self addCompositionTrackOfType:AVMediaTypeVideo forMediaItems:self.slideShow.videos];
    self.musicTrack =  [self addMusicTrackWith:self.slideShow.musics];
    self.audioTrack =  [self addMusicTrackWith:self.slideShow.audios];
    if(!self.musicTrack && !self.audioTrack)
        [self addEmptyAudio];

    
    //create basic compostion
    SCBasicBuilderComposition *basicCompostion = [SCBasicBuilderComposition compositionWithComposition:self.composition videoComposition:self.videoComposition];
    basicCompostion.audioMix = [self  buildAudioMixForMusic];
    self.slideShow.totalDuration = self.composition.duration;

	return basicCompostion;
}

- (AVMutableCompositionTrack*)addCompositionTrackOfType:(NSString *)mediaType forMediaItems:(NSArray *)mediaItems
{
	if (!SCIsEmpty(mediaItems))
    {
		AVMutableCompositionTrack *compositionTrack = [self.composition addMutableTrackWithMediaType:mediaType
																					preferredTrackID:kCMPersistentTrackID_Invalid];
		// Set insert cursor to 0
		CMTime cursorTime = kCMTimeZero;
        int index = 0;
		for (SCMediaComposition *item in mediaItems)
        {
            //get  asset track and insert into composition track
			AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:mediaType][0];
			[compositionTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];
            //create time stamp for start and end point for slide
            
            //add start/end time for slide/video item
            item.startTimeInTimeline = cursorTime;
            item.endTimeInTimeline = CMTimeAdd(item.startTimeInTimeline, item.timeRange.duration);
            SCSlideComposition *slide = [self.slideShow.slides objectAtIndex:index];
            slide.startTimeInTimeline = cursorTime;
            slide.endTimeInTimeline = CMTimeAdd(item.startTimeInTimeline, item.timeRange.duration);
            NSLog(@"Time stamp for Item index[%d] With: startTime:[%.2f] endtime[%.2f]",index,CMTimeGetSeconds(slide.startTimeInTimeline),CMTimeGetSeconds(slide.endTimeInTimeline));

            // Move cursor to next item time
			cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
            
            //increase index
            index ++;
		}
        
        return compositionTrack;
	}
    
    return nil;
}


- (AVMutableCompositionTrack*)addMusicTrackWith:(NSArray*)musics
{
    AVMutableCompositionTrack *compositionTrack = nil;
    
	if (!SCIsEmpty(musics))
    {
		CMTime cursorTime = kCMTimeZero;
		for (SCAudioComposition *music in musics)
        {
            CMTime musicRangeFromStartTime = CMTimeAdd(music.startTimeInTimeline, music.timeRange.duration);
            float startTime = CMTimeGetSeconds(music.startTimeInTimeline);
            float duration  = CMTimeGetSeconds(self.composition.duration);
            CMTimeRange timeRange;
            if(CMTimeGetSeconds(music.timeRange.duration) >= CMTimeGetSeconds(self.composition.duration))
            {
                music.timeRange = CMTimeRangeMake(music.timeRange.start, self.composition.duration);
            }
            if(CMTimeGetSeconds(musicRangeFromStartTime) > 0 && startTime < duration)
            {
                compositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                if(CMTimeGetSeconds(music.startTimeInTimeline) < 0)
                {
                    CMTime start = CMTimeSubtract(music.timeRange.start, music.startTimeInTimeline);
                    CMTime duration = CMTimeAdd(music.timeRange.duration, music.startTimeInTimeline);
                    timeRange = CMTimeRangeMake(start, duration);
                    cursorTime = kCMTimeZero;
                }
                else if(CMTimeGetSeconds(CMTimeAdd(music.startTimeInTimeline, music.timeRange.duration)) > CMTimeGetSeconds(self.composition.duration))
                {
                    CMTime duration = CMTimeSubtract(self.composition.duration, music.startTimeInTimeline);
                    timeRange = CMTimeRangeMake(music.timeRange.start, duration);
                    cursorTime = music.startTimeInTimeline;
                }
                else
                {
                    if(CMTimeGetSeconds(music.timeRange.duration) >= CMTimeGetSeconds(self.composition.duration))
                    {
                        music.timeRange = CMTimeRangeMake(music.timeRange.start, self.composition.duration);
                        music.startTimeInTimeline = kCMTimeZero;
                        music.duration = music.timeRange.duration;
                    }
                    
                    timeRange = music.timeRange;
                    cursorTime = music.startTimeInTimeline;

                }
               
                NSArray *tracks = [music.asset tracksWithMediaType:AVMediaTypeAudio];
                if(tracks.count > 0)
                {
                    AVAssetTrack *assetTrack = tracks[0];
                    //check to comfirm that music can start at its time range start point (from trimming action)
                    [music updateVolumeRamp];
                    [compositionTrack insertTimeRange:timeRange ofTrack:assetTrack atTime:cursorTime error:nil];
                    // Move cursor to next item time
                    cursorTime = CMTimeAdd(cursorTime, music.timeRange.duration);
                }
            }
		}
	}
	return compositionTrack;
    
}

- (AVMutableCompositionTrack*)addRecordAudioTrackWith:(NSArray*)audios
{
    AVMutableCompositionTrack *compositionTrack = nil;
    
	if (!SCIsEmpty(audios))
    {
        AVMutableCompositionTrack *compositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                 preferredTrackID:kCMPersistentTrackID_Invalid];
		// Set insert cursor to 0
		CMTime cursorTime = kCMTimeZero;
        
		for (SCMediaComposition *item in audios)
        {
            
			if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
				cursorTime = item.startTimeInTimeline;
			}
            
            //update the audio record timerange with the total duration
            if(CMTimeGetSeconds(item.timeRange.duration) >= CMTimeGetSeconds(self.composition.duration))
            {
                cursorTime = kCMTimeZero;
                item.timeRange = CMTimeRangeMake(kCMTimeZero, self.composition.duration);
                item.startTimeInTimeline = kCMTimeZero;
                item.duration = item.timeRange.duration;
            
            }
            else if( CMTimeGetSeconds(item.timeRange.duration) < CMTimeGetSeconds(self.composition.duration) && CMTimeGetSeconds(CMTimeAdd(item.startTimeInTimeline, item.duration)) > CMTimeGetSeconds(self.composition.duration))
            {
                cursorTime = CMTimeSubtract(self.composition.duration, item.duration);
                item.timeRange = CMTimeRangeMake(kCMTimeZero, item.duration);
                item.startTimeInTimeline = cursorTime;
                item.duration = item.timeRange.duration;
            }
            
            //get  asset track and insert into composition track
            NSArray *audiotrack = [item.asset tracksWithMediaType:AVMediaTypeAudio ];
            if(audiotrack.count > 0)
            {
                AVAssetTrack *assetTrack = audiotrack[0];
                [compositionTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];
                
                // Move cursor to next item time
                cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
            }
		}
        return compositionTrack;
	}
    
	return compositionTrack;
}


- (AVAudioMix *)buildAudioMixForMusic
{
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *musicParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.musicTrack];
    AVMutableAudioMixInputParameters *audioParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.audioTrack];

    //music
    if(self.musicTrack)
    {
        NSArray *items = self.slideShow.musics;
        // Only one allowed
        if (items.count > 0)
        {
            SCAudioComposition *item = self.slideShow.musics[0];
            
            for (SCVolumeRampComposition *automation in item.volumeRamps)
            {
                if(automation.enable)
                    [musicParameters setVolumeRampFromStartVolume:automation.startVolume
                                             toEndVolume:automation.endVolume
                                               timeRange:automation.timeRange];
                
            }
        }
    }
    
    //audio
    if(self.audioTrack)
    {
        NSArray *items = self.slideShow.audios;
        // Only one allowed
        if (items.count > 0)
        {
            SCAudioComposition *item = self.slideShow.audios[0];
            for (SCVolumeRampComposition *automation in item.volumeRamps)
            {
                if(automation.enable)
                    [audioParameters setVolumeRampFromStartVolume:automation.startVolume
                                                 toEndVolume:automation.endVolume
                                                   timeRange:automation.timeRange];
                
            }
        }
    }
    
    audioMix.inputParameters = @[musicParameters,audioParameters];

    return audioMix;
}

- (void)addEmptyAudio
{
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:@"audio"
                      ofType:@"m4a"];
    
    SCAudioComposition *item = [[SCAudioComposition alloc]initWithURL:[NSURL fileURLWithPath:path]];
    AVMutableCompositionTrack *compositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                 preferredTrackID:kCMPersistentTrackID_Invalid];
    // Set insert cursor to 0
    CMTime cursorTime = kCMTimeZero;
    

    if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
        cursorTime = item.startTimeInTimeline;
    }
    
    //update the audio record timerange with the total duration
    if(CMTimeGetSeconds(item.timeRange.duration) >= CMTimeGetSeconds(self.composition.duration))
    {
        cursorTime = kCMTimeZero;
        item.timeRange = CMTimeRangeMake(kCMTimeZero, self.composition.duration);
        item.startTimeInTimeline = kCMTimeZero;
        item.duration = item.timeRange.duration;
        
    }
    else if( CMTimeGetSeconds(item.timeRange.duration) < CMTimeGetSeconds(self.composition.duration) && CMTimeGetSeconds(CMTimeAdd(item.startTimeInTimeline, item.duration)) > CMTimeGetSeconds(self.composition.duration))
    {
        cursorTime = CMTimeSubtract(self.composition.duration, item.duration);
        item.timeRange = CMTimeRangeMake(kCMTimeZero, item.duration);
        item.startTimeInTimeline = cursorTime;
        item.duration = item.timeRange.duration;
    }
    
    //get  asset track and insert into composition track
    NSArray *audiotrack = [item.asset tracksWithMediaType:AVMediaTypeAudio ];
    if(audiotrack.count > 0)
    {
        AVAssetTrack *assetTrack = audiotrack[0];
        [compositionTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];
        
        // Move cursor to next item time
        cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
    }

}


- (void)clearAll
{
    
}


@end
