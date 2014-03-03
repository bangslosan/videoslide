//
//  SCAdvancedBuilderComposition.m
//  SlideshowCreator
//
//  Created 9/26/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCAdvancedBuilderComposition.h"
#import "AVPlayerItem+SCAdditions.h"

@interface SCAdvancedBuilderComposition ()


@end

@implementation SCAdvancedBuilderComposition

- (id)initWithComposition:(AVComposition *)composition
		 videoComposition:(AVVideoComposition *)videoComposition
				 audioMix:(AVAudioMix *)audioMix
			   titleLayer:(CALayer *)layer
{
	self = [super initWithComposition:composition];
	if (self) {
		self.videoComposition = videoComposition;
		self.audioMix = audioMix;
		self.layer = layer;
	}
	return self;
}

- (AVPlayerItem *)makePlayable
{
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.composition copy]];
	playerItem.videoComposition = self.videoComposition;
	playerItem.audioMix = self.audioMix;
    
	AVSynchronizedLayer *synchLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:playerItem];
	[synchLayer addSublayer:self.layer];
    
	// WARNING: This is calling a category method I added to carry the synch layer to the
	// player view controller.  This is not part of AV Foundation.
	playerItem.titleLayer = synchLayer;
	return playerItem;
}

- (AVAssetExportSession *)makeExportable:(NSString *)quality
{
    if(self.layer)
    {
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
        videoLayer.frame = CGRectMake(0, 0, self.videoComposition.renderSize.width, self.videoComposition.renderSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:self.layer];
        
        ((AVMutableVideoComposition*)self.videoComposition).animationTool = [AVVideoCompositionCoreAnimationTool
                                     videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        
		// Use AVVideoCompositionCoreAnimationTool to composite the Core Animation
		// title layers with the video content when exporting the video
	}
    
    
	AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:self.composition
																	 presetName:quality];
    
	session.audioMix = self.audioMix;
	session.videoComposition = self.videoComposition;
    session.shouldOptimizeForNetworkUse = YES;

	return session;
}


@end
