//
//  SCBuilderComposition.h
//  SlideshowCreator
//
//  Created 9/26/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  SCBuilderCompositionProtocol <NSObject>

- (AVPlayerItem *)makePlayable;
- (AVAssetExportSession *)makeExportable:(NSString*)quality;

@end

@protocol SCMediaCompositionBuilderProtocol <NSObject>

- (id <SCBuilderCompositionProtocol>)buildMediaComposition;

@end

@interface SCBasicBuilderComposition : NSObject <SCBuilderCompositionProtocol>

@property (nonatomic, strong) AVComposition *composition;
@property (nonatomic, strong) AVVideoComposition *videoComposition;
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, strong) CALayer *layer;
@property (nonatomic, strong) AVAssetExportSession *exporter;
@property (nonatomic, strong)   AVVideoCompositionCoreAnimationTool *animationTool;



+ (id)compositionWithComposition:(AVComposition *)composition;

- (id)initWithComposition:(AVComposition *)composition;

+ (id)compositionWithComposition:(AVComposition *)composition videoComposition:(AVVideoComposition *)videoComposition;

- (id)initWithComposition:(AVComposition *)composition  videoComposition:(AVVideoComposition *)videoComposition;


- (void)clearAll;

@end
