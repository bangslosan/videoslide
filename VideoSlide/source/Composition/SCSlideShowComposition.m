//
//  SCSlideShowComposition.m
//  SlideshowCreator
//
//  Created 9/10/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSlideShowComposition.h"
#import "SCTransitionComposition.h"

@interface SCSlideShowComposition ()

@property (nonatomic) int slideIndex;

@end

@implementation SCSlideShowComposition

@synthesize delegate = _delegate;
@synthesize slides = _slides;
@synthesize transitions = _transitions;
@synthesize audios = _audios;
@synthesize record = _record;
@synthesize music = _music;
@synthesize model = _model;
@synthesize musics = _musics;
@synthesize videos = _videos;
@synthesize layers = _layers;
@synthesize isAdvanced = _isAdvanced;
@synthesize totalDuration = _totalDuration;
@synthesize isComposing = _isComposing;
@synthesize exportURL = _exportURL;
@synthesize thumbnailImg  = _thumbnailImg;
@synthesize deleteItems = _deleteItems;
@synthesize iSOverWrite = _iSOverWrite;
@synthesize mediaExportQuality = _mediaExportQuality;

- (id)init
{
    self = [super init];
    if(self)
    {
        _slides         = [[NSMutableArray alloc]init];
        _transitions    = [[NSMutableArray alloc]init];
        _audios         = [[NSMutableArray alloc]init];
        _musics         = [[NSMutableArray alloc]init];
        _videos         = [[NSMutableArray alloc]init];
        _layers         = [[NSMutableArray alloc]init];
        _record         = [[SCAudioComposition alloc]init];
        _music          = [[SCAudioComposition alloc]init];
        _model          = [[SCSlideShowModel alloc]init];
        _deleteItems    = [[NSMutableArray alloc] init];
        
        _isAdvanced = NO;
        _isComposing = NO;
        _iSOverWrite = NO;
        _mediaExportQuality = NSLocalizedString(@"Hight", nil);
        
        self.slideIndex = 0;

    }
    
    return self;
}

- (id)initWithModel:(SCCompositionModel *)model
{
    self = [super initWithModel:model];
    if(self)
    {
        if([model isKindOfClass:[SCSlideShowModel class]])
        {
            _slides         = [[NSMutableArray alloc]init];
            _transitions    = [[NSMutableArray alloc]init];
            _audios         = [[NSMutableArray alloc]init];
            _musics         = [[NSMutableArray alloc]init];
            _videos         = [[NSMutableArray alloc]init];
            _layers         = [[NSMutableArray alloc]init];
            _deleteItems    = [[NSMutableArray alloc] init];

            _isAdvanced     = NO;
            _isComposing    = NO;
            _iSOverWrite    = NO;
            _mediaExportQuality = NSLocalizedString(@"Hight", nil);
            
            self.model = (SCSlideShowModel*)model;
            [self getInfoFromModel];
        }
    }
    
    return self;
}


#pragma mark  - save/load model process

