//
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "AVPlayerItem+SCAdditions.h"
#import <objc/runtime.h>

static id THSynchronizedLayerKey;

@implementation AVPlayerItem (SCAdditions)

- (BOOL)hasValidDuration {
	return self.status == AVPlayerItemStatusReadyToPlay && !CMTIME_IS_INVALID(self.duration);
}

- (AVSynchronizedLayer *)titleLayer {
	return objc_getAssociatedObject(self, &THSynchronizedLayerKey);
}

- (void)setTitleLayer:(AVSynchronizedLayer *)titleLayer {
	objc_setAssociatedObject(self, &THSynchronizedLayerKey, titleLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)muteAudioTracks:(BOOL)value {
	for (AVPlayerItemTrack *track in self.tracks) {
		if ([track.assetTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
			track.enabled = !value;
		}
	}
}

@end
