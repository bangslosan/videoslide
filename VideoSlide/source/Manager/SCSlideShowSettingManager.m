//
//  SCSettingManager.m
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSlideShowSettingManager.h"

static SCSlideShowSettingManager *instance;

@interface SCSlideShowSettingManager ()

- (void)updateDurationType:(SCVideoDurationType)videoDurationType;

@end

@implementation SCSlideShowSettingManager

@synthesize transitionsEnabled  = _transitionsEnabled;
@synthesize transitionDuration  = _transitionDuration;
@synthesize videoTotalDuration  = _videoTotalDuration;
@synthesize videoDurationType   = _videoDurationType;
@synthesize numberPhotos        = _numberPhotos;
@synthesize slideDuration       = _slideDuration;
@synthesize transitionType      = _transitionType;
@synthesize slideShowComposition = _slideShowComposition;
@synthesize clipboardTextObjectView = _clipboardTextObjectView;

- (id)init
{
    self = [super init];
    if(self)
    {
        _numberPhotos = 0;
        _transitionDuration = 0;
        _videoTotalDuration = 0;
        _slideDuration = 0;
        _transitionsEnabled = NO;
        _videoDurationType = SCVideoDurationTypeVine;
        _transitionType = SCVideoTransitionTypeNone;
        
    }
    return self;
}

+ (SCSlideShowSettingManager*)getInstance
{
    @synchronized([SCSlideShowSettingManager class])
    {
        if(!instance)
            instance = [[self alloc] init];
        return instance;
    }
    
    return nil;
    
}


#pragma  mark - get/set

- (void)setNumberOfPhotos:(int)number
{
    _numberPhotos = number;
    
    if([SCSlideShowSettingManager checkValidVineDuration:_numberPhotos])
    {
        [self updateDurationType:SCVideoDurationTypeVine];
    }
    else if([SCSlideShowSettingManager checkValidInstagramDuration:_numberPhotos])
    {
        [self updateDurationType:SCVideoDurationTypeInstagram];
        
    }
    else if([SCSlideShowSettingManager checkValidCustomDuration:_numberPhotos])
    {
        [self updateDurationType:SCVideoDurationTypeCustom];
    }

}


- (void)updateDurationType:(SCVideoDurationType)videoDurationType
{
    _videoDurationType = videoDurationType;
    switch (_videoDurationType)
    {
        case SCVideoDurationTypeVine:
            _videoTotalDuration = SC_VIDEO_VINE_DURATION;
            break;
            
        case SCVideoDurationTypeInstagram:
            _videoTotalDuration = SC_VIDEO_INSTAGRAM_DURATION;
            break;
            
        case SCVideoDurationTypeCustom:
            _videoTotalDuration = _numberPhotos;
            break;
            
        default:
            _videoTotalDuration = 0;
            break;
    }
    
    [self updateTimeWith:_numberPhotos videoTotalDuration:self.videoTotalDuration videoDurationType:self.videoDurationType];
}



#pragma instance methods

- (BOOL)canAddMoreSlide
{
    if(self.videoTotalDuration == SC_VIDEO_CUSTOM_MAX_DURATION || self.numberPhotos == 100)
        return NO;
    
    if(self.videoTotalDuration + self.slideDuration > SC_VIDEO_CUSTOM_MAX_DURATION)
        return NO;
    
    return YES;
}

- (BOOL)updateNumberPhoto:(int)numberPhotos andTotalDuration:(int)totalDuration
{
    if(numberPhotos != self.numberPhotos)
    {
        self.numberPhotos = numberPhotos;
        self.videoTotalDuration = totalDuration;
        self.videoDurationType = SCVideoDurationTypeCustom;
        if(numberPhotos == 1)
        {
            _transitionDuration = 0;
            self.transitionsEnabled = NO;
        }
        return YES;
    }
    else
        return NO;
}


