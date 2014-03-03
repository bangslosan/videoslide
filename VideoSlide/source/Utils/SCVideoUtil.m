//
//  SCVideoUtil.m
//  SlideshowCreator
//
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVideoUtil.h"


@implementation SCVideoUtil


/*
 *Create a video with an image by providing slide composition, and output file URL for export video
 *@param  slide         : slide to create static video
 *@param  output        : output URL for video result
 */

+ (void)createVideoWith:(SCSlideComposition *)slide output:(NSURL *)output FPS:(float)FPS
{
    NSLog(@"************ start write standard video ************");
    CGSize size = SC_VIDEO_SIZE;
    float startTime = CMTimeGetSeconds(slide.startTransition.duration);
    float endTime = CMTimeGetSeconds(CMTimeSubtract(slide.timeRange.duration, slide.endTransition.duration));
    float duration  = CMTimeGetSeconds(slide.timeRange.duration);

    //getting a random path
    NSError *error;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:output fileType:SC_MEDIA_TYPE_MOV error: &error];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput: videoWriterInput
                                                     
                                                     sourcePixelBufferAttributes:nil];
    [videoWriter addInput: videoWriterInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //notice to create buffer at one time
    CVPixelBufferRef buffer1 = NULL;
    CVPixelBufferRef buffer2 = NULL;

    if(!slide.filterComposition.filteredImage)
        buffer1 = [self videoPixelBufferFromCGImage:slide.image.CGImage andSize:SC_VIDEO_SIZE];
    else
        buffer1 = [self videoPixelBufferFromCGImage:slide.filterComposition.filteredImage.CGImage andSize:SC_VIDEO_SIZE];

    buffer2 = [self videoPixelBufferFromCGImage:slide.imageWithText.CGImage andSize:SC_VIDEO_SIZE];

    if(duration == FPS && FPS == 1)
    {
        FPS = 2;
    }
    NSLog(@"FPS : %d",(int)FPS);

    for(int i = 0;i < FPS * duration;i ++)
    {
        BOOL append_ok = NO;
        
        while (!append_ok)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                CMTime frameTime = CMTimeMake(i,(int32_t)FPS);
                CMTimeShow(frameTime);
                if(FPS*startTime < i && i < FPS * endTime)
                    append_ok = [adaptor appendPixelBuffer:buffer2 withPresentationTime:frameTime];
                else
                    append_ok = [adaptor appendPixelBuffer:buffer1 withPresentationTime:frameTime];
            }
            else
            {
                NSLog(@"Asset writter Not ready");
            }
        }
    }
    
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    
    videoWriter = nil;
    if(buffer1 != NULL)
        CVPixelBufferRelease(buffer1);
    if(buffer2 != NULL)
        CVPixelBufferRelease(buffer2);
    NSLog(@"************ write standard video successful ************");
    
}

/*
*Create a video with an image by providing size, and output file URL for export video
*@param  backgroundImg : image to create static video
*@param  size          : size for the video (resolution)
*@param  output        : output URL for video result
*/
+ (void)createStandardVideoWith:(UIImage*)backgroundImg  size:(CGSize)size time:(float)time output:(NSURL*)output FPS:(float)FPS
{
    NSLog(@"************ start write standard video ************");
    //getting a random path
    NSError *error;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:output fileType:SC_MEDIA_TYPE_MOV error: &error];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput: videoWriterInput
                                                     
                                                     sourcePixelBufferAttributes:nil];
    [videoWriter addInput: videoWriterInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //notice to create buffer at one time
    CVPixelBufferRef buffer = NULL;
    buffer = [self videoPixelBufferFromCGImage:backgroundImg.CGImage andSize:SC_VIDEO_SIZE];
    
    if(time == FPS && FPS == 1)
    {
        FPS = 2;
    }
    NSLog(@"FPS : %d",(int)FPS);
    for(int i = 0;i < FPS * time;i ++)
    {
        BOOL append_ok = NO;// [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
        
        while (!append_ok)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                CMTime frameTime = CMTimeMake(i,(int32_t)FPS);
                CMTimeShow(frameTime);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                //[NSThread sleepForTimeInterval:0.01];
            }
            else
            {
                //[NSThread sleepForTimeInterval:0.01];
                NSLog(@"Asset writter Not ready");
            }
        }
    }
    
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    
    videoWriter = nil;
    if(buffer != NULL)
        CVPixelBufferRelease(buffer);
    NSLog(@"************ write standard video successful ************");
    
}


