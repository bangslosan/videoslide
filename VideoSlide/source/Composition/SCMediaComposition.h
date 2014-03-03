//
//  SCMediaComposition.h
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCComposition.h"

typedef void(^THPreparationCompletionBlock)(BOOL complete);

@interface SCMediaComposition : SCComposition

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign, readonly) BOOL prepared;
@property (nonatomic, readonly) NSString *mediaType;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *projectURL;
@property (nonatomic, strong) NSString *mediaID;


- (id)initWithURL:(NSURL *)url;

- (void)prepareWithCompletionBlock:(THPreparationCompletionBlock)completionBlock;

- (void)performPostPrepareActionsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock;

- (BOOL)isTrimmed;

- (AVPlayerItem *)makePlayable;

- (void)resetTimeRangeWithAsset;

- (void)deleteAssetFile;


@end
