//
//  SCItemGridView.m
//  SlideshowCreator
//
//  Created 10/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "GMGridView.h"
#import "SCItemGridView.h"

@interface SCItemGridView () <UIGestureRecognizerDelegate,GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate, UIScrollViewDelegate, GMGridViewLayoutStrategy, GMGridViewDataSource>

@property (nonatomic)         CGSize size;
@property (nonatomic, strong) NSTimer *loadingTimer;

- (void)initLoadingView;

@end

@implementation SCItemGridView

@synthesize isUsingDynamicData = _isUsingDynamicData;
@synthesize data = _data;
@synthesize gridView = _gridView;
@synthesize type = _type;
@synthesize delegate =_delegate;
@synthesize currentIndex = _currentIndex;
@synthesize numberItemPerPage = _numberItemPerPage;
@synthesize enableEditing = _enableEditing;
// pull to refresh
@synthesize headerView = _headerView;
@synthesize pullArrowImgView = _pullArrowImgView;
@synthesize pullLoadingIndicator = _pullLoadingIndicator;
@synthesize pullToRefreshLabel = _pullToRefreshLabel;
@synthesize isUsingPullToRefresh = _isUsingPullToRefresh;
@synthesize isInLoadingProgress = _isInLoadingProgress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (id)initWith:(CGRect)frame andType:(SCGridViewType)type numberItemPerPage:(int)number
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.isUsingDynamicData = NO;
        
        NSLog(@"Frame [%f,%f]",self.frame.size.width,self.frame.size.height);
        self.type = type;
        //init grid view
        self.gridView = [[GMGridView alloc] initWithFrame:self.bounds];
        self.gridView .autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.gridView .backgroundColor = [UIColor clearColor];
        [self addSubview:self.gridView ];
        self.backgroundColor = [UIColor clearColor];
        
        //set up gridview
        self.gridView.style = GMGridViewStylePush;
        self.gridView.centerGrid = NO;
        self.gridView.clipsToBounds = YES;

        self.gridView.delegate = self;
        self.gridView.dataSource = self;
        self.gridView.actionDelegate = self;
        self.gridView.mainSuperView = self;
        
        if(type == SCGridViewTypeVertical)
        {
            self.gridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
            self.gridView.itemSpacing = 0;
            self.gridView.minEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0);
            [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        }
        else if(type == SCGridViewTypeLargeVertical)
        {
            self.gridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
            self.gridView.itemSpacing = 8;
            self.gridView.minEdgeInsets = UIEdgeInsetsMake(4, 8, 0, 8);
            [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
        }
        else if(type == SCGridViewTypeLargeHorizontal)
        {
            self.gridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontalPagedLTR];
            self.gridView.itemSpacing = 16;
            self.gridView.minEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
            [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
            self.gridView.showsHorizontalScrollIndicator = NO;
        }
        self.currentIndex = 0;
        self.numberItemPerPage = number;
        [self initLoadingView];
        //auto resizing for multiple screen
        
        if (self.isUsingPullToRefresh) {
            [self addPullToRefreshHeader];
        }
        
    }
    return self;
}

- (void)initLoadingView
{
   
}

- (void)addPullToRefreshHeader {
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - SC_GRIDVIEW_HEADER_HEIGHT, 320, SC_GRIDVIEW_HEADER_HEIGHT)];
    
    self.pullArrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 10, 22, 31)];
    self.pullArrowImgView.image = [UIImage imageNamed:@"image_pull_arrow.png"];
    
    self.pullToRefreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 30)];
    self.pullToRefreshLabel.backgroundColor = [UIColor clearColor];
    self.pullToRefreshLabel.text = @"Pull down to refresh";
    self.pullToRefreshLabel.font = [UIFont systemFontOfSize:14.0];
    self.pullToRefreshLabel.textAlignment = NSTextAlignmentCenter;
    self.pullToRefreshLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:170.0/255.0 blue:220.0/255.0 alpha:1.0];
    
    self.pullLoadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(60, 10, 30, 30)];
    self.pullLoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    //[self.pullLoadingIndicator startAnimating];
    
    [self.headerView addSubview:self.pullArrowImgView];
    [self.headerView addSubview:self.pullToRefreshLabel];
    [self.headerView addSubview:self.pullLoadingIndicator];
    [self.gridView addSubview:self.headerView];
    
    self.gridView.alwaysBounceVertical = YES;
}

#pragma mark - get/set

- (void)loadMoreItem:(NSMutableArray*)data
{
    if(self.data.count < data.count)
    {
        _data = data;
        [self reloadData];
    }
}

- (void)setData:(NSMutableArray *)data
{
    _data = data;
    [self reloadData];
}

- (void)setDelegate:(id<SCItemGridViewProtocol>)delegate
{
    _delegate = delegate;
    //call delegate to load data
    [self showSignalLoading];
    [self.delegate SCitemGridView:self loadDataAtfirstTimeWith:self.numberItemPerPage];
}

- (void)setEnableEditing:(BOOL)enableEditing
{
    _enableEditing = enableEditing;
    if(_enableEditing)
    {
        self.gridView.sortingDelegate = self;
        //self.gridView.transformDelegate = self;

    }
    else
    {
        self.gridView.sortingDelegate = nil;
        //self.gridView.transformDelegate = nil;

    }
}
#pragma mark - class methods

- (void)resetWithData:(NSMutableArray*)data
{
    self.currentIndex = 0;
    [self setData:data];
}

- (void)reloadGridView
{
    [self.gridView reloadData];
}

