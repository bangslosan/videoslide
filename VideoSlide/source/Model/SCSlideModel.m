//
//  SCSlideModel.m
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSlideModel.h"

@implementation SCSlideModel

@synthesize imgName = _imgName;
@synthesize filter = _filter;
@synthesize startTrans = _startTrans;
@synthesize endTrans = _endTrans;
@synthesize textArray = _textArray;
@synthesize thumbnailImgName  =_thumbnailImgName;
@synthesize filterImgName     = _filterImgName;
@synthesize imgWithTextName   = _imgWithTextName;


- (id)init
{
    self = [super init];
    if(self)
    {
        self.textArray = [[NSMutableArray alloc] init];
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
        self.startTrans = [[SCTransitionModel alloc] initWithDictionary:[dict valueForKey:@"startTrans" ]];
        self.endTrans = [[SCTransitionModel alloc] initWithDictionary:[dict valueForKey:@"endTrans" ]];
        self.filter = [[SCFilterModel alloc] initWithDictionary:[dict valueForKey:@"filter" ]];
        
        self.textArray = [[NSMutableArray alloc] init];
        
        for(NSDictionary *textDict in [dict valueForKey:@"textArray" withDefaultValue:SCDictionaryDefaultArray])
        {
            SCTextModel *text = [[SCTextModel alloc] initWithDictionary:textDict];
            [self.textArray addObject:text];
        }

    }
    
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dict = [super toDictionary];
    
    if(self.startTrans)
        [dict setObject:[self.startTrans toDictionary] forKey:@"startTrans"];
    if(self.endTrans)
        [dict setObject:[self.endTrans toDictionary] forKey:@"endTrans"];
    if(self.filter)
        [dict setObject:[self.filter toDictionary] forKey:@"filter"];
    
    //test array
    NSMutableArray *texts = [[NSMutableArray alloc] init];
    for(SCTextModel *text in self.textArray)
    {
        [texts addObject:[text toDictionary]];
    }
    [dict setObject:texts forKey:@"textArray"];
    
    
    
    return dict;
}

- (void)clearAll
{
    [super clearAll];
    if(self.textArray.count > 0)
    {
        [self.textArray removeAllObjects];
    }
    self.textArray = nil;
    
    if(self.startTrans)
    {
        [self.startTrans clearAll];
        self.startTrans = nil;
    }
    if(self.endTrans)
    {
        [self.endTrans clearAll];
        self.endTrans = nil;
    }
    
    if(self.filter)
    {
        [self.filter clearAll];
        self.filter = nil;
    }
    
}
@end