/*
 *Create a video with an image by providing size, and output file URL for compose video
 *@param  backgroundImg : image to create static video
 *@param  size          : size for the video (resolution)
 *@param  output        : output URL for video result
 */
+ (void)createVideoWith:(UIImage*)backgroundImg  size:(CGSize)size time:(float)time output:(NSURL*)output
{
    NSLog(@"************ start write video ************");
    //getting a random path
    NSError *error;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:output fileType:SC_MEDIA_TYPE_MOV error: &error];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput: videoWriterInput
                                                     
                                                     sourcePixelBufferAttributes:nil];
    [videoWriter addInput: videoWriterInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    float fps = SC_VIDEO_BASIC_RENDER_FPS;
    if(time == 1)
    {
        fps = SC_VIDEO_BASIC_RENDER_FPS * 2;
    }
    
    //notice to create buffer at one time
    CVPixelBufferRef buffer = NULL;
    buffer = [self videoPixelBufferFromCGImage:backgroundImg.CGImage andSize:SC_VIDEO_SIZE];
    for(int i = 0;i < fps * time;i ++)
    {
        BOOL append_ok = NO;// [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
        
        while (!append_ok)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                CMTime frameTime = CMTimeMake(i,(int32_t)fps);
                CMTimeShow(frameTime);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                //[NSThread sleepForTimeInterval:0.01];
            }
            else
            {
                //[NSThread sleepForTimeInterval:0.01];
                NSLog(@"Asset writter Not ready");
            }
        }
    }
    
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    
    videoWriter = nil;
    if(buffer != NULL)
        CVPixelBufferRelease(buffer);
    NSLog(@"************ write video successful ************");
    
}



/*
 *Create a video with an array of images by providing size, and output file URL
 *@param  images        : image arrays to create static video
 *@param  size          : size for the video (resolution)
 *@param  output        : output URL for video result
 */

