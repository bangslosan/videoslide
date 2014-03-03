//
//  SCVideoPreview.h
//  VideoSlide
//
//  Created by Thi Huynh on 2/25/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCView.h"
#import "SCBasicBuilderComposition.h"
#import "SCAdvancedBuilderComposition.h"
#import "SCSlideComposition.h"

@protocol SCVideoPreviewProtocol <NSObject>


@optional
- (void)currentProgessFromPlayer:(float)progress;
- (void)playerStatus:(SCMediaStatus)status;
- (void)playerReachEndPoint;


@end

@interface SCVideoPreview : SCView

@property (nonatomic)         float                 realProgressWidth;
@property (nonatomic)         float                 currentViewProgress;;
@property (nonatomic)         float                 currentPlayerTime;
@property (nonatomic, weak)   id<SCVideoPreviewProtocol>  delegate;

- (id)initWith:(SCBasicBuilderComposition*)builderData frame:(CGRect)frame;
- (void)setBasicData:(SCBasicBuilderComposition*)data;

- (void)play;
- (void)pause;
- (void)beginSeekingTo:(float)value;
- (void)seekingTo:(float)value;
- (void)endSeekingTo:(float)value;
- (BOOL)isPlaying;

@end
