//
//  SCFilterComposition.m
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCFilterComposition.h"

@implementation SCFilterComposition
@synthesize filteredImage;
@synthesize filterMode;
@synthesize thumbnailFilteredImage;
@synthesize hasFilterChanged;
@synthesize model = _model;

- (id)init {
    self = [super init];
    if(self)
    {
        self.filteredImage = nil;
        self.thumbnailFilteredImage = nil;
        self.filterMode = SCImageFilterModeNormal;
        self.hasFilterChanged = NO;
        
        self.model = [[SCFilterModel alloc] init];
    }
    
    return self;
}

- (id)initWithModel:(SCCompositionModel *)model
{
    self = [super initWithModel:model];
    if(self)
    {
        if([model isKindOfClass:[SCFilterModel class]])
        {
            self.model = (SCFilterModel*)model;
            [self getInfoFromModel];
        }
    }
    
    return self;
}



#pragma mark - save/load process
- (void)updateModel
{
    [self clearModel];
    self.model.name = self.name;
    self.model.filterMode = self.filterMode;
    self.model.hasFilterChanged = self.hasFilterChanged;
}

- (void)getInfoFromModel
{
    self.filterMode = self.model.filterMode;
    self.hasFilterChanged = self.model.hasFilterChanged;
}


- (void)clearModel
{
    if(self.model)
    {
        [self.model clearAll];
        self.model = nil;
    }
    
    self.model = [[SCFilterModel alloc] init];
}

#pragma mark -  clear method

- (void)clearAll
{
    [super clearAll];
    self.filteredImage = nil;
    self.thumbnailFilteredImage = nil;
}


@end
