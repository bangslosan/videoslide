//
//  SCComposition.h
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCComposition : NSObject 

@property (nonatomic, assign) CMTimeRange   timeRange;
@property (nonatomic, assign) CMTime        startTimeInTimeline;
@property (nonatomic, assign) CMTime        endTimeInTimeline;
@property (nonatomic, assign) CMTime        duration;
@property (nonatomic, assign) BOOL          needToUpdate;
@property (nonatomic, assign) BOOL          markDelete;
@property (nonatomic, strong) NSString      *name;


- (id)initWithModel:(SCCompositionModel*)model;
- (void)updateModel;
- (void)getInfoFromModel;
- (void)clearAll;
- (void)clearModel;

@end
