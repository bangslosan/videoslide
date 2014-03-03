//
//  SCSlideModel.h
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCompositionModel.h"
#import "SCTransitionModel.h"
#import "SCFilterModel.h"

@interface SCSlideModel : SCCompositionModel

@property (nonatomic, strong) NSString *imgName;
@property (nonatomic, strong) NSString *thumbnailImgName;
@property (nonatomic, strong) NSString *filterImgName;
@property (nonatomic, strong) NSString *imgWithTextName;


@property (nonatomic, strong) SCFilterModel *filter;
@property (nonatomic, strong) SCTransitionModel *startTrans;
@property (nonatomic, strong) SCTransitionModel *endTrans;
@property (nonatomic, strong) NSMutableArray           *textArray;


@end
