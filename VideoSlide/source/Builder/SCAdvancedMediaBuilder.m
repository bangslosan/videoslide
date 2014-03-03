//
//  SCAdvancedVideoBuilder.m
//  SlideshowCreator
//
//  Created 9/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCAdvancedMediaBuilder.h"

@interface SCAdvancedMediaBuilder ()

@property (nonatomic, strong)   SCSlideShowComposition *slideShow;
@property (nonatomic, strong)   AVMutableComposition *composition;
@property (nonatomic, strong)   AVMutableVideoComposition *videoComposition;
@property (nonatomic, weak)     AVMutableCompositionTrack *musicTrack;
@property (nonatomic, weak)     AVMutableCompositionTrack *audioTrack;
@property (nonatomic, strong)   AVVideoCompositionCoreAnimationTool *animationTool;


- (void)buildCompositionObjectsForPlayback;
- (AVMutableVideoComposition*)buildVideoCompositionFor:(AVMutableComposition*)composition;
- (void)buildAudioTrackFor:(AVMutableComposition*)composition;

- (AVMutableCompositionTrack *)addCompositionTrackOfType:(NSString *)mediaType forMediaItems:(NSArray *)mediaItems into:(AVMutableComposition*)composition;
- (AVMutableCompositionTrack*)addMusicTrackWith:(NSArray*)musics into:(AVMutableComposition*)composition;
- (AVMutableCompositionTrack*)addRecordAudioTrackWith:(NSArray*)audios;

- (AVAudioMix *)buildAudioMixForMusic;
- (CALayer *)buildLayers;

- (AVVideoCompositionCoreAnimationTool*)addAnimationTool:(CMPersistentTrackID)trackID;


@end

@implementation SCAdvancedMediaBuilder

- (id)initWithSlideShow:(SCSlideShowComposition *)slideShow
{
	self = [super init];
	if (self) {
		_slideShow = slideShow;
	}
	return self;
}

- (SCAdvancedBuilderComposition*)buildMediaComposition
{
    [self buildCompositionObjectsForPlayback];
    SCAdvancedBuilderComposition *advancedComposition = [[SCAdvancedBuilderComposition alloc] initWithComposition:self.composition
                                                                                                 videoComposition:self.videoComposition
                                                                                                         audioMix:[self buildAudioMixForMusic]
                                                                                                       titleLayer:nil];//[self buildLayers]];
    self.slideShow.totalDuration = self.composition.duration;
	return advancedComposition;
}


- (void)buildCompositionObjectsForPlayback
{
	if (self.slideShow.videos.count == 0 )
    {
		self.composition = nil;
		self.videoComposition = nil;
		return;
	}
    
    self.composition = [AVMutableComposition composition];;
    //self.composition.naturalSize = videoSize;
    self.videoComposition = [self buildVideoCompositionFor:self.composition];
    [self buildAudioTrackFor:self.composition];
}


#pragma mark - static methods
+ (SCAdvancedBuilderComposition *)buildCmpositionWith:(SCSlideShowComposition *)slideShow
{
    return nil;
}

#pragma mark -  build video compostion for mutable transform and transitions