+ (void)createVideoWithArrayImages:(NSMutableArray*)images  size:(CGSize)size time:(float)time output:(NSURL*)output;
{
    //getting a random path
    NSError *error;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:output fileType:SC_MEDIA_TYPE_MOV error: &error];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput: videoWriterInput
                                                     
                                                     sourcePixelBufferAttributes:nil];
    [videoWriter addInput: videoWriterInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    CVPixelBufferRef buffer = NULL;
    //convert uiimage to CGImage.
    
    //convert uiimage to CGImage.
    NSInteger fps = 30;
    int frameCount = 0;
    
    for(UIImage *img  in images)
    {
        //for(VideoFrame * frm in imageArray)
        NSLog(@"**************************************************");
        //UIImage * img = frm._imageFrame;
        buffer = [self videoPixelBufferFromCGImage:[img CGImage] andSize:size];
        double numberOfSecondsPerFrame = time / images.count;
        double frameDuration = fps * numberOfSecondsPerFrame;
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < fps)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                //print out status:
                NSLog(@"Processing video frame (%d,%d)",frameCount,[images count]);
                
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok)
                {
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else
            {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok)
        {
            printf("error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
        NSLog(@"**************************************************");
    }
    
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    
    videoWriter = nil;
    if(buffer != NULL)
        CVPixelBufferRelease(buffer);
    NSLog(@"************ write standard video successful ************");

}

/*
 *Create a video with an array of images by providing size, and output file URL
 *@param  slideShow        : slide show of image to create video 
 *
 */

+ (void)createVideoWithSlideShow:(SCSlideShowComposition*)slideShow output:(NSURL*)output
{
    
    if(slideShow.slides.count == 0)
        return;
    NSError *error = nil;
    CGSize size = slideShow.model.videoSize;
    
    NSLog(@"Write Started");

    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  output fileType:SC_MEDIA_TYPE_MOV error:&error];
    NSParameterAssert(videoWriter);
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    //convert uiimage to CGImage.
    
    //convert uiimage to CGImage.
    NSInteger fps = 30;
    int frameCount = 0;

    for(SCSlideComposition * slide in slideShow.slides)
    {
        //for(VideoFrame * frm in imageArray)
        NSLog(@"**************************************************");
        //UIImage * img = frm._imageFrame;
        buffer = [self videoPixelBufferFromCGImage:[slide.image CGImage] andSize:size];
        double numberOfSecondsPerFrame = CMTimeGetSeconds( slide.timeRange.duration);
        double frameDuration = fps * numberOfSecondsPerFrame;
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < fps)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                //print out status:
                NSLog(@"Processing video frame (%d,%d)",frameCount,[slideShow.slides count]);
                
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok)
                {
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else
            {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok)
        {
            printf("error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
        NSLog(@"**************************************************");
    }
    
    //Finish the session:
    [videoWriterInput markAsFinished];
    //[videoWriter finishWritingWithCompletionHandler:nil];
    NSLog(@"Write Ended");

}


+ (CVPixelBufferRef)videoPixelBufferFromCGImage: (CGImageRef) image andSize:(CGSize) size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, size.width,
                                           size.height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


+ (void)resizeVideoWith:(NSURL*)source des:(NSURL*)des
{
    NSURL *fullPath = des;
    NSURL *path = source;
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:fullPath fileType:SC_MEDIA_TYPE_MOV error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:480], AVVideoWidthKey,
                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                             assetWriterInputWithMediaType:AVMediaTypeVideo
                                             outputSettings:videoSettings];
    
    //add video input
    
    videoWriterInput.expectsMediaDataInRealTime = NO;
    [videoWriter addInput:videoWriterInput];
    
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:path options:nil];
    NSError *aerror = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&aerror];
    
    AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
    
    NSDictionary *videoOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    AVAssetReaderTrackOutput *asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
    [reader addOutput:asset_reader_output];
    
    //add audio
    AVAssetWriterInput *audioWriterInput;
    AVAssetReader *audioReader;
    AVAssetTrack *audioTrack;
    AVAssetReaderOutput *audioReaderOutput;
    if ([[avAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
    {
        audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
        audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:nil];
        audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        [audioReader addOutput:audioReaderOutput];
        [videoWriter addInput:audioWriterInput];
    }
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    [reader startReading];
    
    CMSampleBufferRef buffer;
    while ( [reader status]==AVAssetReaderStatusReading )
    {
        if(![videoWriterInput isReadyForMoreMediaData])
            continue;
        
        buffer = [asset_reader_output copyNextSampleBuffer];
        if(buffer)
            [videoWriterInput appendSampleBuffer:buffer];
    }
    //Finish the session:
    [videoWriterInput markAsFinished];
    if (audioWriterInput)
    {
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        [audioReader startReading];
        
        while (audioWriterInput.readyForMoreMediaData)
        {
            CMSampleBufferRef audioSampleBuffer;
            if ([audioReader status] == AVAssetReaderStatusReading &&
                (audioSampleBuffer = [audioReaderOutput copyNextSampleBuffer]))
            {
                if (audioSampleBuffer)
                {
                    printf("write audio  ");
                    [audioWriterInput appendSampleBuffer:audioSampleBuffer];
                }
                CFRelease(audioSampleBuffer);
            }
            else
            {
                [audioWriterInput markAsFinished];
                switch ([audioReader status])
                {
                    case AVAssetReaderStatusCompleted:
                    {
                        
                    }
                }
            }
        }
    }
    [videoWriter endSessionAtSourceTime:avAsset.duration];
    [videoWriter finishWriting];
    NSLog(@"Write Ended");
    
}


@end
