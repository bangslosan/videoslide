//
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerItem (SCAdditions)

@property (nonatomic, strong) AVSynchronizedLayer *titleLayer;

- (BOOL)hasValidDuration;
- (void)muteAudioTracks:(BOOL)value;

@end
