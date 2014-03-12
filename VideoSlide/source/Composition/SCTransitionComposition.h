//
//  SCTransitionComposition.h
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCComposition.h"

@interface SCTransitionComposition : SCComposition

+ (id)videoTransition;

@property (nonatomic, strong) SCTransitionModel     *model;
@property (nonatomic) SCVideoTransitionType type;
@property (nonatomic) SCPushTransitionDirection direction;

#pragma mark - Convenience initializers for stock transitions

- (id)initWithType:(SCVideoTransitionType)type duration:(float)duration;

+ (id)fadeInTransitionWithDuration:(float)duration;

+ (id)fadeOutTransitionWithDuration:(float)duration;

+ (id)disolveTransitionWithDuration:(float)duration;

+ (id)zoomTransitionWithDuration:(float)duration ;

+ (id)pushTransitionWithDuration:(float)duration direction:(SCPushTransitionDirection)direction;

@end
