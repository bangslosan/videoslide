//
//  SCSlideShowPreview.h
//  SlideshowCreator
//
//  Created 10/10/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"
#import "SCBasicBuilderComposition.h"
#import "SCAdvancedBuilderComposition.h"
#import "SCSlideComposition.h"
@protocol SCSlideShowPreviewProtocol <NSObject>

- (void)currentProgessFromPlayer:(float)progress;
- (void)playerStatus:(SCMediaStatus)status;
- (void)playerReachEndPoint;


@end

@interface SCSlideShowPreview : SCView

@property (nonatomic, strong) AVComposition         *composition;
@property (nonatomic, strong) AVVideoComposition    *videoComposition;
@property (nonatomic, strong) AVAudioMix            *audioMix;
@property (nonatomic, strong) SCVideoDebugViewer	*compositionDebugView;
@property (nonatomic)         float                 realProgressWidth;
@property (nonatomic)         float                 currentViewProgress;;
@property (nonatomic)         float                 currentPlayerTime;
@property (nonatomic, weak)   id<SCSlideShowPreviewProtocol>  delegate;

- (id)initWith:(SCBasicBuilderComposition*)builderData frame:(CGRect)frame;
- (id)initWithBasic:(SCBasicBuilderComposition*)builderData frame:(CGRect)frame;
- (id)initWithAdvanced:(SCAdvancedBuilderComposition*)builderData frame:(CGRect)frame;

+ (id)initWithBasic:(SCBasicBuilderComposition*)builderData frame:(CGRect)frame;
+ (id)initWithAdvanced:(SCAdvancedBuilderComposition*)builderData frame:(CGRect)frame;

- (void)setAdvancedData:(SCAdvancedBuilderComposition*)data;
- (void)setBasicData:(SCBasicBuilderComposition*)data;

- (void)playWithoutVolume;
- (void)play;
- (void)pause;
- (void)beginSeekingTo:(float)value;
- (void)seekingTo:(float)value;
- (void)endSeekingTo:(float)value;
- (void)showDebugViewerInView:(UIView*)view withFrame:(CGRect)frame;
- (BOOL)isPlaying;
@end
