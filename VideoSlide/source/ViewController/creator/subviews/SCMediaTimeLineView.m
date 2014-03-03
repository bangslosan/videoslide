//
//  SCMediaTimeLineView.m
//  SlideshowCreator
//
//  Created 10/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCMediaTimeLineView.h"

@interface SCMediaTimeLineView () <SCPhotoStripItemViewProtocol, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet SCMediaItemView *audioLineView;
@property (nonatomic, strong) IBOutlet SCMediaItemView *musicLineView;
@property (nonatomic, strong) IBOutlet UIView *imageStripView;
@property (nonatomic, strong) IBOutlet UIView *timeRulerView;
@property (nonatomic, strong) IBOutlet UIView *dynamicCursorView;
@property (nonatomic, strong) IBOutlet UIImageView *topImgLineView;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImgLineView;

@property (nonatomic, strong) IBOutlet UIButton *audioBtn;
@property (nonatomic, strong) IBOutlet UIButton *musiccBtn;

@property (nonatomic, strong) IBOutlet UILabel          *audioLb;
@property (nonatomic, strong) IBOutlet UILabel          *musicLb;
@property (nonatomic, strong) IBOutlet UILabel          *totalDurationLb;
@property (nonatomic, strong) SCMediaItemView *currentSelectedView;


@property (nonatomic, strong) NSMutableArray            *photos;
@property (nonatomic, strong) NSMutableArray            *photoPositions;
@property (nonatomic, strong) SCSlideShowComposition    *slideShow;
@property (nonatomic, strong) SCPhotoStripItemView      *currentItem;
@property (nonatomic) int     currentIndex;
@property (nonatomic, strong) UILongPressGestureRecognizer      *longGesture;
@property (nonatomic, strong) UIPanGestureRecognizer            *sortingPanGesture;

@property (nonatomic)         BOOL                              autoScrollActive;
@property (nonatomic, strong) NSTimer                           *autoScrollTimer;

- (void)updateView;
- (void)updateTime;

- (void)updateItemsIndex;
- (void)updateAllPhotoPositionWithAnimation:(BOOL)animate;
- (CGPoint)itemPositionFromIndex:(int)index;
- (int)itemIndexFromPosition:(CGPoint)position;

@end

@implementation SCMediaTimeLineView

@synthesize music  =_music;
@synthesize audioRecord = _audioRecord;
@synthesize delegate  =_delegate;
@synthesize realDuration = _realDuration;
@synthesize parentScrollView = _parentScrollView;

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

- (id)initWithComposition:(SCSlideShowComposition*)slideShow
{
    self  = [[[NSBundle mainBundle] loadNibNamed:@"SCMediaTimeLineView" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        self.slideShow = slideShow;
        [self setData:slideShow.slides];
        
        //init all array
        self.photos = [[NSMutableArray alloc] init];
        self.photoPositions = [[NSMutableArray alloc] init];
        self.autoScrollActive = NO;
    }
    
    return self;
}

- (void)awakeFromNib
{
    //create corner radius for music and audio strip
    self.audioLineView.layer.cornerRadius = 6;
    self.musicLineView.layer.cornerRadius = 6;
    self.layer.cornerRadius = 6;
    
    //don't clip subview within bouding
    //self.imageStripView.clipsToBounds = NO;
    self.clipsToBounds = NO;
    
    self.musicLineView.clipsToBounds = NO;
    self.audioLineView.clipsToBounds = NO;
    
    [self.dynamicCursorView setHidden:YES];
}

- (void)clearAll
{
    [super clearAll];
    for(UIView *view in self.timeRulerView.subviews)
    {
        [view removeFromSuperview];
    }

    if(self.photos.count > 0)
        [self.photos removeAllObjects];
    self.photos = nil;
    
    self.delegate = nil;
}

#pragma mark GestureRecognizer delegate
//////////////////////////////////////////////////////////////

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL valid = YES;
    if (gestureRecognizer == self.sortingPanGesture)
    {
        valid = (self.currentItem != nil && self.longGesture.enabled);
    }
    return valid;
}

#pragma mark - get/set

