//
//  SCAudipModel.m
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCAudioModel.h"

@implementation SCAudioModel

@synthesize audioFileURL = _audioFileURL;
@synthesize volume = _volume;
@synthesize fadeIn = _fadeIn;
@synthesize fadeOut = _fadeOut;
@synthesize audioID = _audioID;
@synthesize normal = _normal;

- (id)init
{
    self = [super init];
    if(self)
    {
        //self.fadeIn = [[SCVolumeRampModel alloc] init];
        //self.fadeOut = [[SCVolumeRampModel alloc] init];
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
        self.fadeIn = [[SCVolumeRampModel alloc] initWithDictionary:[dict valueForKey:@"fadeIn"]];
        self.fadeOut = [[SCVolumeRampModel alloc] initWithDictionary:[dict valueForKey:@"fadeOut"]];
        self.normal = [[SCVolumeRampModel alloc] initWithDictionary:[dict valueForKey:@"normal"]];

    }
    
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dict = [super toDictionary];
    
    if(self.fadeIn)
    {
        [dict setObject:[self.fadeIn toDictionary] forKey:@"fadeIn"];
    }

    if(self.fadeOut)
    {
        [dict setObject:[self.fadeOut toDictionary] forKey:@"fadeOut"];
    }
    
    if(self.normal)
    {
        [dict setObject:[self.normal toDictionary] forKey:@"normal"];
    }

    
    return dict;
}

- (void)clearAll
{
    [super clearAll];
    if(self.fadeIn)
    {
        [self.fadeIn clearAll];
        self.fadeIn = nil;
    }
    
    if(self.fadeOut)
    {
        [self.fadeOut clearAll];
        self.fadeOut = nil;
    }
    
    if(self.normal)
    {
        [self.normal clearAll];
        self.normal = nil;
    }
}

@end
