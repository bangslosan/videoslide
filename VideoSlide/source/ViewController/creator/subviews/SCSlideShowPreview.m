//
//  SCSlideShowPreview.m
//  SlideshowCreator
//
//  Created 10/10/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSlideShowPreview.h"


static NSString* const AVCDVPlayerViewControllerStatusObservationContext	= @"AVCDVPlayerViewControllerStatusObservationContext";
static NSString* const AVCDVPlayerViewControllerRateObservationContext = @"AVCDVPlayerViewControllerRateObservationContext";

/*
 Player view backed by an AVPlayerLayer
 */
@interface SCPlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;

@end

@implementation SCPlayerView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (AVPlayer *)player
{
	return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
	[(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end

@interface SCSlideShowPreview()
{
    @private
        BOOL			_playing;
        BOOL			_scrubInFlight;
        BOOL			_seekToZeroBeforePlaying;
        float			_lastScrubSliderValue;
        float			_playRateToRestore;
        id				_timeObserver;
        
}

@property(nonatomic, strong) AVPlayer			*player;
@property(nonatomic, strong) AVPlayerItem		*playerItem;
@property(nonatomic, strong) IBOutlet           SCPlayerView		*playerView;

- (void)updatePlayPauseButton;
- (void)updateScrubber;
- (CMTime)playerItemDuration;
- (void)synchronizePlayerWithData;
- (void)synchronizeDebugViewerWithData;


@end

@implementation SCSlideShowPreview


#pragma mark - init
@synthesize composition = _composition;
@synthesize compositionDebugView = _compositionDebugView;
@synthesize videoComposition = _videoComposition;
@synthesize audioMix = _audioMix;
@synthesize delegate = _delegate;
@synthesize realProgressWidth = _realProgressWidth;
@synthesize currentViewProgress = _currentViewProgress;
@synthesize currentPlayerTime = _currentPlayerTime;


- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCSlideShowPreview" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        //create player view
        self.realProgressWidth = frame.size.width;
        [self updateScrubber];
    }
    
    return self;
}

- (id)initWith:(SCBasicBuilderComposition*)builderData frame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    if(self)
    {
        [self setBasicData:builderData];
    }
    
    return self;
}

- (id)initWithBasic:(SCBasicBuilderComposition*)builderData frame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    if(self)
    {
        [self setBasicData:builderData];
    }
    
    return self;
}

- (id)initWithAdvanced:(SCAdvancedBuilderComposition*)builderData frame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    if(self)
    {
        [self setAdvancedData:builderData];

    }
    
    return self;
}

+ (id)initWithBasic:(SCBasicBuilderComposition*)builderData frame:(CGRect)frame
{
    return [[self alloc]initWithBasic:builderData frame:frame];
}
+ (id)initWithAdvanced:(SCAdvancedBuilderComposition*)builderData frame:(CGRect)frame
{
    return [[self alloc]initWithAdvanced:builderData frame:frame];
    
}

- (void)awakeFromNib
{
    if (!self.player)
    {
		_seekToZeroBeforePlaying = NO;
		self.player = [[AVPlayer alloc] init];
		[self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:(__bridge void *)(AVCDVPlayerViewControllerRateObservationContext)];
		[self.playerView setPlayer:self.player];
        
	}
	[self addTimeObserverToPlayer];
}


#pragma mark - super

- (void)clearAll
{
    [super clearAll];
    [self removeTimeObserverFromPlayer];
	[self.player removeObserver:self forKeyPath:@"rate"];
	[self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player pause];

    self.player = nil;
    if(self.compositionDebugView.superview)
    {
        [self.compositionDebugView removeFromSuperview];
    }
    self.compositionDebugView = nil;
    
    self.compositionDebugView = nil;
    self.composition  = nil;
    self.videoComposition = nil;
    self.audioMix = nil;
    self.delegate = nil;
}

- (void)removeTimeObserverFromPlayer
{
	if (_timeObserver)
    {
		[self.player removeTimeObserver:_timeObserver];
		_timeObserver = nil;
	}
}

#pragma mark - get/set