- (void)updateModel
{
    [self clearModel];
    self.model.videoExtension       = SC_MOV;
    self.model.videoSize            = SC_VIDEO_SIZE;
    self.model.name                 = self.name;
    self.model.dateCreated          = [NSDate date];
    self.model.FPS                  = SC_VIDEO_OUTPUT_FPS;
    self.model.duration             = CMTimeGetSeconds(self.totalDuration);
    self.model.exportURL            = self.exportURL.path;
    self.model.exportVideoName      = [self.name stringByAppendingPathExtension:SC_MOV];
    
    //get the fist slide to obtain the thumbnail image
    SCSlideComposition *slide       = [self.slides objectAtIndex:0];
    if(slide.filterComposition.filterMode == SCImageFilterModeNormal)
    {
        self.thumbnailImg = slide.image;
    }
    else
    {
        self.thumbnailImg = slide.filterComposition.filteredImage;
    }
    //check to create video with text
   /* if(slide.texts.count > 0)
    {
        //draw text to image here to write final video for composition
        CGSize previewSize;
        previewSize = SC_IS_IPHONE5 ? SC_PREVIEW_4INCH_SIZE:SC_PREVIEW_3INCH5_SIZE;
        self.thumbnailImg = [SCImageUtil imageTextWithSlideComposition:slide previewSize:previewSize];
    }*/
    self.model.thumbnailImageName   = [@"thumbnail" stringByAppendingPathExtension:SC_PNG];
    
    //setting info
    self.model.totalDuration        = [SCSlideShowSettingManager getInstance].videoTotalDuration;
    self.model.slideDuration        = [SCSlideShowSettingManager getInstance].slideDuration;
    self.model.transitionEnable     = [SCSlideShowSettingManager getInstance].transitionsEnabled;
    self.model.transitionType       = [SCSlideShowSettingManager getInstance].transitionType;
    self.model.transitionDuration   = [SCSlideShowSettingManager getInstance].transitionDuration;
    self.model.numberOfPhotos       = [SCSlideShowSettingManager getInstance].numberPhotos;
    self.model.videoDurationType    = [SCSlideShowSettingManager getInstance].videoDurationType;
    
    if(self.musics.count  > 0)
    {
        SCAudioComposition *music   = [self.musics objectAtIndex:0];
        music.projectURL            = self.exportURL;
        [music updateModel];
        self.model.musicModel       = music.model;
    }
    if(self.audios.count  >0)
    {
        SCAudioComposition *audio = [self.audios objectAtIndex:0];
        audio.projectURL            = self.exportURL;
        [audio updateModel];
        audio.model.audioFileURL        = [SCFileManager urlFromDir:self.exportURL withName:audio.name].path;
        self.model.recordModel          = audio.model;
    }
    
    //slide array
    for(SCSlideComposition *slide in self.slides)
    {
        slide.projectURL            = self.exportURL;
        [slide updateModel];
        [self.model.slideArray addObject:slide.model];
    }
    
    //transition array
    for(SCTransitionComposition *transition in self.transitions)
    {
        [transition updateModel];
        [self.model.transitionArray addObject:transition.model];
    }
}


