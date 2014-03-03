//
//  SCFilterModel.m
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCFilterModel.h"

@implementation SCFilterModel

@synthesize hasFilterChanged = _hasFilterChanged;
@synthesize filterMode = _filterMode;

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
        //self.filterMode = ((NSNumber*)[dict objectForKey:@"filterMode"]).intValue;
    }
    
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dict = [super toDictionary];
    //[dict setObject:[NSNumber numberWithInt:self.filterMode] forKey:@"filterMode"];
    return dict;
}

- (void)clearAll
{
    [super clearAll];
}
@end
