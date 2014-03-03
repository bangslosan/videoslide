//
//  SCVideoPreview.m
//  VideoSlide
//
//  Created by Thi Huynh on 2/25/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCVideoPreview.h"

static NSString* const AVCDVPlayerViewControllerStatusObservationContext	= @"AVCDVPlayerViewControllerStatusObservationContext";
static NSString* const AVCDVPlayerViewControllerRateObservationContext = @"AVCDVPlayerViewControllerRateObservationContext";

/*
 Player view backed by an AVPlayerLayer
 */
@interface SCVideoPlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;

@end

@implementation SCVideoPlayerView

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

@interface SCVideoPreview()
{
    
@private
    BOOL			_playing;
    BOOL			_scrubInFlight;
    BOOL			_seekToZeroBeforePlaying;
    float			_lastScrubSliderValue;
    float			_playRateToRestore;
    id				_timeObserver;
    
}

@property (nonatomic, strong) AVComposition         *composition;
@property (nonatomic, strong) AVVideoComposition    *videoComposition;
@property (nonatomic, strong) AVAudioMix            *audioMix;

@property(nonatomic, strong) AVPlayer			*player;
@property(nonatomic, strong) AVPlayerItem		*playerItem;

@property (nonatomic, strong) UITapGestureRecognizer            *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer            *panGesture;



@property(nonatomic, strong) IBOutlet           SCVideoPlayerView		*playerView;
@property(nonatomic, strong) IBOutlet           UIView                  *progressView;
@property(nonatomic, strong) IBOutlet           UIImageView             *playBtn;


- (void)updatePlayPauseButton;
- (void)updateScrubber;
- (CMTime)playerItemDuration;
- (void)synchronizePlayerWithData;

@end

@implementation SCVideoPreview


#pragma mark - init

@synthesize composition = _composition;
@synthesize videoComposition = _videoComposition;
@synthesize audioMix = _audioMix;
@synthesize delegate = _delegate;
@synthesize realProgressWidth = _realProgressWidth;
@synthesize currentViewProgress = _currentViewProgress;
@synthesize currentPlayerTime = _currentPlayerTime;


- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCVideoPreview" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        //create player view
        self.realProgressWidth = frame.size.width;
        [self updateScrubber];
        
        [self.progressView setFrame:CGRectMake(0, self.progressView.frame.origin.y, 0, self.progressView.frame.size.height)];

        
        //gesture for play/pause
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        self.tapGesture.numberOfTapsRequired = 1;
        [self.playerView addGestureRecognizer:self.tapGesture];

        //ccreate gesture for seeking video
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [self.playerView addGestureRecognizer:self.panGesture];

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

#pragma mark - gesture recognize

- (void)onTap:(UITapGestureRecognizer *)gesture
{
    NSLog(@"Tap");
    if([self isPlaying])
    {
        [self pause];
    }
    else
    {
        [self play];
    }
}

- (void)onPan:(UIPanGestureRecognizer *)gesture
{
    if([self isPlaying])
    {
        [self pause];
    }
    
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint location = [self.panGesture locationInView:self];

        NSLog(@"[%0.2f][%0.2f]",location.x,location.y);
        //float currenttime = location.x / self.frame.size.width;
        //[self beginSeekingTo:currenttime];
        //self.progressView.frame = CGRectMake(0, self.progressView.frame.origin.y, location.x, self.progressView.frame.size.height);
    }
    else if(gesture.state == UIGestureRecognizerStateChanged)
    {
        //CGPoint location = [self.panGesture locationInView:self];
        CGPoint velocity = [self.panGesture velocityInView:self];

        NSLog(@"[%0.2f][%0.2f]",velocity.x,velocity.y);
        int width = self.progressView.frame.size.width + velocity.x * DELTA_TIME;
        if(width >= self.frame.size.width)
            width = self.frame.size.width;
        
        float currenttime = width/ self.frame.size.width;
        [self seekingTo:currenttime];

        self.progressView.frame = CGRectMake(0, self.progressView.frame.origin.y, width, self.progressView.frame.size.height);
        
    }
    else if(gesture.state == UIGestureRecognizerStateEnded
            || gesture.state == UIGestureRecognizerStateCancelled
            || gesture.state == UIGestureRecognizerStateFailed )
    {
        CGPoint location = [self.panGesture locationInView:self];
        NSLog(@"[%0.2f][%0.2f]",location.x,location.y);
        //float currenttime = location.x / self.frame.size.width;
        //[self endSeekingTo:currenttime];
        //self.progressView.frame = CGRectMake(0, self.progressView.frame.origin.y, location.x, self.progressView.frame.size.height);
        [self pause];

    }
    
}

#pragma mark -   instance methods
- (void)setBasicData:(SCBasicBuilderComposition*)data
{
    if(data)
    {
        self.composition = data.composition;
        self.videoComposition = data.videoComposition;
        self.audioMix = data.audioMix;
        [self synchronizePlayerWithData];
    }
    
}
#pragma mark - instance action
- (void)play
{
    _playing = YES;
    self.playBtn.hidden = YES;
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
    self.playBtn.hidden = NO;
    
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
		__weak SCVideoPreview *weakSelf = self;
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
            [self.progressView setFrame:CGRectMake(0, self.progressView.frame.origin.y, self.currentViewProgress * self.playerView.frame.size.width, self.progressView.frame.size.height)];
        }
        else
        {
            [self.delegate currentProgessFromPlayer:0];
            [self.progressView setFrame:CGRectMake(0, self.progressView.frame.origin.y, 0, self.progressView.frame.size.height)];
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