- (void)getInfoFromModel
{
    self.name      = self.model.name;
    self.exportURL = [NSURL fileURLWithPath:self.model.exportURL];
    self.totalDuration = CMTimeMake(self.model.totalDuration * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
       //slides
    for(SCSlideModel *slide in self.model.slideArray)
    {
        SCSlideComposition *slideComposition = [[SCSlideComposition alloc] initWithModel:slide];
        [self.slides addObject:slideComposition];
    }
    
    //transitions
    for(SCTransitionModel *trans in self.model.transitionArray)
    {
        SCTransitionComposition *transitionComposition = [[SCTransitionComposition alloc] initWithModel:trans];
        [self.transitions addObject:transitionComposition];
    }
    
    //musics
    if(self.model.musicModel)
    {
        self.music = [[SCAudioComposition alloc] initWithModel:self.model.musicModel];
        [self.musics addObject:self.music];
    }
    
    //records
    if(self.model.recordModel)
    {
        self.record = [[SCAudioComposition alloc] initWithModel:self.model.recordModel];
        [self.audios addObject:self.record];
    }
    //set info to slide show setting

}

- (void)clearModel
{
    if(self.model)
    {
        [self.model clearAll];
        self.model = nil;
    }
    
    self.model = [[SCSlideShowModel alloc] init];
}

#pragma mark - instance methods

- (void)addSlides:(NSMutableArray*)slides
{
    self.slideIndex = 0;
   for(SCSlideComposition *slide in slides)
    {
        [self addSlideComposition:slide];
    }
}


- (void)addMoreSlides:(NSMutableArray *)slides
{
    
}


- (void)addSlideComposition:(SCSlideComposition*)slide
{
    if(self.slides)
    {
        if(!slide.name.length)
            slide.name = [NSString stringWithFormat:@"slide-%d-%@", self.slides.count,[SCHelper getCurrentDateTimeInString]];
        
        if(!self.slides)
            self.slides = [[NSMutableArray alloc] init];
        [self.slides addObject:slide];
    }
}

- (void)addSlideComposition:(SCSlideComposition *)slide atIndex:(int)index
{
    if(slide && index <= self.slides.count)
    {
        if(self.slides.count == index)
        {
            slide.name = [NSString stringWithFormat:@"slide-%d-%@", self.slides.count,[SCHelper getCurrentDateTimeInString]];
            [self.slides addObject:slide];
            //SCVideoComposition *video = [slide convertToVideoComposition:NO];
            //[self.videos addObject:video];
        }
        else
        {
            slide.name = [NSString stringWithFormat:@"slide-%d-%@", self.slides.count,[SCHelper getCurrentDateTimeInString]];
            [self.slides insertObject:slide atIndex:index];
            //SCVideoComposition *video = [slide convertToVideoComposition:NO];
            //[self.videos insertObject:video atIndex:index];
        }
    }
}

- (void)addTransitionAfterSlideIndex:(int)index transition:(SCTransitionComposition*)transition
{
    //can only add transition between 2 slides
    if(index <= self.slides.count - 2 && self.slides.count >= 2)
    {
        [self.transitions addObject:transition];
    }
    else
        NSLog(@"[Notice] Transition index is wrong (%d) because there is only %d slide",index,self.slides.count);
}

- (void)deleteSlideComposition:(SCSlideComposition *)slide
{
    if(self.slides.count > 0 && slide)
    {
        if(slide.imageURL && slide.thumbnailURL)
        {
            [self.deleteItems addObject:slide.imageURL];
            [self.deleteItems addObject:slide.thumbnailURL];
        }
        
        int index = [self.slides indexOfObject:slide];
        if(self.videos.count > index)
        {
            SCVideoComposition *video = [self.videos objectAtIndex:index];
            [self.videos removeObject:video];
            [video clearAll];
            video = nil;
        }
        [self.slides removeObject:slide];
        [slide clearAll];
        slide = nil;
    }
}

- (BOOL)exportResourcesToProject
{
    [self updateModel];
    NSMutableDictionary *dict =[self.model toDictionary];
    //[dict setObject:@"asfasf" forKey:@"asfasfaf"];
    NSURL *url = [SCFileManager urlFromDir:self.exportURL withName:SC_PROJECT_NAME];
    if([SCFileManager exist:url])
    {
        [SCFileManager deleteFileWithURL:url];
    }
    BOOL exportStatus = [dict writeToURL:url atomically:YES];
    if(exportStatus)
    {
        //check to delete temp items incase overwriting the project
        if(self.iSOverWrite)
        {
            for(NSURL *deleteItem in self.deleteItems)
            {
                if([SCFileManager exist:deleteItem])
                {
                    [SCFileManager deleteFileWithURL:deleteItem];
                }
            }
        }
        //export images
        for(SCSlideComposition *slide in self.slides)
        {
            [SCFileManager writeImageIntoDir:self.exportURL image:slide.image imageName:slide.model.imgName];
            //[SCFileManager writeImageIntoDir:self.exportURL image:slide.thumbnailImage imageName:slide.model.thumbnailImgName];
        }
        if(self.thumbnailImg)
        {
           // [SCFileManager writeImageIntoDir:self.exportURL image:self.thumbnailImg imageName:self.model.thumbnailImageName];
        }
        //export record audio
        if(self.audios.count > 0)
        {
            SCAudioComposition *record = [self.audios objectAtIndex:0];
            if([SCFileManager copyFileFrom:record.url toDir:[SCFileManager urlFromDir:self.exportURL withName:record.name]])
            {
                record.model.audioFileURL = [SCFileManager urlFromDir:self.exportURL withName:record.name].path;
            }
        }
    }
    else
    {
        //delete all project folder
        if([SCFileManager exist:self.exportURL])
        {
            [SCFileManager deleteFileWithURL:self.exportURL];
        }
    }
    
    return exportStatus;
    
}


- (void)updateSLideShowSetting
{
    if(self.model)
    {
        //getting setting info from model
        [SCSlideShowSettingManager getInstance].videoTotalDuration  =   self.model.totalDuration ;
        [SCSlideShowSettingManager getInstance].slideDuration       =   self.model.slideDuration;
        [SCSlideShowSettingManager getInstance].transitionsEnabled  =   self.model.transitionEnable;
        [SCSlideShowSettingManager getInstance].transitionType      =   self.model.transitionType;
        [SCSlideShowSettingManager getInstance].transitionDuration  =   self.model.transitionDuration ;
        [SCSlideShowSettingManager getInstance].numberPhotos        =   self.model.numberOfPhotos;
        [SCSlideShowSettingManager getInstance].videoDurationType   =   self.model.videoDurationType;
        [[SCSlideShowSettingManager getInstance] logToDebug];
    }

}

- (void)startCropAllPhotos
{
    if(self.slides.count > self.slideIndex)
    {
        SCSlideComposition *slide = [self.slides objectAtIndex:self.slideIndex];
        if (!slide.isCropped)
        {
            [SCImageUtil cropImageFromURLAsset:slide.assetURL size:SC_CROP_PHOTO_SIZE completionBlock:^(UIImage *result)
             {
                 slide.image = result;
                 slide.isCropped = YES;
                 if([self checkCropStatus])
                 {
                     if([self.delegate respondsToSelector:@selector(finishCropAllPhoto)])
                     {
                         [self.delegate finishCropAllPhoto];
                     }
                 }
                 else
                 {
                     self.slideIndex ++;
                     if([self.delegate respondsToSelector:@selector(numberCroppedImage:)])
                     {
                         [self.delegate numberCroppedImage:self.slideIndex];
                     }
                     [self startCropAllPhotos];
                 }
             } completionBlock:^{
             }];
        }
        else
        {
            if([self checkCropStatus])
            {
                if([self.delegate respondsToSelector:@selector(finishCropAllPhoto)])
                    [self.delegate finishCropAllPhoto];
            }
            else
            {
                self.slideIndex ++;
                [self startCropAllPhotos];
            }
        }
    }
}

- (BOOL)checkCropStatus
{
    int i= 0;
    for(SCSlideComposition *slideComposition in self.slides)
    {
        if(slideComposition.isCropped)
            i++;
        if(i == self.slides.count)
        {
            return YES;
        }
    }
    
    return NO;
}
#pragma mark - class methods

- (void)refreshSlideShow
{
    int index = 0;
    float duration = [SCSlideShowSettingManager getInstance].slideDuration;
    float startTrans = [SCSlideShowSettingManager getInstance].transitionDuration;
    float endTrans = [SCSlideShowSettingManager getInstance].transitionDuration;
    self.totalDuration = CMTimeMake([SCSlideShowSettingManager getInstance].videoTotalDuration * SC_VIDEO_CUSTOM_DURATION, SC_VIDEO_CUSTOM_DURATION);
    for (SCSlideComposition *slide in self.slides)
    {
        if(index == 0)
            startTrans = 0;
        else
            startTrans = [SCSlideShowSettingManager getInstance].transitionDuration;
        
        if(index == self.slides.count - 1)
            endTrans = 0;
        else
            endTrans = [SCSlideShowSettingManager getInstance].transitionDuration;
        
        [slide updateSlide:duration startTrans:startTrans endTrans:endTrans transType:[SCSlideShowSettingManager getInstance].transitionType];
        index ++;
    }
    
    //update transition by deleting all and re-create the new one
    if(self.transitions.count > 0)
    {
        for(SCTransitionComposition *trans in  self.transitions)
        {
            [trans clearAll];
        }
        [self.transitions removeAllObjects];
    }
    if([SCSlideShowSettingManager getInstance].transitionsEnabled && [SCSlideShowSettingManager getInstance].transitionType != SCVideoTransitionTypeNone)
    {
        if(self.slides.count >= 2)
        {
            for(int i = 0; i <= self.slides.count - 2; i++)
            {
                //create transition
                SCTransitionComposition *trans = [[SCTransitionComposition alloc] initWithType:[SCSlideShowSettingManager getInstance].transitionType duration:[SCSlideShowSettingManager getInstance].transitionDuration];
                [self addTransitionAfterSlideIndex:i transition:trans];
            }
        }
    }

}

#pragma mark - build methods

- (void)preBuildAsynchronouslyWithCompletionHandler:(void (^)(void))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        self.isComposing = YES;
        [self preBuild];
        //do background task here
        dispatch_async(dispatch_get_main_queue(), ^{
            //do task after background task finished on mainthread
            completionBlock();
        });
        
    });
    [self monitorPrebuildProgress];
}


