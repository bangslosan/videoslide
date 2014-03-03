//
//  SCSlideItemView.m
//  VideoSlide
//
//  Created by Thi Huynh on 2/14/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCSlideItemView.h"

@interface SCSlideItemView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView                       *photoImgView;
@property (nonatomic, strong) UITapGestureRecognizer            *tapGesture;


@end
@implementation SCSlideItemView

@synthesize slideComposition = _slideComposition;
@synthesize delegate = _delegate;
@synthesize index = _index;

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


- (id)initWithFrame:(CGRect)frame slide:(SCSlideComposition*)slideComposition;
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        self.slideComposition = slideComposition;
        self.isSelected = NO;
        self.isMoving = NO;
        self.markDelete = NO;
        self.lastPosition = self.center;
        
        if(self.slideComposition.thumbnailImage)
        {
            self.photoImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width , self.bounds.size.height)];
            if(self.slideComposition.filterComposition.thumbnailFilteredImage && self.slideComposition.filterComposition.filterMode != SCImageFilterModeNormal)
                [self.photoImgView setImage:self.slideComposition.filterComposition.thumbnailFilteredImage];
            else
                [self.photoImgView setImage:self.slideComposition.thumbnailImage];
            [self addSubview:self.photoImgView];
        }
        
        //create index label
        self.indexLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height / 2)];
        self.indexLb.backgroundColor = [UIColor whiteColor];
        self.indexLb.textColor = [UIColor redColor];
        [self.indexLb setFont:[UIFont fontWithName:@"Helvetica Neue Bold" size:12]];
        self.indexLb.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        //[self addSubview:self.indexLb];
        //init getsture
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        self.tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.tapGesture];
    }
    return self;
}

#pragma get/set

- (void)setMainSuperView:(UIView *)mainSuperView
{
    [super setMainSuperView:mainSuperView];
}

- (void)setIndex:(int)index
{
    _index = index;
    self.indexLb.text = [NSString stringWithFormat:@"%d",_index];
    
}

#pragma mark - instance methods
- (void)updateWith:(CGPoint)pos index:(int)index
{
    //_index = index;
    self.isMoving = YES;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:SCDefaultAnimationOptions
                     animations:^
     {
         self.center = pos;
     }
                     completion:^(BOOL finished)
     {
         self.lastPosition = self.center;
         self.isMoving = NO;
         
     }];
}

- (void)refreshPhoto
{
    if(self.slideComposition.thumbnailImage)
    {
        if(self.slideComposition.filterComposition.thumbnailFilteredImage && self.slideComposition.filterComposition.filterMode != SCImageFilterModeNormal)
            [self.photoImgView setImage:self.slideComposition.filterComposition.thumbnailFilteredImage];
        else
            [self.photoImgView setImage:self.slideComposition.thumbnailImage];
    }
    
}

#pragma mark - gesture

- (void)onTap:(UITapGestureRecognizer *)gesture
{
    if([self.delegate respondsToSelector:@selector(didSelectItemWithPosition:slideComposition:)])
    {
        [self.delegate didSelectItemWithPosition:self.center slideComposition:self.slideComposition];
    }
}


#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    [self removeGestureRecognizer:self.tapGesture];
    
    self.delegate = nil;
    if(self.slideComposition)
    {
        self.slideComposition = nil;
    }
    
}



@end
