//
//  SCPreviewer.m
//  SlideshowCreator
//
//  Created 10/3/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPreviewer.h"
static NSString* const AVCDVPlayerViewControllerStatusObservationContext	= @"AVCDVPlayerViewControllerStatusObservationContext";
static NSString* const AVCDVPlayerViewControllerRateObservationContext = @"AVCDVPlayerViewControllerRateObservationContext";

/*
 Player view backed by an AVPlayerLayer
 */
@interface APLPlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;

@end

@implementation APLPlayerView

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

@interface SCPreviewer ()
{
@private
	BOOL			_playing;
	BOOL			_scrubInFlight;
	BOOL			_seekToZeroBeforePlaying;
	float			_lastScrubSliderValue;
	float			_playRateToRestore;
	id				_timeObserver;
	
	float			_transitionDuration;
	BOOL			_transitionsEnabled;
}

@property NSMutableArray		*clips;
@property NSMutableArray		*clipTimeRanges;
@property AVPlayer				*player;
@property AVPlayerItem			*playerItem;

@property IBOutlet APLPlayerView		*playerView;
@property IBOutlet UIToolbar			*toolbar;
@property IBOutlet UISlider				*scrubber;
@property IBOutlet UIBarButtonItem		*playPauseButton;
@property IBOutlet UILabel				*currentTimeLabel;
@property IBOutlet UILabel				*totalTimeLabel;
@property IBOutlet SCVideoDebugViewer	*compositionDebugView;


- (IBAction)togglePlayPause:(id)sender;
- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;
- (IBAction)onClose:(id)sender;


- (void)updatePlayPauseButton;
- (void)updateScrubber;
- (void)updateTimeLabel;

- (CMTime)playerItemDuration;
- (void)synchronizePlayerWithData;
- (void)synchronizeDebugViewerWithData;


@end

@implementation SCPreviewer


#pragma mark - init
@synthesize composition = _composition;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCPreviewer" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        [self updateScrubber];
        [self updateTimeLabel];
    }
    
    return self;
}
- (id)initWithBasic:(SCBasicBuilderComposition*)builderData
{
    self = [self init];
    if(self)
    {
        [self setBasicData:builderData];
    }
    
    return self;
}

- (id)initWithAdvanced:(SCAdvancedBuilderComposition*)builderData
{
    self = [self init];
    if(self)
    {
        [self setAdvancedData:builderData];
        [self.player play];
    }
    
    return self;
}

+ (id)initWithBasic:(SCBasicBuilderComposition*)builderData
{
    return [[self alloc]initWithBasic:builderData];
}
+ (id)initWithAdvanced:(SCAdvancedBuilderComposition*)builderData
{
    return [[self alloc]initWithAdvanced:builderData];

}

- (void)awakeFromNib
{
    if (!self.player) {
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
    [self.player pause];
	[self removeTimeObserverFromPlayer];

}

#pragma mark -   instance methods

- (void)setAdvancedData:(SCAdvancedBuilderComposition*)data
{
    self.composition = data.composition;
    self.videoComposition = data.videoComposition;
    self.audioMix = data.audioMix;
    
    [self synchronizePlayerWithData];
    [self synchronizeDebugViewerWithData];
    [self updateTimeLabel];
}
- (void)setBasicData:(SCBasicBuilderComposition*)data
{
    self.composition = data.composition;
    self.videoComposition = data.videoComposition;
    self.audioMix = data.audioMix;
    [self synchronizePlayerWithData];
    [self synchronizeDebugViewerWithData];
    [self updateTimeLabel];

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
	self.compositionDebugView.player = self.player;
	[self.compositionDebugView synchronizeToComposition:self.composition videoComposition:self.videoComposition audioMix:self.audioMix];
	[self.compositionDebugView setNeedsDisplay];

}

#pragma mark - Utilities

/* Update the scrubber and time label periodically. */
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
		CGFloat width = CGRectGetWidth([self.scrubber bounds]);
		double interval = 0.5 * duration / width;
		
		/* The time label needs to update at least once per second. */
		if (interval > 1.0)
			interval = 1.0;
		__weak SCPreviewer *weakSelf = self;
		_timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
						 ^(CMTime time) {
							 [weakSelf updateScrubber];
							 [weakSelf updateTimeLabel];
						 }];
	}
}

- (void)removeTimeObserverFromPlayer
{
	if (_timeObserver) {
		[self.player removeTimeObserver:_timeObserver];
		_timeObserver = nil;
	}
}

- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [self.player currentItem];
	CMTime itemDuration = kCMTimeInvalid;
	
	if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
		itemDuration = [playerItem duration];
	}
	
	/* Will be kCMTimeInvalid if the item is not ready to play. */
	return itemDuration;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(AVCDVPlayerViewControllerRateObservationContext) ) {
		float newRate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
		NSNumber *oldRateNum = [change objectForKey:NSKeyValueChangeOldKey];
		if ( [oldRateNum isKindOfClass:[NSNumber class]] && newRate != [oldRateNum floatValue] ) {
			_playing = ((newRate != 0.f) || (_playRateToRestore != 0.f));
			[self updatePlayPauseButton];
			[self updateScrubber];
			[self updateTimeLabel];
		}
    }
	else if ( context == (__bridge void *)(AVCDVPlayerViewControllerStatusObservationContext) ) {
		AVPlayerItem *playerItem = (AVPlayerItem *)object;
		if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
			/* Once the AVPlayerItem becomes ready to play, i.e.
			 [playerItem status] == AVPlayerItemStatusReadyToPlay,
			 its duration can be fetched from the item. */
			
			[self addTimeObserverToPlayer];
		}
		else if (playerItem.status == AVPlayerItemStatusFailed) {
			[self reportError:playerItem.error];
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)updatePlayPauseButton
{
	UIBarButtonSystemItem style = _playing ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay;
	UIBarButtonItem *newPlayPauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:self action:@selector(togglePlayPause:)];
	
	NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbar.items];
	[items replaceObjectAtIndex:[items indexOfObject:self.playPauseButton] withObject:newPlayPauseButton];
	[self.toolbar setItems:items];
	
	self.playPauseButton = newPlayPauseButton;
}

- (void)updateTimeLabel
{
    //get current player time
	double seconds = CMTimeGetSeconds([self.player currentTime]);
	if (!isfinite(seconds)) {
		seconds = 0;
	}
	
	int secondsInt = round(seconds);
	int minutes = secondsInt/60;
	secondsInt -= minutes*60;
	
	self.currentTimeLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
	
	self.currentTimeLabel.text = [NSString stringWithFormat:@"%.2i:%.2i", minutes, secondsInt];
    
    
    //get total player time
    double totalSeconds = CMTimeGetSeconds([self.playerItem duration]);
	if (!isfinite(totalSeconds)) {
		totalSeconds = 0;
	}
	
	int totalSecondsInt = round(totalSeconds);
	int totalMinutes = totalSecondsInt/60;
	totalSecondsInt -= totalMinutes*60;
	
	self.totalTimeLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
	
	self.totalTimeLabel.text = [NSString stringWithFormat:@"%.2i:%.2i", totalMinutes, totalSecondsInt];

}

- (void)updateScrubber
{
	double duration = CMTimeGetSeconds([self playerItemDuration]);
	
	if (isfinite(duration)) {
		double time = CMTimeGetSeconds([self.player currentTime]);
		[self.scrubber setValue:time / duration];
	}
	else {
		[self.scrubber setValue:0.0];
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

#pragma mark - IBActions
- (IBAction)onClose:(id)sender
{
    if(self.superview)
    {
        [self removeFromSuperview];
    }
    [self clearAll];
}

- (IBAction)togglePlayPause:(id)sender
{
	_playing = !_playing;
	if ( _playing ) {
		if ( _seekToZeroBeforePlaying ) {
			[self.player seekToTime:kCMTimeZero];
			_seekToZeroBeforePlaying = NO;
		}
		[self.player play];
	}
	else {
		[self.player pause];
	}
}

- (IBAction)beginScrubbing:(id)sender
{
	_seekToZeroBeforePlaying = NO;
	_playRateToRestore = [self.player rate];
	[self.player setRate:0.0];
	
	[self removeTimeObserverFromPlayer];
}

- (IBAction)scrub:(id)sender
{
	_lastScrubSliderValue = [self.scrubber value];
	
	if ( ! _scrubInFlight )
		[self scrubToSliderValue:_lastScrubSliderValue];
}

- (void)scrubToSliderValue:(float)sliderValue
{
	double duration = CMTimeGetSeconds([self playerItemDuration]);
	
	if (isfinite(duration)) {
		CGFloat width = CGRectGetWidth([self.scrubber bounds]);
		
		double time = duration*sliderValue;
		double tolerance = 1.0f * duration / width;
		
		_scrubInFlight = YES;
		
		[self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)
				toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
				 toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
			  completionHandler:^(BOOL finished) {
				  _scrubInFlight = NO;
				  [self updateTimeLabel];
			  }];
	}
}

- (IBAction)endScrubbing:(id)sender
{
	if ( _scrubInFlight )
		[self scrubToSliderValue:_lastScrubSliderValue];
	[self addTimeObserverToPlayer];
	
	[self.player setRate:_playRateToRestore];
	_playRateToRestore = 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
	/* After the movie has played to its end time, seek back to time zero to play it again. */
	_seekToZeroBeforePlaying = YES;
}


@end