- (AVMutableVideoComposition*)buildVideoCompositionFor:(AVMutableComposition*)composition
{
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    float FPS = 1;
    if(self.slideShow.isAdvanced)
        FPS = SC_VIDEO_ADVANVCE_RENDER_FPS;
    else
        FPS = SC_VIDEO_BASIC_RENDER_FPS;
    videoComposition.frameDuration = CMTimeMake(1, FPS); //  frame per second for video composition
    videoComposition.renderSize = SC_VIDEO_SIZE;

    //init composition
	CMTime cursorTime = kCMTimeZero;
	NSInteger i;
	NSUInteger clipsCount = [self.slideShow.videos count];
	
	// Make transitionDuration no greater than half the shortest clip duration.
    
    //get the first transition / in this setting all transiotn have the same info
    CMTime transitionDuration = kCMTimeZero;;
    if(self.slideShow.transitions.count > 0)
    {
        SCTransitionComposition *trans = [self.slideShow.transitions objectAtIndex:0];
        transitionDuration = trans.duration;
    }

	
	// Add two video tracks and two audio tracks.
	AVMutableCompositionTrack *compositionVideoTracks[2];
	//AVMutableCompositionTrack *compositionAudioTracks[2];
	compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	
	CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
	CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
	
    // With transitions:
	// Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
	// Set up the video composition to cycle between "pass through A", "transition from A to B",

	// Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
	for (i = 0; i < clipsCount; i++)
    {
        SCVideoComposition *videoItem = [self.slideShow.videos objectAtIndex:i];
        SCSlideComposition *slideComposition = [self.slideShow.slides objectAtIndex:i];
        //get the start time in time line for video composition
        videoItem.startTimeInTimeline = CMTimeAdd(cursorTime, transitionDuration);
        videoItem.endTimeInTimeline = CMTimeAdd(videoItem.startTimeInTimeline, CMTimeSubtract(videoItem.timeRange.duration, CMTimeAdd(transitionDuration, transitionDuration)));
        slideComposition.startTimeInTimeline = videoItem.startTimeInTimeline;
        slideComposition.endTimeInTimeline = videoItem.endTimeInTimeline;
        
        NSLog(@"Time stamp for Item index[%d] With: startTime:[%.2f] endtime[%2.f]",i,CMTimeGetSeconds(slideComposition.startTimeInTimeline),CMTimeGetSeconds(slideComposition.endTimeInTimeline));

		NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
		AVAsset *asset = videoItem.asset;
		CMTimeRange timeRangeInAsset =   videoItem.timeRange;
		AVAssetTrack *clipVideoTrack =  [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:cursorTime error:nil];
        if(i == 2)
        {
            //[self addAnimationTool:clipVideoTrack.trackID];
        }
		// Remember the time range in which this clip should pass through.
		// Second clip begins with a transition.
		// First clip ends with a transition.
		// Exclude those transitions from the pass through time ranges.
		passThroughTimeRanges[i] = CMTimeRangeMake(cursorTime, timeRangeInAsset.duration);
		if (i > 0)
        {
			passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, transitionDuration);
			passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
		}
		if (i+1 < clipsCount)
        {
			passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
		}
		
		// The end of this clip will overlap the start of the next by transitionDuration.
		// (Note: this arithmetic falls apart if timeRangeInAsset.duration < 2 * transitionDuration.)
		cursorTime = CMTimeAdd(cursorTime, timeRangeInAsset.duration);
		cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
		
		// Remember the time range for the transition to the next item.
		if (i+1 < clipsCount)
        {
			transitionTimeRanges[i] = CMTimeRangeMake(cursorTime, transitionDuration);
		}
	}
	
	// Set up the video composition if we are to perform crossfade transitions between clips.
	NSMutableArray *instructions = [NSMutableArray array];
	
	// Cycle between "pass through A", "transition from A to B", "pass through B"
	for (i = 0; i < clipsCount; i++ )
    {
		
        NSInteger alternatingIndex = i % 2; // alternating targets
		
		// Pass through clip i.
		AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
		passThroughInstruction.timeRange = passThroughTimeRanges[i];
		AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
		
		passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
		[instructions addObject:passThroughInstruction];
		
		if (i+1 < clipsCount)
        {
			AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
			transitionInstruction.timeRange = transitionTimeRanges[i];
			AVMutableVideoCompositionLayerInstruction *fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
			AVMutableVideoCompositionLayerInstruction *toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1-alternatingIndex]];
            
            SCTransitionComposition *transItem = [self.slideShow.transitions objectAtIndex:0];

            //set  transition for 2 slide show
            if(transItem.type == SCVideoTransitionTypeNone)
            {
                
            }
            else if(transItem.type == SCVideoTransitionTypeDisolve)
            {
                [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:transitionTimeRanges[i]];
                
                [toLayer setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:transitionTimeRanges[i]];
            }
            else if(transItem.type == SCVideoTransitionTypePushFromTop)
            {
                [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity
                                                          toEndTransform:CGAffineTransformMakeTranslation(0,SC_VIDEO_SIZE.height)
                                                               timeRange:transitionTimeRanges[i]];
                // Set a transform ramp on toLayer from all the way right of the screen to identity.
                [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(0,-SC_VIDEO_SIZE.height)
                                                        toEndTransform:CGAffineTransformIdentity
                                                             timeRange:transitionTimeRanges[i]];
            }
            else if(transItem.type == SCVideoTransitionTypePushFromBottom)
            {
                [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity
                                               toEndTransform:CGAffineTransformMakeTranslation(0,-SC_VIDEO_SIZE.height)
                                                    timeRange:transitionTimeRanges[i]];
                // Set a transform ramp on toLayer from all the way right of the screen to identity.
                [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(0,SC_VIDEO_SIZE.height)
                                             toEndTransform:CGAffineTransformIdentity
                                                  timeRange:transitionTimeRanges[i]];
            }
            else if(transItem.type == SCVideoTransitionTypePushFromLeft)
            {
                [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity
                                               toEndTransform:CGAffineTransformMakeTranslation(SC_VIDEO_SIZE.width,0)
                                                    timeRange:transitionTimeRanges[i]];
                // Set a transform ramp on toLayer from all the way right of the screen to identity.
                [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(-SC_VIDEO_SIZE.width,0)
                                             toEndTransform:CGAffineTransformIdentity
                                                  timeRange:transitionTimeRanges[i]];
            }
            else if(transItem.type == SCVideoTransitionTypePushFromRight)
            {
                [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity
                                               toEndTransform:CGAffineTransformMakeTranslation(-SC_VIDEO_SIZE.width,0)
                                                    timeRange:transitionTimeRanges[i]];
                // Set a transform ramp on toLayer from all the way right of the screen to identity.
                [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(SC_VIDEO_SIZE.width,0)
                                             toEndTransform:CGAffineTransformIdentity
                                                  timeRange:transitionTimeRanges[i]];
            }
            else if(transItem.type == SCVideoTransitionTypeFadeIn)
            {
                [toLayer setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:transitionTimeRanges[i]];
            }
            else if(transItem.type == SCVideoTransitionTypeFadeOut)
            {
                [toLayer setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:transitionTimeRanges[i]];
            }
            else if(transItem.type == SCVideoTransitionTypeZoomIn)
            {
                [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity
                                               toEndTransform:CGAffineTransformMakeScale(0.1,0.1)
                                                    timeRange:transitionTimeRanges[i]];
                // Set a transform ramp on toLayer from all the way right of the screen to identity.
                [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeScale(0.1,0.1)
                                             toEndTransform:CGAffineTransformIdentity
                                                  timeRange:transitionTimeRanges[i]];

            }
            
			transitionInstruction.layerInstructions = [NSArray arrayWithObjects:toLayer, fromLayer, nil];
			[instructions addObject:transitionInstruction];
        }
		
	}
	videoComposition.instructions = instructions;
    
    return videoComposition;
}

