//
//  SCCompositionModel.h
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCModel.h"

@interface SCCompositionModel : SCModel

@property (nonatomic, strong) NSString  *name;
@property (nonatomic)         float duration;
@property (nonatomic)         float startTime;
@property (nonatomic)         float startTimeInTimeLine;
@property (nonatomic,strong)  NSString *projectURL;

@end