- (void)preBuild
{
    if(self.slides.count > 0)
    {
        //empty all video first
        if(self.videos.count > 0)
        {
            for(SCVideoComposition *video in self.videos)
            {
                [video clearAll];
            }
            [self.videos removeAllObjects];
        }
        //create each image from slides to video
        for (int i = 0; i < self.slides.count ;i ++)
        {
            SCSlideComposition *slide = [self.slides objectAtIndex:i];
            NSURL *videoURL = [SCFileManager createURLFromTempWithName:[NSString stringWithFormat:@"%@.%@",slide.name,SC_MOV]];
            SCVideoComposition *video;
            if([SCFileManager exist:videoURL] && !slide.needToUpdate)
            {
                video = [[SCVideoComposition alloc]initWithURL:videoURL];
                if(CMTimeGetSeconds(video.duration) > 0)
                {
                    video.startTimeInTimeline    = slide.startTimeInTimeline;
                    video.timeRange              = slide.timeRange;
                    video.startTransition        = slide.startTransition;
                    video.endTransition          = slide.endTransition;
                    [self.videos addObject:video];
                }
            }
            else
            {
                video = [slide convertToVideoComposition:NO];
                slide.needToUpdate = NO;
                if(video)
                    [self.videos addObject:video];
                else
                {
                    [self deleteSlideComposition:slide];
                    NSLog(@"[Create video from slide FAILED]");
                }
            }
            NSLog(@"[BuiltVideo index %d]",i+1);
        }
        
        //check status of builder
        if(self.transitions.count > 0)
            self.isAdvanced = YES;
        else
            self.isAdvanced = NO;
        
        self.isComposing = NO;
    }
}

