//
//  SCVideoBuilder.h
//  SlideshowCreator
//
//  Created 9/24/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSlideShowComposition.h"

@interface SCBasicMediaBuilder : NSObject <SCMediaCompositionBuilderProtocol>

- (id)initWithSlideShow:(SCSlideShowComposition *)slideShow;


- (void)clearAll;

- (void)addEmptyAudio;

@end