- (void)setParentScrollView:(UIScrollView *)parentScrollView
{
    _parentScrollView = parentScrollView;
    //init gesture
    if(!self.longGesture && !self.sortingPanGesture)
    {
        self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
        self.longGesture.minimumPressDuration = 0.5;
        [self.parentScrollView addGestureRecognizer:self.longGesture];
    }
    
    UITapGestureRecognizer *tapRecordGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMediaItemTapGesture:)];
    tapRecordGesture.numberOfTapsRequired = 2;
    [self.parentScrollView addGestureRecognizer:tapRecordGesture];
}
- (void)setData:(NSMutableArray *)data
{
    [self updateView];
}

- (CGSize)getSize
{
    return self.frame.size;
}

- (SCSlideComposition*)getCurrentSlideWithPosition:(CGPoint)pos
{
    int index = pos.x / SC_SLIDE_ITEM_SIZE.width;
    if(index < self.slideShow.slides.count)
    {
        SCSlideComposition *slide = [self.slideShow.slides objectAtIndex:index];
        return slide;
    }
    else if(index == self.slideShow.slides.count)
    {
        SCSlideComposition *slide = [self.slideShow.slides objectAtIndex:index - 1];
        return slide;
    }
    return nil;
}

- (SCPhotoStripItemView*)getCurrentSlideItemViewWithPosition:(CGPoint)pos
{
    int index = pos.x / SC_SLIDE_ITEM_SIZE.width;
    if(index < self.slideShow.slides.count)
    {
        SCSlideComposition *slide = [self.slideShow.slides objectAtIndex:index];
        for(SCPhotoStripItemView *itemView in self.imageStripView.subviews)
        {
            if(itemView.slideComposition == slide)
            {
                [self.imageStripView bringSubviewToFront:itemView];
                return itemView;
            }
        }
    }
    return nil;
}

- (SCPhotoStripItemView*)getSLideItemViewWith:(SCSlideComposition*)slide
{
    for(SCPhotoStripItemView *itemView in self.imageStripView.subviews)
    {
        if(itemView.slideComposition == slide)
        {
            return itemView;
        }
    }
    
    return nil;
}

- (float)getCurrentAudioRecordWidth
{
    NSLog(@"Audio record wdth [%.2f]",self.audioLineView.frame.size.width);
    return self.audioLineView.frame.size.width;
}


- (float)getCurrentAudioRecordBegin
{
    if(!self.audioLineView.hidden && self.audioLineView.frame.origin.x >=0 && self.audioLineView.frame.origin.x <= self.imageStripView.frame.size.width)
    {
        return self.audioLineView.frame.origin.x;
    }
    
    return 0;
}


#pragma mark - instance methods

- (void)updateTimeLineWith:(SCSlideShowComposition*)slideShow
{
    self.slideShow = slideShow;
    [self updateView];
}


- (void)deleteMusicBacground
{
    if(!self.musicLineView.hidden)
    {
        self.musicLineView.alpha = 1;
        [UIView animateWithDuration:0.4 animations:^
         {
             self.musicLineView.alpha = 0;
         }completion:^(BOOL finished) {
             [self.musicLineView setHidden:YES];
         }];
    }
}

- (void)deleteAudioRecord
{
    if(!self.audioLineView.hidden)
    {
        self.audioLineView.frame = CGRectMake(0, self.audioLineView.frame.origin.y, 0, self.audioLineView.frame.size.height);
        self.audioLineView.hidden = YES;
    }
}

- (void)createAudioRecordAt:(float)time
{
        self.audioLb.text = @"Recording...";
        [self.audioLineView setHidden:NO];
        self.audioLineView.frame = CGRectMake( time * self.frame.size.width / CMTimeGetSeconds(self.slideShow.totalDuration) , self.audioLineView.frame.origin.y, 0, self.audioLineView.frame.size.height);
}

- (void)updateAudioRecordViewWith:(float)duration
{
    if(duration > 0)
    {
        [self.audioLineView setHidden:NO];
        self.audioLineView.frame = CGRectMake(self.audioLineView.frame.origin.x,
                                              self.audioLineView.frame.origin.y,
                                              duration * self.frame.size.width / CMTimeGetSeconds(self.slideShow.totalDuration),
                                              self.audioLineView.frame.size.height);
        
        if(self.audioLineView.frame.origin.x + self.audioLineView.frame.size.width >= self.frame.size.width)
        {
            self.audioLineView.frame = CGRectMake(self.audioLineView.frame.origin.x,
                                                  self.audioLineView.frame.origin.y,
                                                  self.frame.size.width - self.audioLineView.frame.origin.x,
                                                  self.audioLineView.frame.size.height);
            if([self.delegate respondsToSelector:@selector(audioRecordReachToEndingTimeLine)])
            {
                [self.delegate audioRecordReachToEndingTimeLine];
            }
        }
    }
}

