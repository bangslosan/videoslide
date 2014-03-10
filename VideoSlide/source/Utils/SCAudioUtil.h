//
//  SCAudioUtil.h
//  SlideshowCreator
//
//  Created 9/13/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCAudioUtil : NSObject

+ (void)makeAudioFadeOutWithSourceURL:(NSURL*)sourceURL destinationURL:(NSURL*)destinationURL fadeOutBeginSecond:(NSInteger)beginTime fadeOutEndSecond:(NSInteger)endTime fadeOutBeginVolume:(CGFloat)beginVolume fadeOutEndVolume:(CGFloat)endVolume callback:(void(^)(BOOL))callback;


+ (NSData *) renderPNGAudioPictogramLogForAssett:(AVURLAsset *)songAsset;

@end