- (float)currentViewProgress
{
    double duration = CMTimeGetSeconds([self playerItemDuration]);
	
	if (isfinite(duration) && self.player)
    {
		double time = CMTimeGetSeconds([self.player currentTime]);
        _currentViewProgress = time/duration;
        NSLog(@"Progress %f",time);
        return _currentViewProgress;
    }
    
    return 0;
}

- (float)currentPlayerTime
{
    _currentPlayerTime =CMTimeGetSeconds([self.player currentTime]);
    
    return _currentPlayerTime;
}

- (BOOL)isPlaying
{
    return _playing;
}

#pragma mark -   instance methods

- (void)setAdvancedData:(SCAdvancedBuilderComposition*)data
{
    if(data)
    {
        self.composition = data.composition;
        self.videoComposition = data.videoComposition;
        self.audioMix = data.audioMix;
        [self synchronizePlayerWithData];
        //[self synchronizeDebugViewerWithData];
    }
}
- (void)setBasicData:(SCBasicBuilderComposition*)data
{
    if(data)
    {
        self.composition = data.composition;
        self.videoComposition = data.videoComposition;
        self.audioMix = data.audioMix;
        [self synchronizePlayerWithData];
        //[self synchronizeDebugViewerWithData];
    }
    
}

#pragma mark - instance action
- (void)play
{
    _playing = YES;
	if ( _playing )
    {
		if ( _seekToZeroBeforePlaying )
        {
			[self.player seekToTime:kCMTimeZero];
			_seekToZeroBeforePlaying = NO;
		}
		[self.player play];
	}
}

- (void)playWithoutVolume
{
    [self.player play];
    _playing = YES;
}

- (void)pause
{
    _playing = NO;
    [self.player pause];

}

- (void)beginSeekingTo:(float)value
{
    _seekToZeroBeforePlaying = NO;
	_playRateToRestore = [self.player rate];
	[self.player setRate:0.0];
	
	[self removeTimeObserverFromPlayer];

}

- (void)seekingTo:(float)value
{
    if(value <= 0)
        value = 0;
    _lastScrubSliderValue = value;

	if ( ! _scrubInFlight )
		[self scrubToSliderValue:_lastScrubSliderValue];

}

- (void)endSeekingTo:(float)value
{
    if ( _scrubInFlight )
		[self scrubToSliderValue:_lastScrubSliderValue];
	[self addTimeObserverToPlayer];
	
	[self.player setRate:_playRateToRestore];
	_playRateToRestore = 0.f;
    
    if(_playing)
    {
        [self play];
    }
    else
    {
        [self pause];
    }
}

- (void)synchronizePlayerWithData
{
	if ( self.player == nil )
		return;
	
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.composition];
	playerItem.videoComposition = self.videoComposition;
	playerItem.audioMix = self.audioMix;
	
	if (self.playerItem != playerItem)
    {
		if ( self.playerItem ) {
			[self.playerItem removeObserver:self forKeyPath:@"status"];
			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
		}
		
		self.playerItem = playerItem;
		
		if ( self.playerItem ) {
			// Observe the player item "status" key to determine when it is ready to play
			[self.playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial) context:(__bridge void *)(AVCDVPlayerViewControllerStatusObservationContext)];
			
			// When the player item has played to its end time we'll set a flag
			// so that the next time the play method is issued the player will
			// be reset to time zero first.
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
		}
		[self.player replaceCurrentItemWithPlayerItem:playerItem];
	}
}

- (void)synchronizeDebugViewerWithData
{
    // Set our AVPlayer and all composition objects on the AVCompositionDebugView
    if(self.compositionDebugView)
    {
        [self.compositionDebugView removeFromSuperview];
        self.compositionDebugView = nil;
    }
    
    self.compositionDebugView = [[SCVideoDebugViewer alloc]init];
    self.compositionDebugView.frame = self.frame;
	self.compositionDebugView.player = self.player;
	[self.compositionDebugView synchronizeToComposition:self.composition videoComposition:self.videoComposition audioMix:self.audioMix];
	[self.compositionDebugView setNeedsDisplay];
    
}

- (void)showDebugViewerInView:(UIView *)view withFrame:(CGRect)frame
{
    if(self.compositionDebugView.superview)
    {
        [self.compositionDebugView removeFromSuperview];
    }
    
    self.compositionDebugView.frame = frame;
    [view addSubview:self.compositionDebugView];
}

