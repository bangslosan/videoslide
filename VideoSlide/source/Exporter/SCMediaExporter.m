//
//  SCMediaExporter.m
//  SlideshowCreator
//
//  Created 9/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCMediaExporter.h"
#import "SCAdvancedMediaBuilder.h"

@interface SCMediaExporter () 

@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) NSTimer              *exportTimer;


- (void)monitorExportProgress;
- (void)writeExportedVideoToAssetsLibrary;
- (void)buildVideoWith:(SCSlideShowComposition *)slideShow;
- (void)finishBuildVideo;

@end

@implementation SCMediaExporter

@synthesize delegate  =_delegate;
@synthesize needToWriteToCameraRoll = _needToWriteToCameraRoll;
@synthesize mediaExportQuality = _mediaExportQuality;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.needToWriteToCameraRoll = NO;
    }
    
    return self;
}

#pragma mark - public methods

- (void)exportMediaWithSlideShow:(SCSlideShowComposition *)slideShow
{
    if(CMTimeGetSeconds(slideShow.totalDuration) <= SC_VIDEO_VINE_DURATION)
    {
        [slideShow preExportAsynchronouslyWithCompletionHandler:^
         {
             if([self.delegate respondsToSelector:@selector(didFinishPreExportWithSuccess:)])
             {
                 [self.delegate didFinishPreExportWithSuccess:YES];
             }
             [self buildVideoWith:slideShow];

         }];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(didFinishPreExportWithSuccess:)])
        {
            [self.delegate didFinishPreExportWithSuccess:YES];
        }
        [self buildVideoWith:slideShow];
    }
  

}


#pragma mark - private methods

- (void)buildVideoWith:(SCSlideShowComposition *)slideShow
{
    NSString *quality = AVAssetExportPresetHighestQuality;
    if([slideShow.mediaExportQuality isEqualToString:NSLocalizedString(@"Hight", nil)])
        quality = AVAssetExportPresetHighestQuality;
    else if([slideShow.mediaExportQuality isEqualToString:NSLocalizedString(@"Medium", nil)])
        quality = AVAssetExportPresetMediumQuality;
    else if([slideShow.mediaExportQuality isEqualToString:NSLocalizedString(@"Low", nil)])
        quality = AVAssetExportPresetLowQuality;

    if(slideShow.isAdvanced)
    {
        SCAdvancedMediaBuilder *mediaBuilder = [[SCAdvancedMediaBuilder alloc] initWithSlideShow:slideShow];
        SCAdvancedBuilderComposition *composition = [mediaBuilder buildMediaComposition];
        self.exportSession = [composition makeExportable:quality];
    }
    else
    {
        SCBasicMediaBuilder *mediaBuilder = [[SCBasicMediaBuilder alloc]initWithSlideShow:slideShow];
        SCBasicBuilderComposition *composition = [mediaBuilder  buildMediaComposition];
        self.exportSession = [composition makeExportable:quality];
    }
    
    //check for exporting to project or export to cameraroll
    if(slideShow.exportURL)
    {
        self.exportSession.outputURL = [SCFileManager urlFromDir:slideShow.exportURL withName:[NSString stringWithFormat:@"%@.%@", slideShow.name, SC_MOV]];
    }
    else
    {
        NSURL *exportURL = [SCFileManager URLFromTempWithName:[NSString stringWithFormat:@"%@.%@", slideShow.name,SC_MOV]];
        if([SCFileManager exist:exportURL])
        {
            [SCFileManager deleteFileWithURL:exportURL];
        }
        self.exportSession.outputURL = exportURL;
    }
	self.exportSession.outputFileType = SC_MEDIA_TYPE_MOV;
    
    if([SCFileManager exist:self.exportSession.outputURL])
    {
        [SCFileManager deleteFileWithURL:self.exportSession.outputURL];
    }
	[self.exportSession exportAsynchronouslyWithCompletionHandler:^ {
		dispatch_async(dispatch_get_main_queue(), ^
        {
            //finish the exporting session with 100% progress value
            if([self.delegate respondsToSelector:@selector(percentOfExportProgress:)])
                [self.delegate percentOfExportProgress:1];
            [self finishBuildVideo];
        
        });
	}];
    
    //monitoring the export session
    [self monitorExportProgress];

}

- (void)monitorExportProgress
{
	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	__weak id weakSelf = self;
	dispatch_after(popTime, dispatch_get_main_queue(), ^
    {
		AVAssetExportSessionStatus status = [weakSelf exportSession].status;
		if (status == AVAssetExportSessionStatusExporting)
        {
            [weakSelf monitorExportProgress];
            NSLog(@"[Export Session]Exporting ... [ %.2f percent]",[weakSelf exportSession].progress * 100);
            if([self.delegate respondsToSelector:@selector(percentOfExportProgress:)])
                [self.delegate percentOfExportProgress:[weakSelf exportSession].progress];
            
		}
        else if (status == AVAssetExportSessionStatusCompleted)
        {
			NSLog(@"[Export Session]Export Success");
		}
        else if (status == AVAssetExportSessionStatusFailed)
        {
			NSLog(@"[Export Session]Compose Failed");
            
		}
        else if (status == AVAssetExportSessionStatusCancelled)
        {
			NSLog(@"[Export Session]Export Cancel");
		}
        else if (status == AVAssetExportSessionStatusWaiting)
        {
			NSLog(@"[Export Session]Export Waiting");
            [weakSelf monitorExportProgress];
            NSLog(@"[Export Session]Exporting ... [ %.2f percent]",[weakSelf exportSession].progress * 100);
            if([self.delegate respondsToSelector:@selector(percentOfExportProgress:)])
                [self.delegate percentOfExportProgress:[weakSelf exportSession].progress];

		}
        else if (status == AVAssetExportSessionStatusUnknown)
        {
			NSLog(@"[Export Session]Export Unknow");
		}
	});
}


- (void)finishBuildVideo
{
    if(self.exportSession.status == AVAssetExportSessionStatusCompleted)
    {
        if([self.delegate respondsToSelector:@selector(didFinishExportVideoWithSuccess:)])
            [self.delegate didFinishExportVideoWithSuccess:YES];
        
        //check if there is needed to write  video to camera roll
        if(self.needToWriteToCameraRoll)
            [self writeExportedVideoToAssetsLibrary];
    }
    else if(self.exportSession.status == AVAssetExportSessionStatusFailed ||
            self.exportSession.status == AVAssetExportSessionStatusUnknown ||
            self.exportSession.status == AVAssetExportSessionStatusCancelled)
    {
        if([self.delegate respondsToSelector:@selector(didFinishExportVideoWithSuccess:)])
            [self.delegate didFinishExportVideoWithSuccess:NO];
    }
    
}


- (void)writeExportedVideoToAssetsLibrary
{
	NSURL *exportURL = self.exportSession.outputURL;
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL])
    {
		[library writeVideoAtPathToSavedPhotosAlbum:exportURL completionBlock:^(NSURL *assetURL, NSError *error)
        {
			dispatch_async(dispatch_get_main_queue(), ^
            {
				if (error)
                {
                    if([self.delegate respondsToSelector:@selector(didFinishWriteToLibraryWithSuccess:)])
                    {
                        [self.delegate didFinishWriteToLibraryWithSuccess:NO];
                    }
				}
                else
                {
                    
                    if([self.delegate respondsToSelector:@selector(didFinishWriteToLibraryWithSuccess:)])
                    {
                        [self.delegate didFinishWriteToLibraryWithSuccess:YES];
                    }

                }

            });
		}];
	}
    else
    {
		NSLog(@"Video could not be exported to assets library.");
	}
}


@end
