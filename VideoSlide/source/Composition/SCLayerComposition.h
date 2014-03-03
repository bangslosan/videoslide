//
//  SCLayerComposition.h
//  SlideshowCreator
//
//  Created 9/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCComposition.h"

@interface SCLayerComposition : SCComposition

@property (nonatomic, strong) UIImage *titleImage;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *subtitleText;
@property (nonatomic) BOOL useLargeFont;
@property (nonatomic) BOOL spinOut;

- (CALayer *)layer;

@end
