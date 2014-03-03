//
//  SCVideoDebugViewer.h
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>

@interface SCVideoDebugViewer : SCView
{
@private
	CALayer *drawingLayer;
	CMTime	duration;
	CGFloat compositionRectWidth;
	
	NSArray *compositionTracks;
	NSArray *audioMixTracks;
	NSArray *videoCompositionStages;
	
	CGFloat scaledDurationToWidth;
}

@property AVPlayer *player;

    - (void)synchronizeToComposition:(AVComposition *)composition videoComposition:(AVVideoComposition *)videoComposition audioMix:(AVAudioMix *)audioMix;

@end
