//
//  SCSlideItemView.h
//  VideoSlide
//
//  Created by Thi Huynh on 2/14/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCView.h"
#import "SCMediaItemView.h"

@protocol SCSlideItemViewProtocol <NSObject>

@optional
- (void)didSelectItemWithPosition:(CGPoint)pos slideComposition:(SCSlideComposition*)slide;
- (void)didStartSortingWithIndex:(int)index;
- (void)didEndSorting;
- (void)didChangePositionWith:(CGPoint)pos;
- (void)didEndDeleteItemAtIndex:(int)index;

@end

@class SCMediaItemView;

@interface SCSlideItemView : SCMediaItemView

@property (nonatomic, strong)  SCSlideComposition *slideComposition;
@property (nonatomic, strong)  UILabel            *indexLb;
@property (nonatomic)          int                 index;

@property (nonatomic, weak)   id<SCSlideItemViewProtocol> delegate;


- (id)initWithFrame:(CGRect)frame slide:(SCSlideComposition*)slideComposition;
- (void)updateWith:(CGPoint)pos index:(int)index;
- (void)refreshPhoto;

@end