#pragma mark - private methods
- (void)updateItemsIndex
{
    int i = 0;
    for(SCSlideComposition *slide in self.slideShow.slides)
    {
        for(SCPhotoStripItemView *item in self.imageStripView.subviews)
        {
            if(item.slideComposition == slide)
            {
                item.index = i;
            }
        }
        i++;
    }
}
- (void)updateView
{
    //init all array
    for(SCPhotoStripItemView *photo in self.imageStripView.subviews)
    {
        [photo clearAll];
        [photo removeFromSuperview];
        photo.delegate = nil;
    }
    
    if(self.imageStripView.subviews.count == 0)
    {
        int i = 0;
        for(SCSlideComposition *slide in self.slideShow.slides)
        {
            SCPhotoStripItemView *item = [[SCPhotoStripItemView alloc]initWithFrame:CGRectMake(i*SC_SLIDE_ITEM_SIZE.width, 0, SC_SLIDE_ITEM_SIZE.width, SC_SLIDE_ITEM_SIZE.height) slide:slide];
            item.delegate = self;
            item.mainSuperView = self.mainSuperView;
            item.indexLb.text = [NSString stringWithFormat:@"%d",i];
            [self.imageStripView addSubview:item];
            i++;
        }
        //update view item index
        [self updateItemsIndex];
        //create item time line size
        [UIView animateWithDuration:0.3 animations:^
        {
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.imageStripView.subviews.count * SC_SLIDE_ITEM_SIZE.width, self.frame.size.height)];
            
        }completion:^(BOOL finished)
        {
        }];
    }
  
    //update music strip
    if(self.slideShow.musics.count > 0)
    {
        [self.musicLineView setHidden:NO];
        SCAudioComposition *audio = [self.slideShow.musics objectAtIndex:0];
        self.musicLb.text = audio.name;
        float startPoint = CMTimeGetSeconds(audio.startTimeInTimeline) * self.frame.size.width / CMTimeGetSeconds(self.slideShow.totalDuration);
        float width      = CMTimeGetSeconds(audio.timeRange.duration) * self.frame.size.width / CMTimeGetSeconds(self.slideShow.totalDuration);
        self.musicLineView.frame = CGRectMake(startPoint,
                                              self.musicLineView.frame.origin.y,
                                              width,
                                              self.musicLineView.frame.size.height);
        self.musicLineView.lastPosition = self.musicLineView.center;
        NSLog(@"[Music duration] %f",CMTimeGetSeconds(audio.timeRange.duration));
    }
    else
    {
        self.musicLineView.hidden  = YES;
    }
    //update audio strip
    if(self.slideShow.audios.count > 0)
    {
        SCAudioComposition *audio = [self.slideShow.audios objectAtIndex:0];
        self.audioLb.text = @"Record Audio";//audio.title;
        //update position
        float startPoint = CMTimeGetSeconds(audio.startTimeInTimeline) * self.frame.size.width / CMTimeGetSeconds(self.slideShow.totalDuration);
        float width      = CMTimeGetSeconds(audio.timeRange.duration) * self.frame.size.width / CMTimeGetSeconds(self.slideShow.totalDuration);
        
        self.audioLineView.frame = CGRectMake(startPoint,
                                              self.audioLineView.frame.origin.y,
                                              width,
                                              self.audioLineView.frame.size.height);
        self.audioLineView.lastPosition = self.audioLineView.center;
        self.audioLineView.hidden = NO;
    }
    else
    {
        self.audioLineView.hidden = YES;
    }
    [self updateTime];
}