- (void)reloadData
{
    [self.gridView reloadData];
    if( self.gridView.contentOffset.y >= self.gridView.frame.size.height)
    {
        if(self.data.count > self.currentIndex * self.numberItemPerPage)
        {
            [self.gridView setContentOffset:CGPointMake(0,self.gridView.contentSize.height - self.gridView.frame.size.height) animated:YES];
        }
    }
    self.isInLoadingProgress = NO;
    [self hideSignalLoading];
}

- (void)showSignalLoading
{
    
}

- (void)hideSignalLoading
{
    
}

- (void)noDataResponse
{
    self.currentIndex --;
    self.isInLoadingProgress = NO;
    [self hideSignalLoading];
}

#pragma gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma gridView delegate

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.data count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    self.size = [self.delegate sizeForItemCell];
    return self.size;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    SCItemGridViewCell *cell  = [self.delegate SCitemGridView:self cellForItemAtIndex:index];
    
    return cell;
}

#pragma mark GMGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    SCItemGridViewCell *cell = (SCItemGridViewCell*)[self.gridView cellForItemAtIndex:position];
    if ([self.delegate respondsToSelector:@selector(SCitemGridView:didSelectItemAtIndex:withItem:)]) {
         //[self.delegate SCitemGridView:self didSelectItemAtIndex:position withItem:[self getItemAtIndex:position]];
    }
    if ([self.delegate respondsToSelector:@selector(SCitemGridView:didSelectItemAtIndex:)])
    {
        [self.delegate SCitemGridView:self  didSelectItemAtIndex:position];
    }
    if ([self.delegate respondsToSelector:@selector(SCitemGridView:didSelectItemAtIndex:withCell:)])
    {
        [self.delegate SCitemGridView:self  didSelectItemAtIndex:position withCell:cell];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.backgroundColor = [UIColor orangeColor];
                         cell.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.backgroundColor = [UIColor redColor];
                         cell.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    NSObject *object = [self.data objectAtIndex:oldIndex];
    [self.data removeObject:object];
    [self.data insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    [self.data exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

#pragma mark - scrolview delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!self.isUsingDynamicData)
        return;
    if(!self.isInLoadingProgress)
    {
        NSLog(@"self.gridView.contentOffset.y: %f", self.gridView.contentOffset.y);
        if (self.gridView.contentOffset.y <= -SC_GRIDVIEW_HEADER_HEIGHT)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.gridView.contentInset = UIEdgeInsetsMake(SC_GRIDVIEW_HEADER_HEIGHT, 0, 0, 0);
                self.pullToRefreshLabel.text = @"Loading...";
                self.pullArrowImgView.hidden = YES;
                [self.pullLoadingIndicator startAnimating];
                
                [self.delegate SCitemGridView:self refreshDataWith:0];
                self.isInLoadingProgress = YES;
            }];
        }
        else if(self.gridView.contentOffset.y >= self.gridView.contentSize.height - self.gridView.frame.size.height)
        {
            self.currentIndex ++;
            self.isInLoadingProgress = YES;
            [self.delegate SCitemGridView:self loadMoreItemWith:self.currentIndex  numberItem:self.numberItemPerPage];
        }
    }
    
    if(self.loadingTimer.isValid)
    {
        [self.loadingTimer invalidate];
        self.loadingTimer = nil;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([self.delegate respondsToSelector:@selector(startScroll:yValue:)])
    {
        [self.delegate startScroll:scrollView.contentOffset.x yValue:scrollView.contentOffset.y];
    }
    
    if(!self.isUsingDynamicData)
        return;
    if(!self.loadingTimer.isValid && !self.isInLoadingProgress)
    {
        self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.018 target:self selector:@selector(loadingTick:) userInfo:nil repeats:YES];
        // force timer run while  gridview isb scrolling
        [[NSRunLoop mainRunLoop] addTimer:self.loadingTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isInLoadingProgress) {
        [UIView animateWithDuration:0.25 animations:^{
            if (self.gridView.contentOffset.y < -SC_GRIDVIEW_HEADER_HEIGHT) {
                // User is scrolling above the header
                self.pullToRefreshLabel.text = @"Release to refresh";
                [self.pullArrowImgView layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                self.pullToRefreshLabel.text = @"Pull down to refresh";
                [self.pullArrowImgView layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)resetFramePosition {
    [UIView animateWithDuration:0.3 animations:^{
        self.gridView.contentInset = UIEdgeInsetsZero;
    } completion:^(BOOL finished){
        [self.pullLoadingIndicator stopAnimating];
        self.pullArrowImgView.hidden = NO;
        self.pullToRefreshLabel.text = @"Pull down to refresh";
    }];
}

- (void)loadingTick:(id)sender
{
    if(!self.isUsingDynamicData)
        return;
    NSLog(@"offset [%f]",self.gridView.contentOffset.y);
    NSLog(@"size [%f]", self.gridView.contentSize.height);
    if(self.gridView.contentOffset.y >= self.gridView.contentSize.height - self.gridView.frame.size.height)
    {
        [self showSignalLoading];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if([self.delegate respondsToSelector:@selector(didGotoPage:yValue:)])
    {
        [self.delegate didGotoPage:scrollView.contentOffset.x yValue:scrollView.contentOffset.y];
    }
}


#pragma mark - clear all
- (void)clearAll
{
    if(self.gridView.superview)
        [self.gridView removeFromSuperview];
    self.gridView.delegate = nil;
    self.gridView.actionDelegate = nil;
    self.gridView.sortingDelegate = nil;
    self.gridView.transformDelegate = nil;
    self.gridView.dataSource = nil;
    self.gridView = nil;
    
    if(self.loadingTimer.isValid)
    {
        [self.loadingTimer invalidate];
        self.loadingTimer = nil;
    }
    
    self.delegate = nil;
    if(self.data.count > 0)
    {
      //  [self.data removeAllObjects];
    }
    self.data = nil;
}

@end