#pragma mark - Utilities
- (void)addTimeObserverToPlayer
{
	if (_timeObserver)
		return;
	
	if (self.player == nil)
		return;
	
	if (self.player.currentItem.status != AVPlayerItemStatusReadyToPlay)
		return;
	
	double duration = CMTimeGetSeconds([self playerItemDuration]);
	
	if (isfinite(duration)) {
		CGFloat width = CGRectGetWidth([self bounds]);
		double interval = 0.5 * duration / width;
		
		if (interval > 1.0)
			interval = 1.0;
		__weak SCSlideShowPreview *weakSelf = self;
		_timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
						 ^(CMTime time) {
							 [weakSelf updateScrubber];
						 }];
	}
}


- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [self.player currentItem];
	CMTime itemDuration = kCMTimeInvalid;
	
	if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
		itemDuration = [playerItem duration];
	}
	
	// Will be kCMTimeInvalid if the item is not ready to play.
	return itemDuration;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(AVCDVPlayerViewControllerRateObservationContext) )
    {
		float newRate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
		NSNumber *oldRateNum = [change objectForKey:NSKeyValueChangeOldKey];
		if ( [oldRateNum isKindOfClass:[NSNumber class]] && newRate != [oldRateNum floatValue] )
        {
			_playing = ((newRate != 0.f) || (_playRateToRestore != 0.f));
			[self updatePlayPauseButton];
			[self updateScrubber];
		}
    }
	else if ( context == (__bridge void *)(AVCDVPlayerViewControllerStatusObservationContext) )
    {
		AVPlayerItem *playerItem = (AVPlayerItem *)object;
		if (playerItem.status == AVPlayerItemStatusReadyToPlay)
        {
			// Once the AVPlayerItem becomes ready to play, i.e.
			 //[playerItem status] == AVPlayerItemStatusReadyToPlay,
			 //its duration can be fetched from the item.
			
			[self addTimeObserverToPlayer];
		}
		else if (playerItem.status == AVPlayerItemStatusFailed)
        {
			[self reportError:playerItem.error];
		}
	}
	else
    {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)updatePlayPauseButton
{
    if(_playing)
    {
       [self.delegate playerStatus:SCMediaStatusPlay];
        NSLog(@"Player status : Play");
    }
    else
    {
        [self.delegate playerStatus:SCMediaStatusPause];
        NSLog(@"Player status : Pause");

    }
}


- (void)updateScrubber
{
	double duration = CMTimeGetSeconds([self playerItemDuration]);
	
    if(_playing)
    {
        if (isfinite(duration))
        {
            double time = CMTimeGetSeconds([self.player currentTime]);
            self.currentViewProgress = (time / duration);
            [self.delegate currentProgessFromPlayer:self.currentViewProgress];
            //NSLog(@"[Player Progress : %.2f ]",self.currentViewoProgress);
        }
        else
        {
            [self.delegate currentProgessFromPlayer:0];
        }
    }
}

- (void)reportError:(NSError *)error
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (error) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
																message:[error localizedRecoverySuggestion]
															   delegate:nil
													  cancelButtonTitle:NSLocalizedString(@"OK", nil)
													  otherButtonTitles:nil];
			
			[alertView show];
		}
	});
}

#pragma mark - behaviour

- (void)scrubToSliderValue:(float)sliderValue
{
	//double duration = CMTimeGetSeconds([self playerItemDuration]);
    double duration = CMTimeGetSeconds(self.playerItem.duration);

	if (isfinite(duration))
    {
        if(self.realProgressWidth > 0)
        {
            double time = duration*sliderValue;
            double tolerance = 1.0f * duration / self.realProgressWidth;
            
            _scrubInFlight = YES;
            
            [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)
                    toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
                     toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
                  completionHandler:^(BOOL finished) {
                      _scrubInFlight = NO;
                  }];
        }
	}
}


// Called when the player item has played to its end time.
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
	//After the movie has played to its end time, seek back to time zero to play it again.
	_seekToZeroBeforePlaying = YES;
    [self pause];
    if([self.delegate respondsToSelector:@selector(playerReachEndPoint)])
    {
        [self.delegate playerReachEndPoint];
    }
}



@end