- (void)updateTime
{
    //set total duration time label
    self.realDuration = CMTimeGetSeconds(self.slideShow.totalDuration);
    if(self.realDuration - (int)self.realDuration >= 0.5)
        self.realDuration = (int)self.realDuration + 1;
    self.totalDurationLb.text = [NSString stringWithFormat:@"%ds",(int)self.realDuration];
    
    //1. Remove all old time stamp label
    if(self.timeRulerView.subviews.count > 0)
    {
        for(UILabel *label in self.timeRulerView.subviews)
        {
            [label removeFromSuperview];
        }
    }
    
    //2. create time point ruler with UILable View
    float widthForUnitTime = self.timeRulerView.frame.size.width / self.realDuration;
    int delta = 10;
    float width = widthForUnitTime * delta ;
    while(width < SC_SLIDE_ITEM_SIZE.width)
    {
        delta += 5;
        width = widthForUnitTime * delta;
    }
    int stampCount = self.realDuration / delta;
    if(stampCount >= 1)
    {
        for (int i = 0;i < stampCount;i++)
        {
            UILabel *timeStampLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SC_TIME_RULER_POINT_SIZE.width, SC_TIME_RULER_POINT_SIZE.height)];
            timeStampLb.text = [NSString stringWithFormat:@"%ds", (i + 1)*delta];
            [timeStampLb sizeToFit];
            timeStampLb.center = CGPointMake((i + 1)*width - timeStampLb.frame.size.width/2, self.timeRulerView.frame.size.height / 2);
            [timeStampLb setFont:[UIFont fontWithName:@"Helvetica" size:12]];
            [timeStampLb setTextAlignment:NSTextAlignmentLeft];
            [timeStampLb setBackgroundColor:[UIColor clearColor]];
            [timeStampLb setTextColor:[UIColor blackColor]];
            [self.timeRulerView addSubview:timeStampLb];
        }
    }
}

#pragma mark - double tap gesture recognize handler

- (void)handleMediaItemTapGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint locationInView = [gesture locationInView:self];
        if((CGRectContainsPoint(self.musicLineView.frame, locationInView) && !self.musicLineView.isHidden)
        || (CGRectContainsPoint(self.audioLineView.frame, locationInView) && !self.audioLineView.isHidden))
        {
            BOOL selectMusicLine = CGRectContainsPoint(self.musicLineView.frame, locationInView);
            if(selectMusicLine)
            {
                if([self.delegate respondsToSelector:@selector(startEditMusicTrack)])
                    [self.delegate startEditMusicTrack];
            }
            else
                if([self.delegate respondsToSelector:@selector(startEditAudioRecordTrack)])
                    [self.delegate startEditAudioRecordTrack];

        }
    }
}


#pragma mark - action + sorting + delete

