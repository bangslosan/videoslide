//
//  SCSlideTransitionInstruction.h
//  SlideshowCreator
//
//  Created 9/26/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCTransitionComposition.h"

@interface SCSlideTransitionInstruction : NSObject

@property (nonatomic, strong) AVMutableVideoCompositionInstruction *compositionInstruction;
@property (nonatomic, strong) AVMutableVideoCompositionLayerInstruction *fromLayerInstruction;
@property (nonatomic, strong) AVMutableVideoCompositionLayerInstruction *toLayerInstruction;
@property (nonatomic, strong) SCTransitionComposition *transition;


@end
