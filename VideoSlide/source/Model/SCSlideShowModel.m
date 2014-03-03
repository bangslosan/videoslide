//
//  SCSlideShowModel.m
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSlideShowModel.h"

@implementation SCSlideShowModel

@synthesize slideArray = _slideArray;
@synthesize transitionArray = _transitionArray;
@synthesize recordModel = _recordModel;
@synthesize musicModel = _musicModel;
@synthesize dateCreated = _dateCreated;
@synthesize videoExtension = _videoExtension;
@synthesize backgroundColor = _backgroundColor;
@synthesize videoSize = _videoSize;
@synthesize FPS            = _FPS;
@synthesize thumbnailImageName = _thumbnailImageName;
@synthesize exportURL          = _exportURL;
@synthesize exportVideoName    = _exportVideoName;

@synthesize numberOfPhotos = _numberOfPhotos;
@synthesize transitionDuration = _transitionDuration;
@synthesize transitionEnable = _transitionEnable;
@synthesize transitionType = _transitionType;
@synthesize slideDuration = _slideDuration;
@synthesize totalDuration = _totalDuration;
@synthesize videoDurationType = _videoDurationType;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.slideArray = [[NSMutableArray alloc]init];
        self.transitionArray = [[NSMutableArray alloc]init];
        //self.recordModel = [[SCAudioModel alloc]init];
        //self.musicModel = [[SCAudioModel alloc]init];
        self.dateCreated = [NSDate date];
        self.videoExtension = @"";
        self.backgroundColor = [SCHelper colorFromUIcolor:[UIColor blackColor]];
        self.videoSize = SC_VIDEO_SIZE;
        self.thumbnailImageName = @"";
    }
    
    return self;

}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if(self)
    {
        self.recordModel    = [[SCAudioModel alloc] initWithDictionary:[dict valueForKey:@"recordModel" ]];
        self.musicModel     = [[SCAudioModel alloc] initWithDictionary:[dict valueForKey:@"musicModel"]];
        self.videoSize      = [SCHelper sizeFromArray:[dict valueForKey:@"videoSize" withDefaultValue:SCDictionaryDefaultArray]];
        self.backgroundColor= [SCHelper colorFromArray:[dict valueForKey:@"backgroundColor" withDefaultValue:SCDictionaryDefaultArray]];
    
        
        //slide array
        self.slideArray = [[NSMutableArray alloc] init];
        for(NSDictionary *item in [dict valueForKey:@"slideArray" withDefaultValue:SCDictionaryDefaultArray])
        {
            SCSlideModel *slide = [[SCSlideModel alloc] initWithDictionary:item];
            [self.slideArray addObject:slide];
        }
        
        //transition array
        self.transitionArray = [[NSMutableArray alloc] init];
        for(NSDictionary *item in [dict valueForKey:@"transitionArray" withDefaultValue:SCDictionaryDefaultArray])
        {
            SCTransitionModel *transition = [[SCTransitionModel alloc] initWithDictionary:item];
            [self.slideArray addObject:transition];
        }

    }
    
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dict = [super toDictionary];
    if(self.recordModel)
        [dict setObject:[self.recordModel toDictionary] forKey:@"recordModel"];
    if(self.musicModel)
        [dict setObject:[self.musicModel toDictionary] forKey:@"musicModel"];
    [dict setObject:[SCHelper arrayFromSize:self.videoSize] forKey:@"videoSize"];
    [dict setObject:[SCHelper arrayFromSCColor:self.backgroundColor] forKey:@"backgroundColor"];

    
    //slide array
    NSMutableArray *slides = [[NSMutableArray alloc] init];
    for(SCSlideModel *slide in self.slideArray)
    {
        [slides addObject:[slide toDictionary]];
    }
    
    [dict setObject:slides forKey:@"slideArray"];

    return dict;
}

- (void)clearAll
{
    [super clearAll];
    
    if(self.slideArray.count > 0)
    {
        for(SCSlideModel *slide in self.slideArray)
        {
            [slide clearAll];
        }
        
        [self.slideArray removeAllObjects];
        self.slideArray = nil;
    }
    
    if(self.transitionArray.count > 0)
    {
        for(SCTransitionModel *trans in self.transitionArray)
        {
            [trans clearAll];
        }
        
        [self.transitionArray removeAllObjects];
        self.transitionArray = nil;
    }
    
    if(self.musicModel)
    {
        [self.musicModel clearAll];
        self.musicModel = nil;
    }
    
    if(self.recordModel)
    {
        [self.recordModel clearAll];
        self.recordModel = nil;
    }
}


@end