- (void)onPress:(UILongPressGestureRecognizer *)gesture
{
    //checl if there is only 1 photo strip --> do not allow to press
    if(self.slideShow.slides.count == 1)
        return;
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint locationInView = [self.longGesture locationInView:self];
        if(CGRectContainsPoint(self.imageStripView.frame, locationInView))
        {
            CGPoint locationInPhotoStrip = [self.longGesture locationInView:self.imageStripView];
            int index = [self itemIndexFromPosition:locationInPhotoStrip];
            if(index != SC_GRIDVIEW_INVALID_INDEX)
            {
                self.currentItem = [self itemWithIndex:index];
                self.currentItem.index = SC_GRIDVIEW_INVALID_INDEX;
                self.currentIndex = index;

                CGRect frameInMainView = [self convertRect:self.currentItem.frame toView:self.parentScrollView.superview];
                [self.currentItem removeFromSuperview];
                self.currentItem.frame = frameInMainView;
                [self.parentScrollView.superview addSubview:self.currentItem];

                [self.currentItem beginWithGesture:gesture zoom:YES moveUp:NO completion:^
                 {
                     _autoScrollActive = YES;
                     [self autoScrollWithGesture:self.longGesture];
                     if([self.delegate respondsToSelector:@selector(startSorting)])
                     {
                         [self.delegate startSorting];
                     }
                     
                 }];
                NSLog(@"start move slide item");
            }
        }
        else if((CGRectContainsPoint(self.musicLineView.frame, locationInView) && !self.musicLineView.isHidden)
                || (CGRectContainsPoint(self.audioLineView.frame, locationInView) && !self.audioLineView.isHidden))
        {
            
            BOOL selectMusicLine = CGRectContainsPoint(self.musicLineView.frame, locationInView);
            self.currentSelectedView = selectMusicLine ? self.musicLineView : self.audioLineView;

            CGRect frameInMainView = [self convertRect:self.currentSelectedView.frame toView:self.parentScrollView.superview];
            [self.currentSelectedView removeFromSuperview];
            self.currentSelectedView.frame = frameInMainView;
            [self.parentScrollView.superview addSubview:self.currentSelectedView];
            
            //show align view
            self.dynamicCursorView.backgroundColor = self.currentSelectedView.backgroundColor;
            CGPoint currentPosition = [self convertPoint:self.currentSelectedView.frame.origin fromView:self.currentSelectedView.superview];
            if(currentPosition.x >= 0 && currentPosition.x <= self.frame.size.width)
            {
                self.dynamicCursorView.hidden  = NO;
                self.dynamicCursorView.frame = CGRectMake(currentPosition.x, 0, self.dynamicCursorView.frame.size.width, self.dynamicCursorView.frame.size.height);
            }
            else
                self.dynamicCursorView.hidden  = YES;

            [self.currentSelectedView beginWithGesture:gesture zoom:NO moveUp:YES completion:^
             {
                 _autoScrollActive = YES;
                 [self autoScrollWithGesture:self.longGesture];
                 if([self.delegate respondsToSelector:@selector(startSorting)])
                     [self.delegate startSorting];
                 
                 CGPoint locationInView = [self convertPoint:self.currentSelectedView.frame.origin fromView:self.currentSelectedView.superview];
                 self.dynamicCursorView.frame = CGRectMake(locationInView.x, 0, self.dynamicCursorView.frame.size.width, self.dynamicCursorView.frame.size.height);
                 [self.dynamicCursorView.superview bringSubviewToFront:self.dynamicCursorView];

             }];
            NSLog(@"start move slide item");
            _autoScrollActive = YES;
            [self autoScrollWithGesture:self.longGesture];
            NSLog(@"start move media line view");
        }
    }
    else if(gesture.state == UIGestureRecognizerStateChanged)
    {
        if(self.currentItem && !self.currentSelectedView)
        {
            [self.currentItem updateWithGesture:self.longGesture];
            [self selectedItemChangePositionWith:self.longGesture];
        }
        else if(!self.currentItem && self.currentSelectedView)
        {
            [self.currentSelectedView updateWithGesture:self.longGesture];
            CGPoint locationInView = [self convertPoint:self.currentSelectedView.frame.origin fromView:self.currentSelectedView.superview];
            if(locationInView.x >= 0 && locationInView.x <= self.frame.size.width)
            {
                self.dynamicCursorView.hidden  = NO;
                self.dynamicCursorView.frame = CGRectMake(locationInView.x, 0, self.dynamicCursorView.frame.size.width, self.dynamicCursorView.frame.size.height);
            }
            else
                self.dynamicCursorView.hidden  = YES;
        }
    }
    else if(gesture.state == UIGestureRecognizerStateEnded
            || gesture.state == UIGestureRecognizerStateCancelled
            || gesture.state == UIGestureRecognizerStateFailed )
    {
        if(self.currentItem && !self.currentSelectedView)
        {
            CGPoint positionView = [self convertPoint:self.currentItem.center fromView:self.currentItem.superview];
            [self.currentItem removeFromSuperview];
            [self.imageStripView addSubview:self.currentItem];
            self.currentItem.center = positionView;

            if(self.currentItem && self.currentIndex >= 0 && self.currentIndex < self.slideShow.slides.count)
            {
                self.currentItem.lastPosition = [self itemPositionFromIndex:self.currentIndex];
                self.currentItem.index = self.currentIndex;
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
                 self.currentItem = nil;
             }];
        }
        else if(!self.currentItem && self.currentSelectedView)
        {
            self.dynamicCursorView.hidden  = YES;
            CGPoint positionView = [self convertPoint:self.currentSelectedView.center fromView:self.currentSelectedView.superview];
            [self.currentSelectedView removeFromSuperview];
            [self addSubview:self.currentSelectedView];
            self.currentSelectedView.center = positionView;
            
            float startTime = 0;
            SCAudioComposition *audio ;
            audio = self.currentSelectedView == self.musicLineView ?  [self.slideShow.musics objectAtIndex:0] : [self.slideShow.audios objectAtIndex:0];
            startTime = self.currentSelectedView.frame.origin.x;
            self.currentSelectedView.lastPosition = CGPointMake(self.currentSelectedView.center.x, self.currentSelectedView.lastPosition.y);

           /* if(self.currentSelectedView.frame.origin.x + self.currentSelectedView.frame.size.width > self.frame.size.width)
            {
                self.currentSelectedView.lastPosition = CGPointMake(self.frame.size.width - self.currentSelectedView.frame.size.width/2, self.currentSelectedView.lastPosition.y);
                startTime = (self.frame.size.width - self.currentSelectedView.frame.size.width);
            }
            else if(self.currentSelectedView.frame.origin.x < 0)
            {
                self.currentSelectedView.lastPosition = CGPointMake(self.currentSelectedView.frame.size.width / 2, self.currentSelectedView.lastPosition.y);
                startTime = 0;
            }*/
            startTime = startTime * CMTimeGetSeconds(self.slideShow.totalDuration) / self.frame.size.width;
            audio.startTimeInTimeline = CMTimeMake(startTime * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
            [self.currentSelectedView endWithGesture:gesture completion:^
             {
                 if(self.currentSelectedView.markDelete)
                 {
                     [self didDeleteCurrentMediaItem];
                     self.currentSelectedView.center = CGPointMake(self.currentSelectedView.center.x, self.currentSelectedView.lastPosition.y);
                 }
                 else
                 {
                     [self didEndSorting];
                 }
                 self.currentSelectedView = nil;
             }];
        }
        _autoScrollActive = NO;
        self.dynamicCursorView.hidden  = YES;
        [self stopAutoScroll];
        NSLog(@"End move");
    }
}

