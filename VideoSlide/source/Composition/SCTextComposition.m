//
//  SCTextComposition.m
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTextComposition.h"

@implementation SCTextComposition

@synthesize model = _model;

- (id)init {
    self = [super init];
    if (self) {
        self.model = [[SCTextModel alloc] init];
    }
    return self;
}

- (id)initWithTextComposition:(SCTextComposition*)textComposition {
    self = [super init];
    if (self) {
        self.model = [[SCTextModel alloc] initWithTextModel:textComposition.model];
    }
    return self;
}


- (id)initWithModel:(SCCompositionModel *)model
{
    self = [super initWithModel:model];
    if(self)
    {
        if([model isKindOfClass:[SCTextModel class]])
        {
            self.model = (SCTextModel*)model;
            [self getInfoFromModel];
        }
    }
    
    return self;
}


#pragma mark - save/load process

- (void)updateModel
{
    
}

- (void)getInfoFromModel
{
    
}


- (void)clearModel
{
    if(self.model)
    {
        [self.model clearAll];
        self.model = nil;
    }
    
    self.model = [[SCTextModel alloc] init];
}


#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    self.model = nil;
}
@end