- (BOOL)updateTimeWithoutTransition:(int)numberPhotos videoTotalDuration:(float)videoTotalDuration videoDurationType:(SCVideoDurationType)videoDurationType
{
    //if not valid for vine and instagram ---> reject update
    if(videoDurationType == SCVideoDurationTypeVine && ![SCSlideShowSettingManager checkValidVineDuration:videoTotalDuration])
        return NO;
    
    if(videoDurationType == SCVideoDurationTypeInstagram && ![SCSlideShowSettingManager checkValidInstagramDuration:videoTotalDuration])
        return NO;
    
    
    if([SCSlideShowSettingManager checkValidWith:numberPhotos videoTotalDuration:videoTotalDuration])
    {
        _numberPhotos = numberPhotos;
        _videoTotalDuration = videoTotalDuration;
        _videoDurationType = videoDurationType;
        
        //calculate to get the slide duration and slide transition
        _transitionDuration = 0;
        _transitionsEnabled = NO;
        _transitionType = SCVideoTransitionTypeNone;
        _slideDuration = (self.videoTotalDuration - _transitionDuration * (_numberPhotos -1 ) ) / _numberPhotos;
        //log to debug all parameter
        [self logToDebug];
        return YES;
    }
    
    return NO;

}

- (BOOL)updateTimeWith:(int)numberPhotos videoTotalDuration:(float)videoTotalDuration videoDurationType:(SCVideoDurationType)videoDurationType;
{
    
    //if not valid for vine and instagram ---> reject update
    if(videoDurationType == SCVideoDurationTypeVine && ![SCSlideShowSettingManager checkValidVineDuration:videoTotalDuration])
        return NO;
    
    if(videoDurationType == SCVideoDurationTypeInstagram && ![SCSlideShowSettingManager checkValidInstagramDuration:videoTotalDuration])
        return NO;
    
    
    if([SCSlideShowSettingManager checkValidWith:numberPhotos videoTotalDuration:videoTotalDuration])
    {
        _numberPhotos = numberPhotos;
        _videoTotalDuration = videoTotalDuration;
        _videoDurationType = videoDurationType;
        
        //calculate to get the slide duration and slide transition
        _transitionDuration = [self transitionDurationWith:_videoDurationType numberPhotos:_numberPhotos totalDuration:videoTotalDuration];
        if(_transitionDuration > 0)
        {
            _transitionsEnabled  = YES;
            _transitionType = SCVideoTransitionTypeDisolve;
        }
        else
        {
            _transitionsEnabled = NO;
            _transitionType = SCVideoTransitionTypeNone;
        }
        
        _slideDuration = (self.videoTotalDuration - _transitionDuration * (_numberPhotos -1 ) ) / _numberPhotos;
        //log to debug all parameter
        [self logToDebug];
        return YES;
    }
    
    return NO;
}

- (int)transitionDurationWith:(SCVideoDurationType)type numberPhotos:(int)number totalDuration:(float)duration;
{
    if(duration < number || number == 1)
        return SC_VIDEO_TRANSITION_DURATION_0;
    
    int transitionDuration = SC_VIDEO_TRANSITION_DURATION_0;
    switch (type)
    {
        case SCVideoDurationTypeVine: // there is no transition with this type
        {
            transitionDuration = SC_VIDEO_TRANSITION_DURATION_0;
        }
        break;
        case SCVideoDurationTypeInstagram://transition available only if number <= 5 photos
        {
            if(number <= SC_VIDEO_MINIMUM_SLIDE_DURATION_5)
                transitionDuration = SC_VIDEO_TRANSITION_DURATION_1;
            else
                transitionDuration = SC_VIDEO_TRANSITION_DURATION_0;
        }
        break;
        case SCVideoDurationTypeCustom: //custom video ---> check 1,3,5 cases
        {
            float slideDuration = duration / number;
            //  1 <= slideDuration < 3 --> transition duration = 0
            if(slideDuration >= SC_VIDEO_MINIMUM_SLIDE_DURATION_1 && slideDuration < SC_VIDEO_MINIMUM_SLIDE_DURATION_3)
                transitionDuration = SC_VIDEO_TRANSITION_DURATION_0;
            //  3 <= slideDuration < 5 --transition duration = 1
            else if(slideDuration >= SC_VIDEO_MINIMUM_SLIDE_DURATION_3 && slideDuration < SC_VIDEO_MINIMUM_SLIDE_DURATION_5)
                transitionDuration = SC_VIDEO_TRANSITION_DURATION_1;
            //  5 <= slideDuration  --t ransition duration = 2
            else if(slideDuration >= SC_VIDEO_MINIMUM_SLIDE_DURATION_5)
                transitionDuration = SC_VIDEO_TRANSITION_DURATION_2;
        }
        break;
            
        default:
            break;
    }
    
    return transitionDuration;
}



