//
//  SCSlideShowComposition.h
//  SlideshowCreator
//
//  Created 9/10/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCComposition.h"
#import "SCAudioComposition.h"
#import "SCSlideComposition.h"
#import "SCTransitionComposition.h"

@protocol SCSlideShowCompositionProtocol  <NSObject>

@optional
- (void)prebuildProgressValue:(float)currentValue totalValue:(float)totalValue;
- (void)finishCropAllPhoto;
- (void)finishGetAllPhotoFromAsset;
- (void)numberCroppedImage:(int)numberImage;
- (void)numberGotImage:(int)numberImage;

@end

@interface SCSlideShowComposition : SCComposition

@property (nonatomic, weak)   id<SCSlideShowCompositionProtocol>   delegate;

@property (nonatomic, strong) SCSlideShowModel *model;
@property (nonatomic, strong) NSMutableArray *slides;
@property (nonatomic, strong) NSMutableArray *transitions;
@property (nonatomic, strong) NSMutableArray *audios;
@property (nonatomic, strong) NSMutableArray *musics;
@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, strong) UIImage        *thumbnailImg;
@property (nonatomic, strong) NSMutableArray *deleteItems;

@property (nonatomic)         BOOL           isAdvanced;
@property (nonatomic)         BOOL           isComposing;
@property (nonatomic)         BOOL           iSOverWrite;
@property (nonatomic)         CMTime         totalDuration;

@property (nonatomic, strong) NSURL          *exportURL;
@property (nonatomic, strong) NSDate         *dateCreated;
@property (nonatomic, strong) NSString       *mediaExportQuality;


@property (nonatomic, strong) SCAudioComposition *record;
@property (nonatomic, strong) SCAudioComposition *music;

- (void)addSlides:(NSMutableArray*)slides;
- (void)addMoreSlides:(NSMutableArray*)slides;
- (void)addSlideComposition:(SCSlideComposition*)slide;
- (void)addSlideComposition:(SCSlideComposition*)slide atIndex:(int)index;
- (void)addTransitionAfterSlideIndex:(int)index transition:(SCTransitionComposition*)transition;
- (void)deleteSlideComposition:(SCSlideComposition*)slide;

- (void)refreshSlideShow;
- (void)preBuild;
- (BOOL)exportResourcesToProject;
- (void)updateSLideShowSetting;

- (void)preBuildAsynchronouslyWithCompletionHandler:(void (^)(void))completionBlock;
- (void)preExportAsynchronouslyWithCompletionHandler:(void (^)(void))completionBlock;
- (void)updateAsynchronouslyWithCompletionHandler:(void (^)(void))completionBlock;

- (void)startCropAllPhotos;
- (void)getAllPhotoFromAssetWithoutCrop;

@end

