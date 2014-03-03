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


+ (NSURL*)trimAudioWith:(NSURL*)inputAudio with:(float)startTime endTime:(float)endTime
{
    
}

@end
