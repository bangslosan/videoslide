//
//  SCCompositionModel.m
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCompositionModel.h"

@implementation SCCompositionModel

@synthesize duration = _duration;
@synthesize name = _name;
@synthesize startTime = _startTime;
@synthesize projectURL = _projectURL;
@synthesize startTimeInTimeLine = _startTimeInTimeLine;

- (id)init
{
    self = [super init];
    if(self)
    {
        _name = @"";
        _startTime = 0;
        _duration = 0;
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if(self)
    {
        self.duration = [dict floatForKey:@"duration"];
        self.startTime = [dict floatForKey:@"startTime"];
        self.startTimeInTimeLine = [dict floatForKey:@"startTimeInTimeLine"];

        self.name      = [dict valueForKey:@"name"];
        self.projectURL      = [dict valueForKey:@"projectURL"];

    }
    
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dict = [super toDictionary];
    [dict setObject:[NSNumber numberWithFloat:self.duration] forKey:@"duration" ];
    [dict setObject:[NSNumber numberWithFloat:self.startTime] forKey:@"startTime" ];
    [dict setObject:[NSNumber numberWithFloat:self.startTimeInTimeLine] forKey:@"startTimeInTimeLine" ];

    
    [dict setObject:self.projectURL forkey:@"projectURL" withDefaultValue:SCDictionaryDefaultString];
    [dict setObject:self.name forkey:@"name" withDefaultValue:SCDictionaryDefaultString];



    return dict;
}

- (void)clearAll
{
    [super clearAll];
}
@end
