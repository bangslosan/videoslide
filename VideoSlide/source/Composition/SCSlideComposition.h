//
//  SCSlideComposition.h
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCTransitionComposition.h"
#import "SCMediaComposition.h"

@class SCVideoComposition;
@class SCFilterComposition;

typedef void (^success)(SCVideoComposition*);

@interface SCSlideComposition : SCMediaComposition;

@property (nonatomic, strong) SCSlideModel  *model;
@property (nonatomic, strong) UIImage       *image;
@property (nonatomic, strong) UIImage       *imageWithText;
@property (nonatomic, strong) UIImage       *thumbnailImage;
@property (nonatomic, strong) UIImage       *originalImage; // for Re-Crop function. {nil: photo from Camera Roll, can get original by assetURL (for reduce memory purposel; !nil: photo from Camera/Instagram)}

@property (nonatomic, strong) NSURL         *imageURL;
@property (nonatomic, strong) NSURL         *thumbnailURL;

@property (nonatomic, assign) CGRect        rectCropped;
@property (nonatomic, assign) CGPoint        relativeCroppedPos;

@property (nonatomic, assign) float         currentScale;
@property (nonatomic, assign) BOOL          isCropped;
@property (nonatomic, assign) BOOL          needToRefreshThumbnail;
@property (nonatomic, strong) NSURL         *assetURL;
@property (nonatomic, strong) NSMutableArray  *texts;

@property (nonatomic, strong) SCTransitionComposition *startTransition;
@property (nonatomic, strong) SCTransitionComposition *endTransition;

@property (nonatomic, readonly) CMTimeRange playthroughTimeRange;
@property (nonatomic, readonly) CMTimeRange startTransitionTimeRange;
@property (nonatomic, readonly) CMTimeRange endTransitionTimeRange;

@property (nonatomic, strong) SCFilterComposition *filterComposition;

- (id)initWithImage:(UIImage*)img;

- (id)initWithImage:(UIImage*)img withThumbnail:(UIImage*)thumbnailImage;

- (id)initWithImage:(UIImage*)img withThumbnail:(UIImage*)thumbnailImage withOriginalImage:(UIImage*)originalImage;

- (id)initWithImage:(UIImage*)img withThumbnail:(UIImage*)thumbnailImage withOriginalImage:(UIImage*)originalImage assetURL:(NSURL*)url;

- (id)initWithImage:(UIImage*)img withThumbnail:(UIImage*)thumbnailImage assetURL:(NSURL*)url;

- (id)initWithThumbnailImage:(UIImage*)thumbnailImage assetURL:(NSURL*)url;

- (id)initWithImage:(UIImage*)img startTransTime:(float)startTrans endTransTime:(float)endTrans  duration:(float)duration;

- (SCVideoComposition*)convertToVideoComposition:(BOOL)forExport;

- (SCVideoComposition*)convertToVideoComposition:(BOOL)forExport withDir:(NSURL*)dir;

- (void)updateSlide:(float)duration startTrans:(float)startTrans endTrans:(float)endTrans transType:(SCVideoTransitionType)transType;

- (void)cropImageWithRect:(CGRect)rect andScale:(float)scale;
@end
