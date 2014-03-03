//
//  SCItemGridView.h
//  SlideshowCreator
//
//  Created 10/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"
#import "GMGridView.h"
#import "GMGridViewLayoutStrategies.h"

@protocol SCItemGridViewProtocol;

@interface SCItemGridView : UIView 

@property (nonatomic) int currentIndex;
@property (nonatomic) int numberItemPerPage;
@property (nonatomic, strong) GMGridView *gridView;
@property (nonatomic)         SCGridViewType type;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, weak)   id<SCItemGridViewProtocol> delegate;
@property (nonatomic) BOOL     isUsingDynamicData;
@property (nonatomic) BOOL     isUsingPullToRefresh;
@property (nonatomic) BOOL     enableEditing;
// header pull to refresh
@property (nonatomic, strong) UIView                    *headerView;
@property (nonatomic, strong) UIImageView               *pullArrowImgView;
@property (nonatomic, strong) UILabel                   *pullToRefreshLabel;
@property (nonatomic, strong) UIActivityIndicatorView   *pullLoadingIndicator;

@property (nonatomic) int isInLoadingProgress;

- (id)initWith:(CGRect)frame andType:(SCGridViewType)type numberItemPerPage:(int)number;
- (void)clearAll;

- (void)loadMoreItem:(NSMutableArray*)data;
- (void)reloadData;
- (void)reloadGridView;
- (void)showSignalLoading;
- (void)hideSignalLoading;
- (void)noDataResponse;
- (void)resetWithData:(NSMutableArray*)data;
- (void)resetFramePosition;
- (void)addPullToRefreshHeader;
- (void)parseIsInLoadingProgress:(BOOL)isLoading;
@end


@protocol SCItemGridViewProtocol <NSObject>

@optional

- (void)SCitemGridView:(SCItemGridView*)itemGridView didSelectItemAtIndex:(int)index;
- (void)SCitemGridView:(SCItemGridView*)itemGridView didSelectItemAtIndex:(int)index withCell:(SCItemGridViewCell*)cell;
- (void)SCitemGridView:(SCItemGridView*)itemGridView loadDataAtfirstTimeWith:(int)numberPage;
- (void)SCitemGridView:(SCItemGridView*)itemGridView loadMoreItemWith:(int)currentPage numberItem:(int)number;
- (void)SCitemGridView:(SCItemGridView*)itemGridView refreshDataWith:(int)numberPage;
- (SCItemGridViewCell*)SCitemGridView:(SCItemGridView*)itemGridView cellForItemAtIndex:(int)index;
- (CGSize)sizeForItemCell;
- (void)didGotoPage:(float)x yValue:(float)y;
- (void)startScroll:(float)x yValue:(float)y;

@end