- (void)buildAudioTrackFor:(AVMutableComposition *)composition
{
    //add music  adn audio tracks
    self.musicTrack = [self addMusicTrackWith:self.slideShow.musics into:composition];
    self.audioTrack = [self addMusicTrackWith:self.slideShow.audios into:composition];
    
    if(!self.audioTrack && !self.musicTrack)
        [self addEmptyAudio];

}

- (AVMutableCompositionTrack *)addCompositionTrackOfType:(NSString *)mediaType forMediaItems:(NSArray *)mediaItems into:(AVMutableComposition*)composition
{
    
	AVMutableCompositionTrack *compositionTrack = nil;
    
	if (!SCIsEmpty(mediaItems))
    {
		compositionTrack = [composition addMutableTrackWithMediaType:mediaType preferredTrackID:kCMPersistentTrackID_Invalid];
        
		CMTime cursorTime = kCMTimeZero;
        
		for (SCMediaComposition *item in mediaItems)
        {
			if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid))
            {
				cursorTime = item.startTimeInTimeline;
			}
            
			AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:mediaType][0];
			[compositionTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];
            
			// Move cursor to next item time
			cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
		}
	}
    
	return compositionTrack;
}

- (AVMutableCompositionTrack*)addMusicTrackWith:(NSArray*)musics into:(AVMutableComposition *)composition
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
    {AVMutableCompositionTrack *compositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio
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

#pragma mark  - build audio mix

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



#pragma mark -  buiild layer for animation and layout effect
- (CALayer *)buildLayers
{
    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    [subtitle1Text setFont:@"Helvetica-Bold"];
    [subtitle1Text setFontSize:36];
    [subtitle1Text setFrame:CGRectMake(0, 0, SC_VIDEO_SIZE.width, 100)];
    [subtitle1Text setString:@"TEST LAYER"];
    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitle1Text];
    overlayLayer.frame = CGRectMake(0, 0, SC_VIDEO_SIZE.width, SC_VIDEO_SIZE.height);
    [overlayLayer setMasksToBounds:YES];
    
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration=6.0;
        animation.repeatCount=5;
        animation.autoreverses=YES;
        // rotate from 0 to 360
        animation.fromValue=[NSNumber numberWithFloat:0.0];
        animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        [overlayLayer addAnimation:animation forKey:@"rotation"];
    

	return overlayLayer;
}

- (AVVideoCompositionCoreAnimationTool*)addAnimationTool:(CMPersistentTrackID)trackID
{
	CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
    [subtitle1Text setFont:@"Helvetica-Bold"];
    [subtitle1Text setFontSize:36];
    [subtitle1Text setFrame:CGRectMake(0, 0, SC_VIDEO_SIZE.width, 100)];
    [subtitle1Text setString:@"TEST LAYER"];
    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    // 2 - The usual overlay
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitle1Text];
    overlayLayer.frame = CGRectMake(0, 0, SC_VIDEO_SIZE.width, SC_VIDEO_SIZE.height);
    [overlayLayer setMasksToBounds:YES];
    
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, SC_VIDEO_SIZE.width, SC_VIDEO_SIZE.height);
    videoLayer.frame = CGRectMake(0, 0, SC_VIDEO_SIZE.width, SC_VIDEO_SIZE.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    //self.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithAdditionalLayer:parentLayer asTrackID:trackID];
    
    return [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:parentLayer inLayer:videoLayer];

}


@end
