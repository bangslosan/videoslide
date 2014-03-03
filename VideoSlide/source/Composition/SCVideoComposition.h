//
//  SCVideoComposition.h
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCMediaComposition.h"
#import "SCTransitionComposition.h"

@interface SCVideoComposition : SCMediaComposition

@property (nonatomic, strong) SCVideoModel *model;
@property (nonatomic, strong) NSArray   *thumbnails;
@property (nonatomic, strong) SCTransitionComposition *startTransition;
@property (nonatomic, strong) SCTransitionComposition *endTransition;

@property (nonatomic, readonly) CMTimeRange playthroughTimeRange;
@property (nonatomic, readonly) CMTimeRange startTransitionTimeRange;
@property (nonatomic, readonly) CMTimeRange endTransitionTimeRange;


+ (id)videoItemWithURL:(NSURL *)url;


@end
