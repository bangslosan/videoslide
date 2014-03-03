//
//  SCTransitionComposition.m
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTransitionComposition.h"

@implementation SCTransitionComposition

@synthesize model = _model;
@synthesize type = _type;
@synthesize direction = _direction;

#pragma mark -  init section
- (id)init
{
    self = [super init];
    if(self)
    {
        self.type = SCVideoTransitionTypeNone;
		self.timeRange = kCMTimeRangeInvalid;
        self.model  = [[SCTransitionModel alloc]init];
    }
    
    return  self;
}

- (id)initWithType:(SCVideoTransitionType)type duration:(float)duration
{
    self = [super init];
    if(self)
    {
        self.type = type;
        self.model  = [[SCTransitionModel alloc]init];
        self.duration = CMTimeMake(duration * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
    }
    return  self;

}

+ (id)videoTransition
{
	return [[SCTransitionComposition alloc] init];
}

- (id)initWithModel:(SCCompositionModel *)model
{
    self = [super initWithModel:model];
    if(self)
    {
        if([model isKindOfClass:[SCTransitionModel class]])
        {
            self.model = (SCTransitionModel*)model;
            [self getInfoFromModel];
        }
    }
    
    return self;
}


#pragma mark - save/load process

- (void)updateModel
{
    [self clearModel];
    self.model.type = self.type;
    self.model.name = self.name;
    self.model.startTime = CMTimeGetSeconds(self.startTimeInTimeline);
    self.model.duration  = CMTimeGetSeconds(self.duration);
}

- (void)getInfoFromModel
{
    self.type = self.model.type;
    self.startTimeInTimeline = CMTimeMake(self.model.startTime * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
    self.duration = CMTimeMake(self.model.duration * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);

}


- (void)clearModel
{
    if(self.model)
    {
        [self.model clearAll];
        self.model = nil;
    }
    
    self.model = [[SCTransitionModel alloc] init];
}


#pragma mark - static for create new template of transition

+ (id)fadeInTransitionWithDuration:(float)duration {
	SCTransitionComposition *transition = [[self alloc]initWithType:SCVideoTransitionTypeFadeIn duration:duration];

	return transition;
}

+ (id)fadeOutTransitionWithDuration:(float)duration
{
    SCTransitionComposition *transition = [[self alloc]initWithType:SCVideoTransitionTypeFadeOut duration:duration];
	return transition;
}

+ (id)disolveTransitionWithDuration:(float)duration
{
    SCTransitionComposition *transition = [[self alloc]initWithType:SCVideoTransitionTypeDisolve duration:duration];
	return transition;
}

+ (id)pushTransitionWithDuration:(float)duration direction:(SCPushTransitionDirection)direction
{
    SCTransitionComposition *transition = [[self alloc]initWithType:SCVideoTransitionTypePush duration:duration];
	transition.direction = direction;
	return transition;
}

+ (id)zoomTransitionWithDuration:(float)duration
{
    SCTransitionComposition *transition = [[self alloc]initWithType:SCVideoTransitionTypeZoomIn duration:duration];
	return transition;
}



- (void)setDirection:(SCPushTransitionDirection)direction {
	if (self.type == SCVideoTransitionTypePush) {
		_direction = direction;
	} else {
		_direction = SCPushTransitionDirectionInvalid;
		NSAssert(NO, @"Direction can only be specified for a type == THVideoTransitionTypePush.");
	}
}

#pragma mark - clear all
- (void)clearAll
{
    [super clearAll];
    self.model  = nil;
}


@end
