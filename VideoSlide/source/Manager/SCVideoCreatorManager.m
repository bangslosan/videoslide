//
//  SCVideoCreatorManager.m
//  SlideshowCreator
//
//  Created 9/10/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVideoCreatorManager.h"
#import "SCTextModel.h"

static SCVideoCreatorManager *instance;


@interface SCVideoCreatorManager () <MBProgressHUDDelegate>

@property (nonatomic, strong)  MBProgressHUD *HUD;
@property (nonatomic, strong)  NSTimer       *exportTimer;
@property (nonatomic, strong) AVAssetExportSession *exporter;

- (void)exportVideoWithAsset:(AVMutableComposition*)asset compositionIns:(AVVideoComposition*)compositionIns output:(NSURL*)url quality:(NSString*)quality;
- (void)addAudioTrackWith:(SCAudioModel*)model into:(AVMutableComposition*)mixComposition;
- (void)addVideoTrackWith:(AVAsset*)videoAsset into:(AVMutableComposition*)mixComposition;
- (void)createSlideShowWith:(NSMutableArray*)slides into:(AVMutableVideoComposition*)videoComposition;
- (NSMutableArray*)layerInstructionsWith:(AVAsset*)videoAsset;

@end

@implementation SCVideoCreatorManager

@synthesize isInProgress;
- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

+ (SCVideoCreatorManager*)getInstance
{
    @synchronized([SCVideoCreatorManager class])
    {
        if(!instance)
            instance = [[self alloc] init];
        return instance;
    }
    
    return nil;
}


#pragma mark - class methods

- (void)addVideoTrackWith:(AVAsset*)videoAsset into:(AVMutableComposition*)mixComposition;
{
    if (!videoAsset) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Load a Video Asset First"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //Add video track into composition
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];

}
- (void)addAudioTrackWith:(SCAudioModel*)model into:(AVMutableComposition*)mixComposition
{
    AVAsset *audioAsset;
    if(model.name)
    {
        audioAsset = [AVURLAsset assetWithURL:[SCFileManager URLFromTempWithName:model.name]];
        if(audioAsset)
        {
            AVMutableCompositionTrack *track = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                 preferredTrackID:kCMPersistentTrackID_Invalid];
            [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                 ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                  atTime:kCMTimeZero error:nil];
        }
    }
}

- (NSMutableArray*)layerInstructionsWith:(AVAsset*)videoAsset
{
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    CGAffineTransform start = CGAffineTransformIdentity;
    CGAffineTransform end =  CGAffineTransformMakeTranslation(960, 0);
    [videolayerInstruction setTransformRampFromStartTransform:start toEndTransform:end timeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)];
    
    return [NSMutableArray arrayWithObject:videolayerInstruction];
}

