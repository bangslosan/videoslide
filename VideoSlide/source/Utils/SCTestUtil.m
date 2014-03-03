//
//  SCTestUtil.m
//  SlideshowCreator
//
//  Created by Thi Huynh on 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCTestUtil.h"

@implementation SCTestUtil


+ (void)convertImageToVideo
{
    //getting a random path
    NSError *error;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[SCFileManager URLFromTempWithName:@"test.mov"] fileType:AVFileTypeQuickTimeMovie error: &error];
    
    
    NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInt:SC_VIDEO_SIZE.width], AVVideoCleanApertureWidthKey,
                                                [NSNumber numberWithInt:SC_VIDEO_SIZE.height], AVVideoCleanApertureHeightKey,
                                                [NSNumber numberWithInt:10], AVVideoCleanApertureHorizontalOffsetKey,
                                                [NSNumber numberWithInt:10], AVVideoCleanApertureVerticalOffsetKey,
                                                nil];
    
    
    NSDictionary *codecSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:980000], AVVideoAverageBitRateKey,
                                   [NSNumber numberWithInt:24],AVVideoMaxKeyFrameIntervalKey,
                                   videoCleanApertureSettings, AVVideoCleanApertureKey,
                                   nil];
    
    
    
    NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              AVVideoCodecH264, AVVideoCodecKey,
                                              codecSettings,AVVideoCompressionPropertiesKey,
                                              [NSNumber numberWithInt:SC_VIDEO_SIZE.width], AVVideoWidthKey,
                                              [NSNumber numberWithInt:SC_VIDEO_SIZE.height], AVVideoHeightKey,
                                              nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoCompressionSettings];

    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput: videoWriterInput
                                                     
                                                     sourcePixelBufferAttributes:nil];
    [videoWriter addInput: videoWriterInput];
    [videoWriter startWriting];
    
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    for(int i = 0;i < 30000;i ++)
    {
        CVPixelBufferRef buffer = NULL;
        buffer = [self pixelBufferFromCGImage:[[UIImage imageNamed:@"3.jpg"] CGImage] andSize:SC_VIDEO_SIZE];
        BOOL append_ok = NO;// [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
   
        while (!append_ok)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData){
                CMTime frameTime = CMTimeMake(i,(int32_t) 30);
                CMTimeShow(frameTime);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(buffer)
                    CVBufferRelease(buffer);
                //[NSThread sleepForTimeInterval:0.05];
            }else{
                //[NSThread sleepForTimeInterval:0.1];
            }
        }
    }
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    
    NSLog(@"************ write test video successful ************");
    
}

+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image andSize:(CGSize) size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,&pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

@end
