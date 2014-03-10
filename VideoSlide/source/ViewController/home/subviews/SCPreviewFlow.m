//
//  SCPreviewFlow.m
//  VideoSlide
//
//  Created by Thi Huynh on 2/14/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCPreviewFlow.h"


@interface SCPreviewFlow () <SCSlideItemViewProtocol, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *previewScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *timelineScrollView;
@property (nonatomic, strong) IBOutlet UIImageView  *previewImgView;
@property (nonatomic, strong) IBOutlet UIView *timelineContentView;

@property (nonatomic, strong) NSMutableArray *slides;

@property (nonatomic, strong) SCSlideItemView                   *currentItem;
@property (nonatomic, strong) UILongPressGestureRecognizer      *longGesture;

@property (nonatomic)         int                               currentSortingIndex;
@property (nonatomic)         BOOL                              autoScrollActive;
@property (nonatomic, strong) NSTimer                           *autoScrollTimer;


- (void)updatePreviewFlow;

@end

@implementation SCPreviewFlow

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

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCPreviewFlow" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        
    }
    
    return self;
}

- (id)initWith:(NSMutableArray*)slides
{
    self = [self init];
    if(self)
    {
        self.slides = slides;
        [self updatePreviewFlow];
        
        //init gesture
        if(!self.longGesture )
        {
            self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
            self.longGesture.minimumPressDuration = 0.5;
            [self.timelineScrollView addGestureRecognizer:self.longGesture];
        }
        
        //don't clip subview
        self.timelineContentView.clipsToBounds = NO;
        self.timelineScrollView.clipsToBounds = NO;
        self.clipsToBounds = NO;
        
        self.previewScrollView.maximumZoomScale = 8;
        self.previewScrollView.minimumZoomScale = 1;
        self.previewScrollView.delegate = self;
        

    }
    return  self;
}

#pragma mark - object methods

- (void)updateWithSlides:(NSMutableArray*)slides
{
    self.slides = slides;
    [self updatePreviewFlow];
    [self.timelineScrollView setContentOffset:CGPointMake(self.timelineScrollView.contentSize.width - self.timelineScrollView.frame.size.width, self.timelineScrollView.contentOffset.y) animated:YES];
    
}


- (void)updatePreviewFlow
{
    
    //init all array
    for(SCSlideItemView *photo in self.timelineContentView.subviews)
    {
        [photo clearAll];
        [photo removeFromSuperview];
        photo.delegate = nil;
    }
    
    if(self.timelineContentView.subviews.count == 0)
    {
        int i = 0;
        for(SCSlideComposition *slide in self.slides)
        {
            SCSlideItemView *item = [[SCSlideItemView alloc]initWithFrame:CGRectMake(i*SC_TIMELINE_ITEM_SIZE.width, 0, SC_TIMELINE_ITEM_SIZE.width, SC_TIMELINE_ITEM_SIZE.height) slide:slide];
            item.delegate = self;
            item.mainSuperView = self.mainSuperView;
            item.indexLb.text = [NSString stringWithFormat:@"%d",i];
            if(slide.currentScale <= 1)
                [self calculateSlideCropRect:item.slideComposition withVisibleRect:CGRectMake(0, 0, SC_CROP_PHOTO_SIZE.width, SC_CROP_PHOTO_SIZE.height) scale:slide.currentScale];
            [self.timelineContentView addSubview:item];
            //get the first slide to preview
            if(i == 0)
            {
                [self.previewImgView setImage:slide.image];
                self.currentItem = item;
            }
            i++;
        }
        [self.timelineContentView setFrame:CGRectMake(0, 0, i*SC_TIMELINE_ITEM_SIZE.width, SC_TIMELINE_ITEM_SIZE.height)];
        //update view item index
        [self updateItemsIndex];
        //create item time line size
    }
    if(self.timelineContentView.frame.size.width < self.timelineScrollView.frame.size.width)
    {
        self.timelineContentView.frame = CGRectMake(0, 0, self.timelineScrollView.frame.size.width + 0.5, SC_TIMELINE_ITEM_SIZE.height);
    }
    [self.timelineScrollView setContentSize:self.timelineContentView.frame.size];
    self.timelineScrollView.scrollEnabled = YES;

}

- (void)updateItemsIndex
{
    int i = 0;
    for(SCSlideComposition *slide in self.slides)
    {
        for(SCSlideItemView *item in self.timelineContentView.subviews)
        {
            if(item.slideComposition == slide)
            {
                item.index = i;
            }
        }
        i++;
    }
}

#pragma mark - action + sorting + delete

