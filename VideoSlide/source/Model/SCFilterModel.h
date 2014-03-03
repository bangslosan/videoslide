//
//  SCFilterModel.h
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCompositionModel.h"

@interface SCFilterModel : SCCompositionModel

@property (nonatomic) SCImageFilterMode  filterMode;
@property (nonatomic) BOOL               hasFilterChanged;

@end
