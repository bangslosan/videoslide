//
//  SCAudioRecordView.h
//  SlideshowCreator
//
//  Created 10/14/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"

@protocol SCAudioRecordViewProtocol <NSObject>

- (void)didFinishRecordingWith:(SCAudioComposition*)audioComposition;
- (void)startRecording;
- (void)stopRecording;
- (void)pauseRecord;
- (void)recordingWithDuration:(float)time;
- (void)reTake;
- (void)recordPlayBack;

@end

@interface SCAudioRecordView : SCView 


@property (nonatomic, weak) id<SCAudioRecordViewProtocol> delegate;

- (void)setStartTimeForRecording:(float)startTime;
- (void)stopRecording;
- (void)setRecordSessionWith:(BOOL)value;
- (void)startRecordingAudio;
- (void)startEditingAudioWith:(SCAudioComposition*)recordAudio playBack:(BOOL)canPlayBack;
- (void)deleteAudio;
@end

