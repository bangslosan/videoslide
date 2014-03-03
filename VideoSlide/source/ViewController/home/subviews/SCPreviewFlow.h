//
//  SCPreviewFlow.h
//  VideoSlide
//
//  Created by Thi Huynh on 2/14/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCView.h"
#import "SCSlideShowComposition.h"

@interface SCPreviewFlow : SCView

- (id)initWith:(NSMutableArray*)slides;


- (void)updateWithSlides:(NSMutableArray*)slides;
@end