- (void)monitorPrebuildProgress
{
	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	__weak id weakSelf = self;
	dispatch_after(popTime, dispatch_get_main_queue(), ^
                   {
                       if(self.slides.count > 0)
                       {
                           if([self.delegate respondsToSelector:@selector(prebuildProgressValue:totalValue:)])
                           {
                               if(self.isComposing)
                                   [self.delegate prebuildProgressValue:self.videos.count totalValue:self.slides.count];
                               else
                               {
                                   [self.delegate prebuildProgressValue:1 totalValue:1];
                               }
                           }
                       }
                       if(self.videos.count < self.slides.count && self.isComposing)
                           [weakSelf monitorPrebuildProgress];
                    });
}

#pragma mark - update methods

- (void)updateAsynchronouslyWithCompletionHandler:(void (^)(void))completionBlock
{
    if(self.isComposing)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       self.isComposing = YES;
                       [self update];
                       //do background task here
                       dispatch_async(dispatch_get_main_queue(), ^{
                           //do task after background task finished on mainthread
                           completionBlock();
                       });
                       
                   });
}


- (void)update
{
    //check if  slide show contain transition and other effects --> using advanced builder
    if(self.slides.count > 0 && self.videos.count > 0  && self.slides.count == self.videos.count)
    {
        //create each image from slides to video
        for (int i = 0; i < self.slides.count ;i ++)
        {
            SCSlideComposition *slide = [self.slides objectAtIndex:i];
            if(slide.needToUpdate)
            {
                //create  the new video
                SCVideoComposition *video = [slide convertToVideoComposition:NO];
                if(video)
                {
                    //find the old video and clear it
                    SCVideoComposition *oldVideo = [self.videos objectAtIndex:i];
                    [oldVideo clearAll];

                    [self.videos replaceObjectAtIndex:i withObject:video];
                    slide.needToUpdate = NO;
                }
                else
                {
                    [self deleteSlideComposition:slide];
                    NSLog(@"[Create video from slide FAILED]")
                }
                
            }
            NSLog(@"[Updated Video index %d]",i+1);
        }
        
        //check status of builder
        if(self.transitions.count > 0)
            self.isAdvanced = YES;
        else
            self.isAdvanced = NO;
        
        self.isComposing = NO;
    }
}