- (void)logToDebug
{
    NSLog(@" *********************** [Setting - DEBUG BEGIN ] ***********************");
    NSLog(@"[Setting - Total Duration] = [%f]", self.videoTotalDuration);
    NSLog(@"[Setting - Slide Duration] = [%f]", self.slideDuration);
    NSLog(@"[Setting - Total Slide]    = [%d]", self.numberPhotos);
    NSLog(@"[Setting - TransitionEnable] = [%d]", self.transitionsEnabled);
    NSLog(@"[Setting - Transition Duration] = [%d]", self.transitionDuration);
    NSLog(@" *********************** [Setting - DEBUG END ] ***********************");

}

/*- (void)setTransitionDuration:(int)transitionDuration
{
    transitionDuration = SC_VIDEO_TRANSITION_DURATION_1;
    switch (transitionDuration)
    {
        case SC_VIDEO_TRANSITION_DURATION_0:
        {
            _transitionDuration = SC_VIDEO_TRANSITION_DURATION_0;
            _transitionDuration = NO;
            _transitionsEnabled = NO;
        }
            break;
        case SC_VIDEO_TRANSITION_DURATION_1:
        {
            float retainTime = self.videoTotalDuration - SC_VIDEO_TRANSITION_DURATION_1 * (self.numberPhotos - 1);
            if(retainTime < (self.numberPhotos))
            {
                _transitionDuration = SC_VIDEO_TRANSITION_DURATION_0;
                _transitionsEnabled = NO;
            }
            else
            {
                _transitionDuration = SC_VIDEO_TRANSITION_DURATION_1;
                self.slideDuration = retainTime / self.numberPhotos;
                _transitionsEnabled = YES;
                
            }
        }
            break;
        case SC_VIDEO_TRANSITION_DURATION_2:
        {
            float retainTime = self.videoTotalDuration - SC_VIDEO_TRANSITION_DURATION_2 * (self.numberPhotos - 1);
            if(retainTime < (self.numberPhotos))
            {
                _transitionDuration = SC_VIDEO_TRANSITION_DURATION_0;
                _transitionsEnabled = NO;
            }
            else
            {
                _transitionDuration = SC_VIDEO_TRANSITION_DURATION_2;
                self.slideDuration = retainTime / self.numberPhotos;
                _transitionsEnabled = YES;
            }
        }
            break;
        default:
        {
            _transitionDuration = SC_VIDEO_TRANSITION_DURATION_0;
            _transitionsEnabled = NO;
        }
            break;
    }
}*/


#pragma mark - static methods

+ (BOOL)checkValidWith:(int)numberPhotos videoTotalDuration:(float)videoTotalDuration
{
    if(videoTotalDuration < numberPhotos)
        return NO;
    
    return YES;
}

+ (BOOL)checkValidVineDuration:(int)numberImage
{
    if(numberImage <= SC_VIDEO_VINE_DURATION)
        return YES;
    
    return NO;
}

+ (BOOL)checkValidInstagramDuration:(int)numberImage
{
    if(numberImage <= SC_VIDEO_INSTAGRAM_DURATION)
        return YES;
    
    return NO;
    
}

+ (BOOL)checkValidCustomDuration:(int)numberImage
{
    if(numberImage > 0)
        return YES;
    
    return NO;
    
}

@end
