//
//  SCVideoModel.h
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCompositionModel.h"

@interface SCVideoModel : SCCompositionModel

@property (nonatomic, strong) NSString          *videoFileName;
@property (nonatomic, strong) SCTransitionModel *beginDisplay;
@property (nonatomic, strong) SCTransitionModel *endDisplay;
@property (nonatomic, strong) NSArray           *textArray;


@end