- (void)onPress:(UILongPressGestureRecognizer *)gesture
{
    //checl if there is only 1 photo strip --> do not allow to press
    if(self.slides.count == 1)
        return;
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint locationInView = [self.longGesture locationInView:self.timelineContentView];
        if(CGRectContainsPoint(self.timelineContentView.frame, locationInView))
        {
            CGPoint locationInPhotoStrip = [self.longGesture locationInView:self.timelineContentView];
            int index = [self itemIndexFromPosition:locationInPhotoStrip];
            if(index != SC_GRIDVIEW_INVALID_INDEX)
            {
                self.currentItem = [self itemWithIndex:index];
                self.currentItem.index = SC_GRIDVIEW_INVALID_INDEX;
                self.currentSortingIndex = index;
                
                [self.currentItem beginWithGesture:gesture zoom:YES moveUp:NO completion:^
                 {
                     _autoScrollActive = YES;
                     [self autoScrollWithGesture:self.longGesture];
                     
                 }];
                NSLog(@"start move slide item");
            }
        }
    }
    else if(gesture.state == UIGestureRecognizerStateChanged)
    {
        if(self.currentItem)
        {
            [self.currentItem updateWithGesture:self.longGesture];
            [self selectedItemChangePositionWith:self.longGesture];
        }
    }
    else if(gesture.state == UIGestureRecognizerStateEnded
            || gesture.state == UIGestureRecognizerStateCancelled
            || gesture.state == UIGestureRecognizerStateFailed )
    {
        if(self.currentItem)
        {
            if(self.currentItem && self.currentSortingIndex >= 0 && self.currentSortingIndex < self.slides.count)
            {
                self.currentItem.lastPosition = [self itemPositionFromIndex:self.currentSortingIndex];
                self.currentItem.index = self.currentSortingIndex;
            }
            
            [self.currentItem endWithGesture:gesture completion:^
             {
                 if(self.currentItem.markDelete)
                 {
                     [self didDeleteCurrentSlideItem];
                     [self.currentItem removeFromSuperview];
                 }
                 else
                 {
                     [self didEndSorting];
                 }
             }];
        }
        _autoScrollActive = NO;
        [self stopAutoScroll];
        NSLog(@"End move");
    }
}


- (void)stopAutoScroll
{
    if(self.autoScrollTimer.isValid)
    {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
    
}
- (void)autoScrollWithGesture:(UIGestureRecognizer*)gesture
{
    [self stopAutoScroll];
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.018 target:self selector:@selector(onAutoScroll:) userInfo:nil repeats:YES];
    
    
}
- (void)onAutoScroll:(id)sender
{
    if (_autoScrollActive)
    {
        CGPoint locationInMainView = [self.longGesture locationInView:self.timelineScrollView];
        locationInMainView = CGPointMake(locationInMainView.x - self.timelineScrollView.contentOffset.x,
                                         locationInMainView.y -self.timelineScrollView.contentOffset.y
                                         );
        CGPoint offset = self.timelineScrollView.contentOffset;
        
        CGFloat threshhold = SC_TIMELINE_ITEM_SIZE.width;
        // Going right
        if (locationInMainView.x + threshhold > self.timelineScrollView.bounds.size.width)
        {
            self.timelineScrollView.contentOffset = CGPointMake(self.timelineScrollView.contentOffset.x + DELTA_TIME * SC_TIMELINE_ITEM_SIZE.width * 2, self.timelineScrollView.contentOffset.y);
            if (self.timelineScrollView.contentOffset.x > self.timelineScrollView.contentSize.width - self.timelineScrollView.frame.size.width)
            {
                self.timelineScrollView.contentOffset = CGPointMake(self.timelineScrollView.contentSize.width - self.timelineScrollView.frame.size.width, self.timelineScrollView.contentOffset.y);
            }
        }
        // Going left
        else if (locationInMainView.x - threshhold < 0 )
        {
            self.timelineScrollView.contentOffset = CGPointMake(self.timelineScrollView.contentOffset.x - DELTA_TIME * SC_TIMELINE_ITEM_SIZE.width *  2, self.timelineScrollView.contentOffset.y);
            if (self.timelineScrollView.contentOffset.x < 0)
            {
                self.timelineScrollView.contentOffset = CGPointMake(0, self.timelineScrollView.contentOffset.y);
            }
        }
        if(offset.x != self.timelineScrollView.contentOffset.x)
        {
            if(self.currentItem)
            {
                [self.currentItem updateWithGesture:self.longGesture];
                [self selectedItemChangePositionWith:self.longGesture];
            }
        }
    }
}


