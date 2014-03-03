//
//  SCSettingManager.h
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@class SCTextObjectView;

@interface SCSlideShowSettingManager : SCBaseManager

@property (nonatomic, retain) SCSlideShowComposition   *slideShowComposition;
@property (nonatomic, assign) SCVideoDurationType   videoDurationType;
@property (nonatomic, assign) SCVideoTransitionType transitionType;
@property (nonatomic, assign) float                 videoTotalDuration;
@property (nonatomic, assign) int                   transitionDuration;
@property (nonatomic, assign) float                 slideDuration;
@property (nonatomic, assign) BOOL                  transitionsEnabled;
@property (nonatomic, assign) int                   numberPhotos;
@property (nonatomic, strong) SCTextObjectView      *clipboardTextObjectView;

+ (SCSlideShowSettingManager*)getInstance;
+ (BOOL)checkValidVineDuration:(int)numberImage;
+ (BOOL)checkValidInstagramDuration:(int)numberImage;
+ (BOOL)checkValidCustomDuration:(int)numberImage;
+ (BOOL)checkValidWith:(int)numberPhotos videoTotalDuration:(float)videoTotalDuration;

- (BOOL)updateNumberPhoto:(int)numberPhotos andTotalDuration:(int)totalDuration;
- (BOOL)updateTimeWith:(int)numberPhotos videoTotalDuration:(float)videoTotalDuration videoDurationType:(SCVideoDurationType)videoDurationType;
- (BOOL)updateTimeWithoutTransition:(int)numberPhotos videoTotalDuration:(float)videoTotalDuration videoDurationType:(SCVideoDurationType)videoDurationType;
- (int)transitionDurationWith:(SCVideoDurationType)type numberPhotos:(int)number totalDuration:(float)duration;
- (BOOL)canAddMoreSlide;


- (void)logToDebug;
- (void)setNumberOfPhotos:(int)number;


@end