- (void)createSlideShowWith:(NSMutableArray*)slides into:(AVMutableVideoComposition*)videoComposition
{
    CGSize size = videoComposition.renderSize;
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer setMasksToBounds:YES];
    [parentLayer setContents:(id)[[UIImage imageNamed:@"1.jpg"] CGImage]];//[[SCImageUtil imageWithColor:[UIColor blackColor] size:size] CGImage]];

    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    //[parentLayer addSublayer:videoLayer];

    float totalTime = 0;
    int i=1;
    
    for(SCSlideComposition *slide in slides)
    {
        // 1 - preapare layer
        CALayer *layer = [CALayer layer];
        [layer setContents:(id)[slide.image CGImage]];
        i++;
        layer.frame = CGRectMake(0, 0, size.width, size.height);
        [layer setMasksToBounds:YES];
        layer.opacity = 0;
        
        // 2 - add text
        if(slide.model.textArray.count > 0)
        {
            for(SCTextModel *model in slide.model.textArray)
            {
                CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
                [subtitle1Text setFont:@"Helvetica-Bold"];
                [subtitle1Text setFontSize:model.fontSize];
                [subtitle1Text setFrame:CGRectMake(0, size.height - 100, size.width, 100)];
                [subtitle1Text setString:model.text];
                [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
                [subtitle1Text setForegroundColor:[[SCHelper colorFromSCColor:model.color] CGColor]];
                [layer addSublayer:subtitle1Text];
            }
        }
        
        // 3 - transition and animation
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.beginTime  = AVCoreAnimationBeginTimeAtZero + totalTime;
        group.duration   = slide.model.duration + slide.model.startTrans.duration + slide.model.endTrans.duration;
        totalTime += group.duration;
        
        // 4 - create animation for transisiton + performance
        NSMutableArray *animations = [NSMutableArray array];
        
        float appearTime    = slide.model.startTrans.duration;
        float disappearTime = slide.model.endTrans.duration;
        float showTime      = slide.model.duration;

    
        if(slide.model.startTrans)
        {
            CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeIn.duration = appearTime;
            fadeIn.fromValue=[NSNumber numberWithFloat:0];
            fadeIn.toValue=[NSNumber numberWithFloat:1];
            fadeIn.beginTime = AVCoreAnimationBeginTimeAtZero;
            [animations addObject:fadeIn];
        }
        
        if(slide.model.duration > 0)
        {
            CABasicAnimation *show = [CABasicAnimation animationWithKeyPath:@"opacity"];
            show.duration = showTime;
            show.fromValue=[NSNumber numberWithFloat:1];
            show.toValue=[NSNumber numberWithFloat:1];
            show.beginTime = appearTime;
            [animations addObject:show];
        }
        
        if(slide.model.endTrans)
        {
            CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeOut.duration = disappearTime;
            fadeOut.fromValue=[NSNumber numberWithFloat:1];
            fadeOut.toValue=[NSNumber numberWithFloat:0];
            fadeOut.beginTime = appearTime + showTime;
            [animations addObject:fadeOut];
        }
        [group setAnimations:animations];
        [layer addAnimation:group forKey:nil];
        [parentLayer addSublayer:layer];
    }
    
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];

}


#pragma mark - generation video by combining all composositions

- (void)generateVideoWith:(SCSlideShowComposition*)slideShow
{
    AVAsset *videoAsset;
    
    // 1 : create blank video for slideshow and create mix composition
   /* [SCVideoUtil createVideoWith:[SCImageUtil imageWithColor:[UIColor colorWithRed:slideShow.model.backgroundColor.red
                                                                                  green:slideShow.model.backgroundColor.green
                                                                                   blue:slideShow.model.backgroundColor.blue
                                                                                  alpha:slideShow.model.backgroundColor.alpha]
                                                             size:slideShow.model.screenSize]
                                 size:slideShow.model.screenSize
                                 time:slideShow.model.duration
                               output:[SCFileManager createURLFromTempWithName:SC_TEMP_BLANK_VIDEO]];*/
    
    [SCVideoUtil createVideoWith:[UIImage imageNamed:@"1.jpg"]
                                 size:slideShow.model.videoSize
                                 time:slideShow.model.duration
                               output:[SCFileManager createURLFromTempWithName:SC_TEMP_BLANK_VIDEO]];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], AVURLAssetPreferPreciseDurationAndTimingKey, nil];
    videoAsset = [AVURLAsset URLAssetWithURL:[SCFileManager URLFromTempWithName:SC_TEMP_BLANK_VIDEO] options:options];

    // 2 - add vide track
    [self addVideoTrackWith:videoAsset into:mixComposition];
    // 3 - Audio track
    [self addAudioTrackWith:slideShow.model.recordModel into:mixComposition];
    // 4 -  Music track
    [self addAudioTrackWith:slideShow.model.musicModel into:mixComposition];
    
    // 5 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    //mainInstruction.backgroundColor = [SCHelper colorFromSCColor:slideShow.model.backgroundColor].CGColor;
    mainInstruction.layerInstructions = [self layerInstructionsWith:videoAsset];

    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.renderSize = slideShow.model.videoSize;
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);

    
    // 6 - Create slide show and animation + text into blank video
    //[self createSlideShowWith:slideShow.slides into:mainCompositionInst];
    
    // 7 - Get path to export
    NSURL *url = [SCFileManager createURLFromTempWithName:slideShow.model.name];
    [self exportVideoWithAsset:mixComposition compositionIns:mainCompositionInst output:url quality:nil];
    
}