- (void)sortingPanGestureUpdated:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            _autoScrollActive = NO;
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            _autoScrollActive = YES;
            [self autoScrollWithGesture:self.sortingPanGesture];
            NSLog(@"start move");
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if(self.currentItem.isMoving)
            {
                NSLog(@"moving");
                [self.currentItem updateWithGesture:self.sortingPanGesture];
                [self selectedItemChangePositionWith:self.sortingPanGesture];
            }
            break;
        }
        default:
            break;
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
        CGPoint locationInMainView = [self.longGesture locationInView:self.parentScrollView];
        locationInMainView = CGPointMake(locationInMainView.x - self.parentScrollView.contentOffset.x,
                                         locationInMainView.y -self.parentScrollView.contentOffset.y
                                         );
        CGPoint offset = self.parentScrollView.contentOffset;
        
        CGFloat threshhold = SC_SLIDE_ITEM_SIZE.width;
        // Going right
        if (locationInMainView.x + threshhold > self.parentScrollView.bounds.size.width)
        {
            self.parentScrollView.contentOffset = CGPointMake(self.parentScrollView.contentOffset.x + DELTA_TIME * SC_SLIDE_ITEM_SIZE.width * 2, self.parentScrollView.contentOffset.y);
            if (self.parentScrollView.contentOffset.x > self.parentScrollView.contentSize.width - self.parentScrollView.frame.size.width)
            {
                self.parentScrollView.contentOffset = CGPointMake(self.parentScrollView.contentSize.width - self.parentScrollView.frame.size.width, self.parentScrollView.contentOffset.y);
            }
        }
        // Going left
        else if (locationInMainView.x - threshhold < 0 )
        {
            self.parentScrollView.contentOffset = CGPointMake(self.parentScrollView.contentOffset.x - DELTA_TIME * SC_SLIDE_ITEM_SIZE.width *  2, self.parentScrollView.contentOffset.y);
            if (self.parentScrollView.contentOffset.x < 0)
            {
                self.parentScrollView.contentOffset = CGPointMake(0, self.parentScrollView.contentOffset.y);
            }
        }
        if(offset.x != self.parentScrollView.contentOffset.x)
        {
            if(self.currentItem)
            {
                [self.currentItem updateWithGesture:self.longGesture];
                [self selectedItemChangePositionWith:self.longGesture];
            }
            else if(self.currentSelectedView)
            {
                [self.currentSelectedView updateWithGesture:self.longGesture];
                CGPoint locationInView = [self convertPoint:self.currentSelectedView.frame.origin fromView:self.currentSelectedView.superview];
                if(locationInView.x >= 0 && locationInView.x <= self.frame.size.width)
                {
                    self.dynamicCursorView.frame = CGRectMake(locationInView.x, 0, self.dynamicCursorView.frame.size.width, self.dynamicCursorView.frame.size.height);
                }
                else
                    self.dynamicCursorView.hidden  = YES;
            }
        }
    }
}


