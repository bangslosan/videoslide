//
//  SCTextComposition.h
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCTextModel.h"

@interface SCTextComposition : SCComposition

- (id)initWithTextComposition:(SCTextComposition*)textComposition;

@property (nonatomic, strong) SCTextModel *model;

@end
