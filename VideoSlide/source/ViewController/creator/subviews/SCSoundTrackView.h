//
//  SCSoundTrackView.h
//  SlideshowCreator
//
//  Created 10/14/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@protocol SCSoundTrackViewProtocol <NSObject>

- (void)didFinishEditingMusic:(SCAudioComposition*)musicComposition;
- (void)didCancelSelectSong;

@end

@interface SCSoundTrackView : SCView

@property (nonatomic, weak) id<SCSoundTrackViewProtocol> delegate;

- (void)setMusicComposition:(SCAudioComposition*)music;
- (void)updateWithMusicComposition:(SCAudioComposition*)music;
- (void)deleteSong;
- (void)showItunes;
@end
