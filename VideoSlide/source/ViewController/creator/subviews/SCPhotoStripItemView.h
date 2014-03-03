//
//  SCPhotoStripItemView.h
//  SlideshowCreator
//
//  Created 10/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"
#import "DirectionPanGestureRecognizer.h"


@protocol SCPhotoStripItemViewProtocol <NSObject>

- (void)didSelectItemWithPosition:(CGPoint)pos slideComposition:(SCSlideComposition*)slide;
- (void)didStartSortingWithIndex:(int)index;
- (void)didEndSorting;
- (void)didChangePositionWith:(CGPoint)pos;
- (void)didEndDeleteItemAtIndex:(int)index;

@end

@class SCMediaItemView;

@interface SCPhotoStripItemView : SCMediaItemView

@property (nonatomic, strong)  SCSlideComposition *slideComposition;
@property (nonatomic, strong)  UILabel            *indexLb;
@property (nonatomic)          int                 index;

@property (nonatomic, weak)   id<SCPhotoStripItemViewProtocol> delegate;


- (id)initWithFrame:(CGRect)frame slide:(SCSlideComposition*)slideComposition;
- (void)updateWith:(CGPoint)pos index:(int)index;
- (void)refreshPhoto;


@end
