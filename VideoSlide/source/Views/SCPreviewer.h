//
//  SCPreviewer.h
//  SlideshowCreator
//
//  Created 10/3/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"
#import "SCAdvancedBuilderComposition.h"
#import "SCBasicBuilderComposition.h"


@interface SCPreviewer : SCView
@property (nonatomic, strong) AVComposition             *composition;
@property (nonatomic, strong) AVVideoComposition *videoComposition;
@property (nonatomic, strong) AVAudioMix                *audioMix;



- (id)initWithBasic:(SCBasicBuilderComposition*)builderData;
- (id)initWithAdvanced:(SCAdvancedBuilderComposition*)builderData;

+ (id)initWithBasic:(SCBasicBuilderComposition*)builderData;
+ (id)initWithAdvanced:(SCAdvancedBuilderComposition*)builderData;

- (void)setAdvancedData:(SCAdvancedBuilderComposition*)data;
- (void)setBasicData:(SCBasicBuilderComposition*)data;

@end

