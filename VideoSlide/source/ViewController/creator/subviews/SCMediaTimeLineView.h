//
//  SCMediaTimeLineView.h
//  SlideshowCreator
//
//  Created 10/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"
#import "SCSlideShowComposition.h"
#import "SCSlideComposition.h"

@class SCPhotoStripItemView;

@protocol SCMediaTimeLineViewProtocol <NSObject>

@optional

- (void)startSorting;
- (void)startEditMusicTrack;
- (void)startEditAudioRecordTrack;
- (void)audioRecordReachToEndingTimeLine;
- (void)didSelectPhotoItemAtPos:(CGPoint)pos andSlide:(SCSlideComposition*)slide;
- (void)didFinishSortingSlideShow;
- (void)didFinishDeletePhotoItemInSlideShow;
- (void)didFinishDeleteMediaItemInSlideShow;

- (void)dragItemWithPosition:(CGPoint)itemPos;

@end

@interface SCMediaTimeLineView : SCView

@property (nonatomic, weak)   UIScrollView                              *parentScrollView;

@property (nonatomic, strong) SCAudioComposition                        *audioRecord;
@property (nonatomic, strong) SCAudioComposition                        *music;
@property (nonatomic, weak)   id<SCMediaTimeLineViewProtocol>           delegate;
@property (nonatomic)         float                                     realDuration;



- (id)initWithComposition:(SCSlideShowComposition*)slideShow;

- (CGSize)getSize;
- (float)getCurrentAudioRecordWidth;
- (float)getCurrentAudioRecordBegin;

- (void)updateTimeLineWith:(SCSlideShowComposition*)slideShow;
- (SCSlideComposition*)getCurrentSlideWithPosition:(CGPoint)pos;
- (SCPhotoStripItemView*)getCurrentSlideItemViewWithPosition:(CGPoint)pos;
- (SCPhotoStripItemView*)getSLideItemViewWith:(SCSlideComposition*)slide;

- (void)deleteAudioRecord;
- (void)deleteMusicBacground;
- (void)createAudioRecordAt:(float)time;
- (void)updateAudioRecordViewWith:(float)duration;

@end