- (void)exportVideoWithAsset:(AVMutableComposition*)asset compositionIns:(AVVideoComposition*)compositionIns output:(NSURL*)url quality:(NSString*)quality
{
    // 5 - Create exporter
    self.exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    self.exporter.outputURL=url;
    self.exporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.exporter.shouldOptimizeForNetworkUse = YES;
    self.exporter.videoComposition = compositionIns;
    
    self.HUD = [[MBProgressHUD alloc] initWithView:[SCScreenManager getInstance].rootViewController.view];
	[[SCScreenManager getInstance].rootViewController.view addSubview:self.HUD];
	
	// Set determinate bar mode
	self.HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
	self.HUD.delegate = self;
    [self.HUD show:YES];
    if(self.exportTimer)
    {
        [self.exportTimer invalidate];
        self.exportTimer  = nil;
    }
    
    self.exportTimer = [NSTimer scheduledTimerWithTimeInterval:0.018 target:self selector:@selector(exportTick:) userInfo:nil repeats:YES];
	// myProgressTask uses the HUD instance to update progress
    [self.exporter exportAsynchronouslyWithCompletionHandler:^
     {
        dispatch_async(dispatch_get_main_queue(),^
        {
            [self exportDidFinish:self.exporter];
        });
     }];
}

- (void)exportDidFinish:(AVAssetExportSession*)session {
    if (session.status == AVAssetExportSessionStatusCompleted)
    {
        if(self.HUD)
        {
            if(self.HUD.superview)
                [self.HUD removeFromSuperview];
            self.HUD = nil;
        }
        
        self.HUD = [[MBProgressHUD alloc] initWithView:[SCScreenManager getInstance].rootViewController.view];
        [[SCScreenManager getInstance].rootViewController.view addSubview:self.HUD];
        //self.HUD.delegate = self;
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = @"Saving to Camera Roll";
        self.HUD.minSize = CGSizeMake(150.f, 150.f);
        [self.HUD show:YES];

        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(self.HUD)
                    {
                        if(self.HUD.superview)
                            [self.HUD removeFromSuperview];
                        self.HUD = nil;
                    }
                    self.HUD = [[MBProgressHUD alloc] initWithView:[SCScreenManager getInstance].rootViewController.view];
                    [[SCScreenManager getInstance].rootViewController.view addSubview:self.HUD];
                    
                    if (error)
                    {
                        // Set custom view mode
                        self.HUD.mode = MBProgressHUDModeCustomView;
                        
                        self.HUD.delegate = self;
                        self.HUD.labelText = @"Failed";
                        
                        [self.HUD show:YES];
                        [self.HUD hide:YES afterDelay:3];

                    } else {
                        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SC_IMG_HUD_FINISH_CHECK]];
                        
                        // Set custom view mode
                        self.HUD.mode = MBProgressHUDModeCustomView;
                        
                        self.HUD.delegate = self;
                        self.HUD.labelText = @"Completed";
                        
                        [self.HUD show:YES];
                        [self.HUD hide:YES afterDelay:3];

                    }
                    
                    if(!error)
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Saved to Camera Roll"
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        }
    }
}

- (void)exportTick:(id)sender
{
    self.HUD.progress = self.exporter.progress;
    if(self.HUD.progress == 1)
    {
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}


#pragma - mark MBProgressbar delegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[self.HUD removeFromSuperview];
	self.HUD = nil;
}


@end
