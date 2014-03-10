//
//  SCAudioUtil.m
//  SlideshowCreator
//
//  Created 9/13/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCAudioUtil.h"

@implementation SCAudioUtil



+(void)makeAudioFadeOutWithSourceURL:(NSURL*)sourceURL destinationURL:(NSURL*)destinationURL fadeOutBeginSecond:(NSInteger)beginTime fadeOutEndSecond:(NSInteger)endTime fadeOutBeginVolume:(CGFloat)beginVolume fadeOutEndVolume:(CGFloat)endVolume callback:(void(^)(BOOL))callback
{
    NSAssert(callback, @"need callback");
    NSParameterAssert(beginVolume >= 0 && beginVolume <=1);
    NSParameterAssert(endVolume >= 0 && endVolume <= 1);
    
    BOOL sourceExist = [[NSFileManager defaultManager] fileExistsAtPath:sourceURL.path];
    NSAssert(sourceExist, @"source not exist");
    
    AVURLAsset *asset = [AVAsset assetWithURL:sourceURL];
    
    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:asset.tracks.lastObject];
    
    [exportAudioMixInputParameters setVolumeRampFromStartVolume:beginVolume toEndVolume:endVolume timeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(beginTime, 1), CMTimeSubtract(CMTimeMakeWithSeconds(endTime, 1), CMTimeMakeWithSeconds(beginTime, 1)))];
    NSArray *audioMixParameters = @[exportAudioMixInputParameters];
    
    exportAudioMix.inputParameters = audioMixParameters;

    
    AVAssetExportSession* exporter = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    exporter.outputURL = destinationURL;
    exporter.outputFileType = AVFileTypeAppleM4A;
    exporter.audioMix = exportAudioMix;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        AVAssetExportSessionStatus status = exporter.status;
        if (status != AVAssetExportSessionStatusCompleted) {
            if (callback) {
                callback(NO);
            }
        }
        else {
            if (callback) {
                callback(YES);
            }
        }
        NSError *error = exporter.error;
        NSLog(@"export done,error %@,status %d",error,status);
    }];
}



#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)


+ (UIImage *) audioImageLogGraph:(Float32 *) samples
                   normalizeMax:(Float32) normalizeMax
                    sampleCount:(NSInteger) sampleCount
                   channelCount:(NSInteger) channelCount
                    imageHeight:(float) imageHeight {
    
    CGSize imageSize = CGSizeMake(sampleCount, imageHeight);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetAlpha(context,1.0);
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef leftcolor = [[UIColor whiteColor] CGColor];
    CGColorRef rightcolor = [[UIColor redColor] CGColor];
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0);
    
    float halfGraphHeight = (imageHeight / 2) / (float) channelCount ;
    float centerLeft = halfGraphHeight;
    float centerRight = (halfGraphHeight*3) ;
    float sampleAdjustmentFactor = (imageHeight/ (float) channelCount) / (normalizeMax - noiseFloor) / 2;
    
    for (NSInteger intSample = 0 ; intSample < sampleCount ; intSample ++ ) {
        Float32 left = *samples++;
        float pixels = (left - noiseFloor) * sampleAdjustmentFactor;
        CGContextMoveToPoint(context, intSample, centerLeft-pixels);
        CGContextAddLineToPoint(context, intSample, centerLeft+pixels);
        CGContextSetStrokeColorWithColor(context, leftcolor);
        CGContextStrokePath(context);
        
        if (channelCount==2) {
            Float32 right = *samples++;
            float pixels = (right - noiseFloor) * sampleAdjustmentFactor;
            CGContextMoveToPoint(context, intSample, centerRight - pixels);
            CGContextAddLineToPoint(context, intSample, centerRight + pixels);
            CGContextSetStrokeColorWithColor(context, rightcolor);
            CGContextStrokePath(context);
        }
    }
    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    
    return newImage;
}



+ (NSData *) renderPNGAudioPictogramLogForAssett:(AVURLAsset *)songAsset
{
    
    NSError * error = nil;
    
    AVAssetReader * reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    
    AVAssetTrack * songTrack = [songAsset.tracks objectAtIndex:0];
    
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        //     [NSNumber numberWithInt:44100.0],AVSampleRateKey, /*Not Supported*/
                                        //     [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,    /*Not Supported*/
                                        
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        
                                        nil];
    
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    
    [reader addOutput:output];
    [output release];
    
    UInt32 sampleRate,channelCount;
    
    NSArray* formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if(fmtDesc ) {
            
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
            
            //    NSLog(@"channels:%u, bytes/packet: %u, sampleRate %f",fmtDesc->mChannelsPerFrame, fmtDesc->mBytesPerPacket,fmtDesc->mSampleRate);
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    Float32 normalizeMax = noiseFloor;
    NSLog(@"normalizeMax = %f",normalizeMax);
    NSMutableData * fullSongData = [[NSMutableData alloc] init];
    [reader startReading];
    
    UInt64 totalBytes = 0;
    
    Float64 totalLeft = 0;
    Float64 totalRight = 0;
    Float32 sampleTally = 0;
    
    NSInteger samplesPerPixel = sampleRate / 50;
    
    while (reader.status == AVAssetReaderStatusReading){
        
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef){
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            
            NSAutoreleasePool *wader = [[NSAutoreleasePool alloc] init];
            
            NSMutableData * data = [NSMutableData dataWithLength:length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
            
            
            SInt16 * samples = (SInt16 *) data.mutableBytes;
            int sampleCount = length / bytesPerSample;
            for (int i = 0; i < sampleCount ; i ++) {
                
                Float32 left = (Float32) *samples++;
                left = decibel(left);
                left = minMaxX(left,noiseFloor,0);
                
                totalLeft  += left;
                
                
                
                Float32 right;
                if (channelCount==2) {
                    right = (Float32) *samples++;
                    right = decibel(right);
                    right = minMaxX(right,noiseFloor,0);
                    
                    totalRight += right;
                }
                
                sampleTally++;
                
                if (sampleTally > samplesPerPixel) {
                    
                    left  = totalLeft / sampleTally;
                    if (left > normalizeMax) {
                        normalizeMax = left;
                    }
                    // NSLog(@"left average = %f, normalizeMax = %f",left,normalizeMax);
                    
                    [fullSongData appendBytes:&left length:sizeof(left)];
                    
                    if (channelCount==2) {
                        right = totalRight / sampleTally;
                        
                        
                        if (right > normalizeMax) {
                            normalizeMax = right;
                        }
                        
                        [fullSongData appendBytes:&right length:sizeof(right)];
                    }
                    
                    totalLeft   = 0;
                    totalRight  = 0;
                    sampleTally = 0;
                    
                }
            }
            
            [wader drain];
            
            CMSampleBufferInvalidate(sampleBufferRef);
            
            CFRelease(sampleBufferRef);
        }
    }
    
    NSData * finalData = nil;
    
    if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown){
        // Something went wrong. Handle it.
    }
    
    if (reader.status == AVAssetReaderStatusCompleted){
        // You're done. It worked.
        
        NSLog(@"rendering output graphics using normalizeMax %f",normalizeMax);
        
        UIImage *test = [self audioImageLogGraph:(Float32 *) fullSongData.bytes 
                                    normalizeMax:normalizeMax 
                                     sampleCount:fullSongData.length / (sizeof(Float32) * 2) 
                                    channelCount:1
                                     imageHeight:80 ];
        
        finalData = imageToData(test);
    }        
    
    [fullSongData release];
    [reader release];
    
    return finalData;
}


@end
