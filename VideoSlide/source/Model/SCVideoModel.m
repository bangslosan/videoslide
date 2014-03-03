//
//  SCVideoModel.m
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVideoModel.h"

@implementation SCVideoModel

@synthesize videoFileName = _videoFileName;
@synthesize beginDisplay = _beginDisplay;
@synthesize endDisplay = _endDisplay;
@synthesize textArray = _textArray;


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


@end
