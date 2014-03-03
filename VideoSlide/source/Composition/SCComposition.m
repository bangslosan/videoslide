//
//  SCComposition.m
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCComposition.h"

@implementation SCComposition
@synthesize duration = _duration;
@synthesize timeRange = _timeRange;
@synthesize startTimeInTimeline = _startTimeInTimeline;
@synthesize endTimeInTimeline = _endTimeInTimeline;
@synthesize needToUpdate      = _needToUpdate;
@synthesize markDelete     = _markDelete;
@synthesize name              = _name;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.timeRange = kCMTimeRangeInvalid;
        self.duration = kCMTimeInvalid;
		self.startTimeInTimeline = kCMTimeInvalid;
        self.endTimeInTimeline = kCMTimeInvalid;
        self.needToUpdate = NO;
        self.markDelete = NO;
        self.name = nil;

    }
    
    return self;
}

- (id)initWithModel:(SCCompositionModel*)model
{
    self = [self init];
    if(self)
    {
        self.startTimeInTimeline = CMTimeMake(model.startTimeInTimeLine * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.duration = CMTimeMake(model.duration * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.timeRange = CMTimeRangeMake(CMTimeMake(model.startTime*SC_VIDEO_OUTPUT_FPS , SC_VIDEO_OUTPUT_FPS), self.duration);
        self.endTimeInTimeline = kCMTimeInvalid;
        self.name = model.name;

    }
    
    return self;
}

#pragma mark - derive methods

- (void)updateModel
{
    
}

- (void)getInfoFromModel
{
    
}

- (void)clearModel
{
    
}


#pragma mark - release methods for arc
- (void)clearAll
{
    
}


@end