- (void)selectedItemChangePositionWith:(UIGestureRecognizer*)gesture
{
    CGPoint locationInImageStripView = [gesture locationInView:self];
    int nextItemIndex = [self itemIndexFromPosition:locationInImageStripView];
    if(nextItemIndex != self.currentIndex  && nextItemIndex != SC_GRIDVIEW_INVALID_INDEX)
    {
        SCPhotoStripItemView *item = [self itemWithIndex:nextItemIndex];
        if(item != self.currentItem && item.index != self.currentIndex)
        {
            NSLog(@"[Current Index [%d]]", self.currentIndex);
            NSLog(@"[Next index [%d]", nextItemIndex);
            item.index = self.currentIndex;
            //item.center = [self itemPositionFromIndex:item.index];
            [item updateWith:[self itemPositionFromIndex:item.index] index:self.currentIndex];
            
            //update slide show + video index
            int lastIndex = [self.slideShow.slides indexOfObject:self.currentItem.slideComposition];
            int newIndex = [self.slideShow.slides indexOfObject:item.slideComposition];
            SCVideoComposition *videoItem = [self.slideShow.videos objectAtIndex:lastIndex];
            
            [self.slideShow.slides removeObjectAtIndex:lastIndex];
            [self.slideShow.slides insertObject:self.currentItem.slideComposition atIndex:newIndex];
            
            [self.slideShow.videos removeObjectAtIndex:lastIndex];
            [self.slideShow.videos insertObject:videoItem atIndex:newIndex];
            self.currentIndex = nextItemIndex;
        }
    }
}

- (void)didEndSorting
{
    // notice to finish sorting
    if([self.delegate respondsToSelector:@selector(didFinishSortingSlideShow)])
    {
        [self.delegate didFinishSortingSlideShow];
    }
}

- (void)didDeleteCurrentSlideItem
{
    //remove slide /video from global array
    if(self.currentItem)
    {
        [self.slideShow deleteSlideComposition:self.currentItem.slideComposition];
        [self.currentItem removeFromSuperview];
        [self.currentItem clearAll];
    }
    //auto arrange other slides
    for(SCPhotoStripItemView *itemView in self.imageStripView.subviews)
    {
        if(itemView.index > self.currentIndex)
            itemView.index --;
    }
    
    [UIView animateWithDuration:0.3 animations:^
    {
        for(SCPhotoStripItemView *itemView in self.imageStripView.subviews)
        {
            itemView.center = [self itemPositionFromIndex:itemView.index];
            itemView.lastPosition = itemView.center;
        }

    }completion:^(BOOL finished) {
        if([self.delegate respondsToSelector:@selector(didFinishDeletePhotoItemInSlideShow)])
           [self.delegate didFinishDeletePhotoItemInSlideShow];
        self.currentItem = nil;
        self.currentIndex = SC_GRIDVIEW_INVALID_INDEX;
    }];
}

- (void)didDeleteCurrentMediaItem
{
    if(self.currentSelectedView)
    {
        [self.currentSelectedView setHidden:YES];
        if(self.currentSelectedView == self.musicLineView && self.slideShow.musics.count > 0)
        {
            [self.slideShow.musics removeAllObjects];
        }
        else if(self.currentSelectedView == self.audioLineView && self.slideShow.audios.count > 0)
        {
            [self.slideShow.audios removeAllObjects];
        }
    }
    if([self.delegate respondsToSelector:@selector(didFinishDeleteMediaItemInSlideShow)])
        [self.delegate didFinishDeleteMediaItemInSlideShow];

}


#pragma mark - on tap slide
- (void)didSelectItemWithPosition:(CGPoint)pos slideComposition:(SCSlideComposition *)slide
{
    NSLog(@"[Select Photo at index [%.2f][%.2f]]",pos.x,pos.y);
    [self.delegate didSelectPhotoItemAtPos:pos andSlide:slide];
}



#pragma mark - util

- (SCPhotoStripItemView*)itemWithIndex:(int)index
{
    for(SCPhotoStripItemView *item in self.imageStripView.subviews)
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
    for(SCPhotoStripItemView *item in self.imageStripView.subviews)
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
    if(0 <= index && index  < self.slideShow.slides.count)
    {
        result.x = index * SC_SLIDE_ITEM_SIZE.width + SC_SLIDE_ITEM_SIZE.width / 2;
        result.y = self.imageStripView.frame.size.height / 2;
    }
    return result;
}

- (int)itemIndexFromPosition:(CGPoint)position
{
    int result = SC_GRIDVIEW_INVALID_INDEX;
    
    if(position.x >= 0 && position.x <= self.imageStripView.frame.size.width)
    {
        result = position.x / SC_SLIDE_ITEM_SIZE.width;
        NSLog(@"[positionX : %.2f ]",position.x);
        if(result < 0 || result >= self.slideShow.slides.count)
            result = SC_GRIDVIEW_INVALID_INDEX;
            
    }
    return result;
}


@end



