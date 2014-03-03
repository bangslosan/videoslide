//
//  SCVideoCreatorManager.h
//  SlideshowCreator
//
//  Created 9/10/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"
#import "SCSlideShowModel.h"
#import "SCSlideModel.h"
#import "SCTransitionModel.h"
#import "SCAudioModel.h"
#import "SCSlideShowComposition.h"

@interface SCVideoCreatorManager : SCBaseManager

@property (nonatomic) BOOL isInProgress;

+ (SCVideoCreatorManager*)getInstance;


- (void)generateVideoWith:(SCSlideShowComposition*)slideShow;


@end
