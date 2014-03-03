//
//  SCMediaItemView.m
//  SlideshowCreator
//
//  Created 12/3/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//


#import "SCMediaItemView.h"

@interface SCMediaItemView ()

@property (nonatomic, strong) UIImageView *deleteEffectImgView;
@property (nonatomic)          BOOL        zoomWhenMoving;
@property (nonatomic)          BOOL        upWhenMoving;
@property (nonatomic)          float       deltaX;


@end

@implementation SCMediaItemView

@synthesize isMoving= _isMoving;
@synthesize markDelete = _markDelete;
@synthesize isSelected = _isSelected;
@synthesize lastPosition = _lastPosition;

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


#pragma mark - actions

- (void)updateWithGesture:(UIGestureRecognizer*)gesture
{
    CGPoint realLocation = [gesture locationInView:gesture.view];
    CGPoint locationInScroll = [gesture locationInView:self.superview];
    if(self.upWhenMoving)
    {
        self.centerX = locationInScroll.x + self.deltaX;
        self.centerY = locationInScroll.y - 20;
    }
    else
        self.center = CGPointMake(locationInScroll.x, locationInScroll.y - 20);
    //move your views here.
    if(realLocation.y > 0)
    {
        //check bounding
        [self hideDeleteWarning];
    }
    else
    {
        [self showDeleteWarning];
    }
}

- (void)beginWithGesture:(UIGestureRecognizer*)gesture zoom:(BOOL)zoom moveUp:(BOOL)moveUp completion:(void (^)(void))completion
{
    CGPoint locationInScroll = [gesture locationInView:self.superview];

    self.zoomWhenMoving = zoom;
    self.upWhenMoving = moveUp;
    self.layer.shadowOpacity = 0.7;
    //bring this item to top of all superview's subviews
    [self.superview bringSubviewToFront:self];
    //set photo strip go with gesture location
    [UIView animateWithDuration:SCDefaultAnimationDuration animations:^{
        if(zoom)
            self.transform = CGAffineTransformMakeScale(1.2, 1.2);
        if(moveUp)
        {
            self.centerY = locationInScroll.y - 20;
            self.deltaX = self.centerX - locationInScroll.x;
        }
        else
        {
            self.center = CGPointMake(locationInScroll.x, locationInScroll.y - 20);
        }
    }
    completion:^(BOOL finished)
     {
         self.isMoving = YES;
         completion();
     }];
}

- (void)endWithGesture:(UIGestureRecognizer*)gesture completion:(void (^)(void))completion
{
    self.isMoving = NO;
    self.layer.shadowOpacity = 0;
    CGPoint realLocation = [gesture locationInView:gesture.view];
    if(realLocation.y > 0)
    {
        self.markDelete = NO;
        [UIView animateWithDuration:SCDefaultAnimationDuration animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
            self.center = self.lastPosition;
        } completion:^(BOOL finished)
         {
             completion();
         }];
    }
    else
    {
        self.markDelete = YES;
        self.alpha = 0;
        [self deleteAnimation];
        [UIView animateWithDuration:SCDefaultAnimationDuration animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished){
            [self hideDeleteWarning];
            completion();
            self.alpha = 1;
        }];
    }
}


- (void)finishDelete
{
}

#pragma mark - delete aniamtion

- (void)showDeleteWarning
{
    if(self.deleteEffectImgView.superview)
    {
        [self.deleteEffectImgView removeFromSuperview];
        self.deleteEffectImgView = nil;
    }
    self.deleteEffectImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-15, -15, 42, 52)];
    [self.deleteEffectImgView setImage:[UIImage imageNamed:@"poof1.png"]];
    [self addSubview:self.deleteEffectImgView];
    [self bringSubviewToFront:self.deleteEffectImgView];
    self.clipsToBounds = NO;
}

- (void)hideDeleteWarning
{
    if(self.deleteEffectImgView.superview)
    {
        [self.deleteEffectImgView stopAnimating];
        [self.deleteEffectImgView removeFromSuperview];
        self.deleteEffectImgView = nil;
    }
}

- (void)deleteAnimation
{
    if(self.deleteEffectImgView.superview)
    {
        [self.deleteEffectImgView removeFromSuperview];
        self.deleteEffectImgView = nil;
    }
    int i = 1;
    NSMutableArray *images = [[NSMutableArray alloc]init];
    
    while (i <= 5)
    {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"poof%d.png",i]];
        if(image)
        {
            [images addObject:image];
            i++;
        }
    }
    
    self.deleteEffectImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 52)];
    self.deleteEffectImgView.animationImages = images;
    self.deleteEffectImgView.animationRepeatCount = 0;
    self.deleteEffectImgView.animationDuration = SC_VIEW_ANIMATION_DURATION;
    if(self.superview)
    {
        self.deleteEffectImgView.center = self.center;
        [self.superview addSubview:self.deleteEffectImgView];
        self.deleteEffectImgView.alpha = 1;
    }
    else
    {
        self.deleteEffectImgView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self addSubview:self.deleteEffectImgView];
        self.deleteEffectImgView.alpha = 1;
    }
    [self.deleteEffectImgView startAnimating];
    
}



@end
