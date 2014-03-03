//
//  SCTransitionModel.m
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTransitionModel.h"

@implementation SCTransitionModel

@synthesize type = _type;
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
