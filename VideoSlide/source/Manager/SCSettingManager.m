//
//  SCSettingManager.m
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSettingManager.h"

static SCSettingManager *instance;


@implementation SCSettingManager


- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

+ (SCSettingManager*)getInstance
{
    @synchronized([SCSettingManager class])
    {
        if(!instance)
            instance = [[self alloc] init];
        return instance;
    }
    
    return nil;
    
}



@end
