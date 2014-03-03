//
//  SCVolumeRampModel.m
//  SlideshowCreator
//
//  Created 10/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVolumeRampModel.h"

@implementation SCVolumeRampModel

@synthesize startVolume = _startVolume;
@synthesize endVolume   = _endVolume;
@synthesize enable      = _enable;

- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if(!dict)
        return nil;
    self = [super initWithDictionary:dict];
    if(self)
    {
        
    }
    
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dict = [super toDictionary];
    return dict;
}

- (void)clearAll
{
    [super clearAll];
}
@end