#pragma mark - pre export

- (void)preExportAsynchronouslyWithCompletionHandler:(void (^)(void))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       self.isComposing = YES;
                       [self preExport];
                       //do background task here
                       dispatch_async(dispatch_get_main_queue(), ^
                       {
                           //do task after background task finished on mainthread
                           completionBlock();
                       });
                       
                   });
    
    [self monitorPrebuildProgress];
}

- (void)preExport
{
    //check if  slide show contain transition and other effects --> using advanced builder
    if(self.slides.count > 0 )
    {
        NSURL *tempFolderURL = [SCFileManager URLFromTempWithName:SC_OUTPUT_TEMP_FOLDER];

        if([SCFileManager exist:[SCFileManager URLFromTempWithName:SC_OUTPUT_TEMP_FOLDER]])
            [SCFileManager deleteFileWithURL:tempFolderURL];
        tempFolderURL = [SCFileManager createFolderFromTempWithName:SC_OUTPUT_TEMP_FOLDER];
        
        if(self.videos.count > 0)
        {
            [self.videos removeAllObjects];
        }
        //create each image from slides to video
        for (int i = 0; i < self.slides.count ;i ++)
        {
            SCSlideComposition *slide = [self.slides objectAtIndex:i];
            
            SCVideoComposition *video = [slide convertToVideoComposition:YES withDir:tempFolderURL];
            if(video)
            {
                [self.videos addObject:video];
            }
            NSLog(@"[Exported : Video index %d]",i+1);
        }
        
        //check status of builder
        if(self.transitions.count > 0)
            self.isAdvanced = YES;
        else
            self.isAdvanced = NO;
        
        self.isComposing = NO;
    }
}


#pragma mark - clear methods

- (void)clearAll
{
    [super clearAll];
    //clear transition data
    if(self.transitions.count > 0)
    {
        for(SCTransitionComposition *tranistion in self.transitions)
        {
            [tranistion clearAll];
        }
        [self.transitions removeAllObjects];
    }
    self.transitions = nil;
    
    
    //clear video data
    if(self.videos.count > 0)
    {
        for(SCVideoComposition *video in self.videos)
        {
            [video clearAll];
        }
        [self.videos removeAllObjects];
    }
    self.videos = nil;
    
    //clear slide data
    if(self.slides.count > 0)
    {
        for(SCSlideComposition *slide in self.slides)
        {
            [slide clearAll];
        }
        [self.slides removeAllObjects];
    }
    self.slides = nil;
    
    //clear audios data
    if(self.audios.count > 0)
    {
        for(SCAudioComposition *audio in self.audios)
        {
            [audio clearAll];
        }
        [self.audios removeAllObjects];
    }
    self.audios = nil;
    
    //clear music dât
    if(self.musics.count > 0)
    {
        
        for(SCAudioComposition *music in self.musics)
        {
            [music clearAll];
        }
        
        [self.musics removeAllObjects];
    }
    self.musics = nil;
    
    //clear other dât
    self.music = nil;
    self.audios = nil;
}



@end
