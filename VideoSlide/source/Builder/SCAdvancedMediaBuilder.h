//
//  SCAdvancedVideoBuilder.h
//  SlideshowCreator
//
//  Created 9/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCAdvancedBuilderComposition;

@interface SCAdvancedMediaBuilder : NSObject

- (id)initWithSlideShow:(SCSlideShowComposition *)slideShow;

- (SCAdvancedBuilderComposition*)buildMediaComposition;

@end
