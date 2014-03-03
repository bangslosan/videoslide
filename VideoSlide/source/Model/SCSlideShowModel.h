//
//  SCSlideShowModel.h
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCompositionModel.h"
#import "SCAudioModel.h"

@interface SCSlideShowModel : SCCompositionModel

@property (nonatomic, strong) NSMutableArray    *slideArray;
@property (nonatomic, strong) NSMutableArray    *transitionArray;
@property (nonatomic, strong) SCAudioModel      *recordModel;
@property (nonatomic, strong) SCAudioModel      *musicModel;
@property (nonatomic, strong) NSDate            *dateCreated;
@property (nonatomic, strong) NSString          *videoExtension;
@property (nonatomic, strong) NSString          *thumbnailImageName;
@property (nonatomic, strong) NSString          *exportURL;
@property (nonatomic, strong) NSString          *exportVideoName;

@property (nonatomic)         SCColor           backgroundColor;
@property (nonatomic)         CGSize            videoSize;
@property (nonatomic)         int               FPS;

@property (nonatomic)         int                                   numberOfPhotos;
@property (nonatomic)         float                                 totalDuration;
@property (nonatomic)         float                                 slideDuration;
@property (nonatomic)         int                                   transitionDuration;
@property (nonatomic)         BOOL                                  transitionEnable;
@property (nonatomic)         SCVideoTransitionType                 transitionType;
@property (nonatomic)         SCVideoDurationType                   videoDurationType;





@end