- (void)selectedItemChangePositionWith:(UIGestureRecognizer*)gesture
{
    CGPoint locationIntimelineContentView = [gesture locationInView:self.timelineContentView];
    int nextItemIndex = [self itemIndexFromPosition:locationIntimelineContentView];
    if(nextItemIndex != self.currentSortingIndex  && nextItemIndex != SC_GRIDVIEW_INVALID_INDEX)
    {
        SCSlideItemView *item = [self itemWithIndex:nextItemIndex];
        if(item != self.currentItem && item.index != self.currentSortingIndex)
        {
            NSLog(@"[Current Index [%d]]", self.currentSortingIndex);
            NSLog(@"[Next index [%d]", nextItemIndex);
            item.index = self.currentSortingIndex;
            //item.center = [self itemPositionFromIndex:item.index];
            [item updateWith:[self itemPositionFromIndex:item.index] index:self.currentSortingIndex];
            
            //update slide show + video index
            int lastIndex = [self.slides indexOfObject:self.currentItem.slideComposition];
            int newIndex = [self.slides indexOfObject:item.slideComposition];
            
            [self.slides removeObjectAtIndex:lastIndex];
            [self.slides insertObject:self.currentItem.slideComposition atIndex:newIndex];
            
            self.currentSortingIndex = nextItemIndex;
        }
    }
}

- (void)didEndSorting
{
    
}

- (void)didDeleteCurrentSlideItem
{
    int currentItemIndex = [self.slides indexOfObject:self.currentItem.slideComposition];
    if(currentItemIndex > 1)
        currentItemIndex = currentItemIndex - 1;
    if(currentItemIndex == 1)
        currentItemIndex = 0;
    //remove slide /video from global array
    if(self.currentItem)
    {
        [self.slides removeObject:self.currentItem.slideComposition];
        [self.currentItem.slideComposition clearAll];
        self.currentItem.slideComposition = nil;
        [self.currentItem removeFromSuperview];
        [self.currentItem clearAll];
    }
    //auto arrange other slides
    for(SCSlideItemView *itemView in self.timelineContentView.subviews)
    {
        if(itemView.index > self.currentSortingIndex)
            itemView.index --;
    }
    
    [UIView animateWithDuration:0.3 animations:^
     {
         for(SCSlideItemView *itemView in self.timelineContentView.subviews)
         {
             itemView.center = [self itemPositionFromIndex:itemView.index];
             itemView.lastPosition = itemView.center;
         }
         
     }completion:^(BOOL finished) {
         self.currentItem = nil;
         self.currentSortingIndex = SC_GRIDVIEW_INVALID_INDEX;
         
         if(currentItemIndex < self.slides.count)
         {
             SCSlideComposition *slide = [self.slides objectAtIndex:currentItemIndex];
             self.currentItem = [self itemWithSlide:slide];
             if(self.currentItem)
                 [self selectItemToPreview:self.currentItem.slideComposition];
         }

         
     }];
}
#pragma mark - scrollview delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.previewImgView;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    //NSLog(@"Final pos [%.2f][%.2f]", scrollView.contentOffset.x,scrollView.contentOffset.y);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if(self.currentItem)
    {
        self.currentItem.slideComposition.relativeCroppedPos = scrollView.contentOffset;
        [self calculateSlideCropRect:self.currentItem.slideComposition withVisibleRect:CGRectMake(scrollView.contentOffset.x*2, scrollView.contentOffset.y *2, scrollView.contentSize.width*2, scrollView.contentSize.height*2) scale:scale];
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.currentItem)
    {
        self.currentItem.slideComposition.relativeCroppedPos = scrollView.contentOffset;
        [self calculateSlideCropRect:self.currentItem.slideComposition withVisibleRect:CGRectMake(scrollView.contentOffset.x*2, scrollView.contentOffset.y *2, scrollView.contentSize.width*2, scrollView.contentSize.height*2) scale:scrollView.zoomScale];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Final pos [%.2f][%.2f]", scrollView.contentOffset.x,scrollView.contentOffset.y);
    if(self.currentItem)
    {
        self.currentItem.slideComposition.relativeCroppedPos = scrollView.contentOffset;
        [self calculateSlideCropRect:self.currentItem.slideComposition withVisibleRect:CGRectMake(scrollView.contentOffset.x*2, scrollView.contentOffset.y *2, scrollView.contentSize.width*2, scrollView.contentSize.height*2) scale:scrollView.zoomScale];
    }
}

#pragma mark GestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL valid = YES;
    return valid;
}

#pragma mark - slide item protocol

