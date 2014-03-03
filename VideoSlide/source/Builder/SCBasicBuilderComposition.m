//
//  SCBuilderComposition.m
//  SlideshowCreator
//
//  Created 9/26/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBasicBuilderComposition.h"

@interface SCBasicBuilderComposition ()

@end

@implementation SCBasicBuilderComposition

@synthesize composition = _composition;
@synthesize audioMix    = _audioMix;
@synthesize videoComposition = _videoComposition;
@synthesize layer = _layer;
@synthesize exporter = _exporter;
@synthesize animationTool = _animationTool;

+ (id)compositionWithComposition:(AVComposition *)composition
{
	return [[self alloc] initWithComposition:composition];
}

- (id)initWithComposition:(AVComposition *)composition
{
	self = [super init];
	if (self) {
		_composition = composition;
	}
	return self;
}


+ (id)compositionWithComposition:(AVComposition *)composition videoComposition:(AVVideoComposition *)videoComposition
{
	return [[self alloc] initWithComposition:composition videoComposition:videoComposition];
}

- (id)initWithComposition:(AVComposition *)composition videoComposition:(AVVideoComposition *)videoComposition
{
	self = [super init];
	if (self) {
		_composition = composition;
        _videoComposition = videoComposition;
    
	}
	return self;
}


- (AVPlayerItem *)makePlayable {
	return [AVPlayerItem playerItemWithAsset:[self.composition copy]];
}

- (AVAssetExportSession *)makeExportable:(NSString*)quality
{

    
	AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:self.composition
																	 presetName:quality];
	if(self.audioMix)
        session.audioMix = self.audioMix;
	
    session.videoComposition = self.videoComposition;
    session.shouldOptimizeForNetworkUse = YES;
    
	return session;
}




- (void)clearAll
{
    
}





@end