- (void)didSelectItemWithPosition:(CGPoint)pos slideComposition:(SCSlideComposition *)slide
{
    for(SCSlideItemView *itemView in self.timelineContentView.subviews)
    {
        if(itemView.slideComposition == slide)
        {
            self.currentItem = itemView;
        }
    }
    [self selectItemToPreview:slide];
}

#pragma mark - util

- (SCSlideItemView*)itemWithSlide:(SCSlideComposition*)slide
{
    for(SCSlideItemView *item in self.timelineContentView.subviews)
    {
        if(item.slideComposition == slide)
        {
            return  item;
        }
    }
    return nil;
}

- (SCSlideItemView*)itemWithIndex:(int)index
{
    for(SCSlideItemView *item in self.timelineContentView.subviews)
    {
        if(item.index == index)
        {
            return  item;
        }
    }
    return nil;
}

- (void)updateAllPhotoPositionWithAnimation:(BOOL)animate
{
    for(SCSlideItemView *item in self.timelineContentView.subviews)
    {
        if(item != self.currentItem)
        {
            CGPoint position = [self  itemPositionFromIndex:item.index];
            if(animate)
            {
                item.isMoving = YES;
                [UIView animateWithDuration:0.3 animations:^
                 {
                     item.center = position;
                 }completion:^(BOOL finished) {
                     item.isMoving = NO;
                 }];
            }
            else
            {
                item.center = position;
            }
        }
    }
}

- (CGPoint)itemPositionFromIndex:(int)index
{
    CGPoint result = CGPointMake(0, 0);
    if(0 <= index && index  < self.slides.count)
    {
        result.x = index * SC_TIMELINE_ITEM_SIZE.width + SC_TIMELINE_ITEM_SIZE.width / 2;
        result.y = self.timelineContentView.frame.size.height / 2;
    }
    return result;
}

- (int)itemIndexFromPosition:(CGPoint)position
{
    int result = SC_GRIDVIEW_INVALID_INDEX;
    
    if(position.x >= 0 && position.x <= self.timelineContentView.frame.size.width)
    {
        result = position.x / SC_TIMELINE_ITEM_SIZE.width;
        NSLog(@"[positionX : %.2f ]",position.x);
        if(result < 0 || result >= self.slides.count)
            result = SC_GRIDVIEW_INVALID_INDEX;
        
    }
    return result;
}

- (void)selectItemToPreview:(SCSlideComposition*)slide
{
    [self.previewImgView setImage:slide.image];
    if(slide.currentScale > 1)
        [self.previewScrollView setZoomScale:slide.currentScale];
    else
        [self.previewScrollView setZoomScale:1];

    [self.previewScrollView setContentOffset:self.currentItem.slideComposition.relativeCroppedPos];

}

- (void)calculateSlideCropRect:(SCSlideComposition*)slide withVisibleRect:(CGRect)visibleRect scale:(float)scale
{
    NSLog(@"[offset pos : %@", NSStringFromCGPoint(visibleRect.origin));
    CGSize imgSize = slide.image.size;
    NSLog(@"[source image size : %@", NSStringFromCGSize(imgSize));
    float sizeRatio = imgSize.width >= imgSize.height ? (SC_CROP_PHOTO_SIZE.width /imgSize.width):((SC_CROP_PHOTO_SIZE.height / imgSize.height));
    slide.currentScale =  scale * sizeRatio;
    CGSize relativeImgSize = CGSizeMake(imgSize.width * sizeRatio, imgSize.height * sizeRatio);

    
    CGRect relativeRect = CGRectMake(visibleRect.origin.x/scale - (visibleRect.size.width/(2*scale)- relativeImgSize.width/2 ),
                                     visibleRect.origin.y/scale - (visibleRect.size.height/(2*scale) - relativeImgSize.height/2),
                                     visibleRect.size.width / scale,
                                     visibleRect.size.height / scale);
    NSLog(@"[scale : %.2f]", scale);
    
    NSLog(@"[Relative crop rect : %@]", NSStringFromCGRect(relativeRect));
    slide.currentScale = scale;
    if(scale <= 1)
    {
        slide.rectCropped = relativeRect;
        slide.currentScale = sizeRatio;
    }
    else
    {
        slide.rectCropped = CGRectMake(relativeRect.origin.x / sizeRatio,
                                       relativeRect.origin.y / sizeRatio,
                                       SC_CROP_PHOTO_SIZE.width/slide.currentScale/sizeRatio,
                                       SC_CROP_PHOTO_SIZE.height/slide.currentScale/sizeRatio
                                       );
    }
    NSLog(@"[image crop rect : %@]", NSStringFromCGRect(slide.rectCropped));
}


#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    
}

@end
