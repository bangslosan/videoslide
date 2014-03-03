//
//  SCAudioRecordView.m
//  SlideshowCreator
//
//  Created 10/14/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCAudioRecordView.h"

#define SC_PEAK_POWER_FULL_WIDTH        196
#define SC_PEAK_POWER_TOTAL_CELL        28
#define SC_PEAK_POWER_UNIT_WIDTH        7

@interface SCAudioRecordView ()  <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
{
    double lowPassResults;
}

@property (nonatomic, strong) IBOutlet UIView       *toolBarView;
@property (nonatomic, strong) IBOutlet UIView       *peakPowerView;
@property (nonatomic, strong) IBOutlet UIView       *statusView;
@property (nonatomic, strong) IBOutlet UIView       *editView;

@property (nonatomic, strong) IBOutlet UILabel      *statusLb;
@property (nonatomic, strong) IBOutlet UIButton     *cancelBtn;
@property (nonatomic, strong) IBOutlet UIButton     *retakeBtn;
@property (nonatomic, strong) IBOutlet UIButton     *previewBtn;
@property (nonatomic, strong) IBOutlet UIButton     *acceptBtn;
@property (nonatomic, strong) IBOutlet UIButton     *recordBtn;
@property (nonatomic, strong) IBOutlet UISlider     *volumeSlider;
@property (nonatomic, strong) IBOutlet UIButton     *playBtn;


@property (nonatomic, strong) NSURL                 *monitorTmpFile;
@property (nonatomic, strong) NSURL                 *recordedTmpFile;
@property (nonatomic, strong) NSURL                 *recordLastFile;
@property (nonatomic, strong) AVAudioRecorder       *recorder;
@property (nonatomic, strong) AVAudioRecorder       *audioMonitor;
@property (nonatomic, strong) AVAudioPlayer			*musicPlayer;
@property (nonatomic, strong) NSTimer               *levelTimer;
@property (nonatomic, strong) SCAudioComposition    *audioComposition;



@property (nonatomic)         BOOL                  isRecording;
@property (nonatomic)         BOOL                  isMonitoring;
@property (nonatomic)         BOOL                  isPlaying;
@property (nonatomic)         BOOL                  isPause;

@property (nonatomic)         float                 startRecordingTime;
@property (nonatomic)         float                 secondStartRecordingTime;

@property (nonatomic)         double                 audioMonitorResults;

- (IBAction)onCancelBtn:(id)sender;
- (IBAction)onReTakeBtn:(id)sender;
- (IBAction)onPreviewBtn:(id)sender;
- (IBAction)onAcceptBtn:(id)sender;
- (IBAction)onRecordBtn:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onDoneBtn:(id)sender;
- (IBAction)onPlay:(id)sender;
- (IBAction)onChangeVolume:(id)sender;


-(void) initAudioMonitor;
-(void) initRecorder;

@end

@implementation SCAudioRecordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCAudioRecordView" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        self.startRecordingTime = -1;
        self.secondStartRecordingTime = -1;
        self.isPlaying = NO;
        self.isRecording = NO;
        self.isPause = NO;
        self.isMonitoring = NO;
        //start recore session
        [self setRecordSessionWith:YES];
        
#if TARGET_IPHONE_SIMULATOR
        
#else
        [self initAudioMonitor];
#endif
    }
    
    return self;
}

- (void)awakeFromNib
{
    if(!SC_IS_IPHONE5)
    {
        self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y, 320, 480);
        self.toolBarView.frame = CGRectMake(0, 233, self.toolBarView.frame.size.width, self.toolBarView.frame.size.height);
        self.statusView.frame = CGRectMake(self.statusView.frame.origin.x,100, self.statusView.frame.size.width, self.statusView.frame.size.height);
    }
    else
    {
        if(!IS_OS_7_OR_LATER)
            self.toolBarView.frame = CGRectMake(0, self.toolBarView.frame.origin.y - 20, self.toolBarView.frame.size.width, self.toolBarView.frame.size.height);

    }
    [self.previewBtn setEnabled:NO];
    [self.retakeBtn setEnabled:NO];
    [self.acceptBtn setEnabled:NO];
}

-(void) initAudioMonitor
{
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    self.audioMonitor = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (self.audioMonitor)
    {
        [self.audioMonitor prepareToRecord];
        self.audioMonitor.meteringEnabled = YES;
        [self.audioMonitor record];
        
        self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.018 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        self.isMonitoring = YES;
        
        //update label status
        self.statusLb.text = SC_MESSAGE_RECORD_READY;
    }
}

- (void) initRecorder
{
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    if(!self.recordedTmpFile)
    {
        self.recordedTmpFile = [SCFileManager createIncreaseNameFromTempWith:SC_AUDIO_RECORD andtype:SC_M4A];
        // Initiate and prepare the recorder
        self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordedTmpFile settings:recordSetting error:nil];
    }
    else if([SCFileManager exist:self.recordedTmpFile])
    {
        self.recordLastFile = [SCFileManager createIncreaseNameFromTempWith:SC_AUDIO_RECORD andtype:SC_M4A];
        // Initiate and prepare the recorder
        self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordLastFile settings:recordSetting error:nil];
    }
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];

}

- (void)clearAll
{
    [super clearAll];
    
    if(self.musicPlayer)
    {
        [self.musicPlayer stop];
        self.musicPlayer = nil;
    }
    
    if(self.audioMonitor.isRecording)
    {
        [self.audioMonitor stop];
    }
    self.audioMonitor  = nil;

    
    if(self.recorder.isRecording)
    {
        [self.recorder stop];
    }
    self.recorder = nil;
    
    if(self.levelTimer.isValid)
    {
        [self.levelTimer invalidate];
        self.levelTimer = nil;
    }
    
    self.delegate = nil;
}


#pragma mark - instance methods

- (void)deleteAudio
{
    [SCFileManager deleteFileWithURL:self.recordedTmpFile];
    [SCFileManager deleteFileWithURL:self.recordLastFile];
    [self.audioComposition clearAll];
    self.audioComposition = nil;

    self.recordedTmpFile = nil;
    self.recordLastFile = nil;
    
    self.startRecordingTime = -1;
    self.secondStartRecordingTime = -1;
}

- (void)startEditingAudioWith:(SCAudioComposition*)recordAudio playBack:(BOOL)canPlayBack
{
    self.audioComposition = recordAudio;
    self.recordedTmpFile = self.audioComposition.url;
    if(!canPlayBack)
    {
        self.editView.hidden = YES;
        self.statusView.hidden = NO;
        self.toolBarView.hidden  = NO;
        if(self.audioComposition.url)
        {
            [self startRecordingAudio];
            self.recordedTmpFile = self.audioComposition.url;
            self.recordLastFile = nil;
        }
        else
        {
            self.recordedTmpFile = nil;
            self.recordLastFile = nil;
        }
    }
    else
    {
        self.statusView.hidden = YES;
        self.toolBarView.hidden = YES;
        self.editView.hidden  = NO;
        self.volumeSlider.hidden = NO;
        self.playBtn.hidden = NO;
        [self.volumeSlider setValue:self.audioComposition.volume];
        
        //create player
        
        if(self.musicPlayer)
        {
            [self.musicPlayer stop];
            self.musicPlayer  = nil;
        }
        self.musicPlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioComposition.url error:nil];
        [self.musicPlayer  setDelegate:self];
        [self.musicPlayer setVolume:self.volumeSlider.value];
        
        [self setRecordSessionWith:NO];
    }
}

- (void)startRecordingAudio
{
    [self setRecordSessionWith:YES];
    [self.statusView setHidden:NO];
    [self.toolBarView setHidden:NO];
    [self.editView setHidden:YES];
    
    [self.previewBtn setEnabled:NO];
    [self.retakeBtn setEnabled:NO];
    [self.acceptBtn setEnabled:NO];
    
    [self.recordBtn setEnabled:YES];
    [self.recordBtn setSelected:NO];
    
}

- (void)setStartTimeForRecording:(float)startTime
{
    if(self.startRecordingTime == -1)
        self.startRecordingTime = startTime;
    else
    {
        self.startRecordingTime = CMTimeGetSeconds(self.audioComposition.startTimeInTimeline);
        self.secondStartRecordingTime = startTime;
    }
}

- (void)stopRecording
{
    if(self.recorder.isRecording)
    {
        NSLog(@"stop Recording");
        [self.recorder stop];
        self.isRecording = NO;
        //update label status
        self.statusLb.text = SC_MESSAGE_RECORDING_PREVIEW;
        
        //enable preview, retake, accept
        [self.previewBtn setEnabled:YES];
        [self.retakeBtn setEnabled:YES];
        [self.acceptBtn setEnabled:YES];
        //[self setRecordSessionWith:NO];
       
        //create compopsition
        if(CMTimeGetSeconds(self.audioComposition.timeRange.duration) == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:SC_MESSAGE_RECORDING_TOO_SHORT delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        //call delegate to stop record
        if([self.delegate respondsToSelector:@selector(stopRecording)])
        {
            [self.delegate stopRecording];
            self.isRecording = NO;
            [self.recordBtn setSelected:self.isRecording];
        }
    }
}

- (void)setRecordSessionWith:(BOOL)value
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if(value)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        if(!self.audioMonitor.isRecording)
        {
            [self.audioMonitor record];
        }
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];

    }
}


#pragma mark - class methods
//creat recorder and output URL + player

- (void)levelTimerCallback:(NSTimer *)timer
{
	[self.audioMonitor updateMeters];
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [self.audioMonitor peakPowerForChannel:0]));
	self.audioMonitorResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * self.audioMonitorResults;
	    //NSLog(@"[boost = %f]",self.audioMonitorResults);
	if (self.audioMonitorResults < 0.95)
    {
        //NSLog(@"Mic blow detected");
    }
    //NSLog(@"Power  %f",self.audioMonitorResults);
    //update view
    int value = SC_PEAK_POWER_TOTAL_CELL * self.audioMonitorResults;
    [self.peakPowerView setFrame:CGRectMake(self.peakPowerView.frame.origin.x,self.peakPowerView.frame.origin.y, value * SC_PEAK_POWER_UNIT_WIDTH,self.peakPowerView.frame.size.height)];
    
    //update record duration
    if(self.recorder.isRecording)
    {
        if([self.delegate respondsToSelector:@selector(recordingWithDuration:)])
        {
            //NSLog(@"Record duration %f", self.recorder.currentTime);
            [self.delegate recordingWithDuration:self.recorder.currentTime];
        }
    }
}

#pragma mark - actions

- (IBAction)onRecordBtn:(id)sender
{
   if(!self.isRecording)
    {
        [self setRecordSessionWith:YES];
        [self initRecorder];
        //open record session
        [self.recorder record];
        //update label status
        self.statusLb.text = SC_MESSAGE_RECORDING;
        //call delegate to start record
        if([self.delegate respondsToSelector:@selector(startRecording)])
        {
            [self.delegate startRecording];
            self.isRecording = YES;
            [self.recordBtn setSelected:self.isRecording];
        }
        [self.recordBtn setEnabled:YES];
    }
    else
    {
        //create audio composition
        if(self.recorder.currentTime == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:SC_MESSAGE_RECORDING_TOO_SHORT delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [self.recorder stop];
        //update label status
        self.statusLb.text = SC_MESSAGE_RECORDING_PREVIEW;
        
        //call delegate to stop record
        if([self.delegate respondsToSelector:@selector(stopRecording)])
        {
            [self.delegate stopRecording];
            self.isRecording = NO;
            [self.recordBtn setSelected:self.isRecording];
        }
        //[self setRecordSessionWith:NO];
        if(self.audioMonitor.isRecording)
        {
            [self.audioMonitor stop];
        }
        
        [self setRecordSessionWith:NO];
    }
    
    [self.previewBtn setEnabled:!self.isRecording];
    [self.retakeBtn setEnabled:!self.isRecording];
    [self.acceptBtn setEnabled:!self.isRecording];

}


- (IBAction)onReTakeBtn:(id)sender
{
    [self onRecordBtn:self.recordBtn];
}

- (IBAction)onPreviewBtn:(id)sender
{
    if(self.musicPlayer)
    {
        [self.musicPlayer stop];
        self.musicPlayer  = nil;
    }
    
    self.musicPlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
    [self.musicPlayer  setDelegate:self];
    [self.musicPlayer setVolume:1];
    
    [self.musicPlayer  play];
    self.isPlaying = YES;
    self.isRecording = NO;
}

- (IBAction)onAcceptBtn:(id)sender
{
    if(self.recordLastFile && [SCFileManager exist:self.recordLastFile])
    {
        self.recordedTmpFile = self.recordLastFile;
        self.recordLastFile = nil;
        self.startRecordingTime = self.secondStartRecordingTime;
        self.secondStartRecordingTime = -1;
    }
    self.audioComposition = [[SCAudioComposition alloc] initWithURL:self.recordedTmpFile];
    self.audioComposition.name = SC_AUDIO_RECORD;

    if(self.superview)
    {
        [self zoomOutWithCompletion:^
         {
             [self removeFromSuperview];
             if(self.musicPlayer)
                 [self.musicPlayer pause];
             
             if([self.delegate respondsToSelector:@selector(didFinishRecordingWith:)])
             {
                 if(self.audioComposition)
                 {
                     self.audioComposition.startTimeInTimeline = CMTimeMake(self.startRecordingTime * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
                     self.audioComposition.volume = self.volumeSlider.value;
                     if(CMTimeGetSeconds(self.audioComposition.timeRange.duration) > 0)
                         [self.delegate didFinishRecordingWith:self.audioComposition];
                     else
                     {
                         [self.delegate didFinishRecordingWith:nil];
                     }
                 }
                 else
                     [self.delegate didFinishRecordingWith:nil];
             }
         }];
        
        [self.recordBtn setSelected:NO];
        //close all record session and audio session
        if(self.audioMonitor.isRecording)
        {
            [self.audioMonitor stop];
        }
        
        if(self.recorder.isRecording)
        {
            [self.recorder stop];
        }
        //close record session
        [self setRecordSessionWith:NO];
    }
}

- (IBAction)onCancelBtn:(id)sender
{
    if(self.recordLastFile && self.audioComposition)
    {
        self.recordLastFile = nil;
        if(self.recordedTmpFile && [SCFileManager exist:self.recordedTmpFile])
        {
            self.audioComposition = [[SCAudioComposition alloc] initWithURL:self.recordedTmpFile];
            self.audioComposition.name = SC_AUDIO_RECORD;
            self.audioComposition.startTimeInTimeline = CMTimeMake(self.startRecordingTime * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
            self.audioComposition.volume = self.volumeSlider.value;
        }
        else
            self.audioComposition = nil;
    }
    else if(!self.audioComposition)
    {
        self.audioComposition = nil;
        self.recordedTmpFile = nil;
        self.audioComposition = nil;
        
        self.startRecordingTime = -1;
        self.secondStartRecordingTime = -1;
    }
    
    //delete temp audio record file
    if(self.superview)
    {
        [self zoomOutWithCompletion:^
         {
             [self removeFromSuperview];
             if(self.musicPlayer)
             {
                 [self.musicPlayer pause];
             }
             if([self.delegate respondsToSelector:@selector(didFinishRecordingWith:)])
             {
                 if(self.audioComposition)
                 {
                     if(CMTimeGetSeconds(self.audioComposition.timeRange.duration) > 0)
                         [self.delegate didFinishRecordingWith:self.audioComposition];
                     else
                     {
                         [self.delegate didFinishRecordingWith:nil];
                     }
                 }
                 else
                     [self.delegate didFinishRecordingWith:nil];
             }
         }];
        
        if(self.audioMonitor.isRecording)
        {
            [self.audioMonitor stop];
        }
        
        if(self.recorder.isRecording)
        {
            [self.recorder stop];
        }
        [self.recordBtn setSelected:NO];
        //close record session
        [self setRecordSessionWith:NO];
    }
}

- (IBAction)onDoneBtn:(id)sender
{
    if(self.superview)
    {
        [self zoomOutWithCompletion:^
         {
             [self removeFromSuperview];
             if(self.musicPlayer)
             {
                 [self.musicPlayer stop];
             }
             if([self.delegate respondsToSelector:@selector(didFinishRecordingWith:)])
             {
                 self.audioComposition.volume = self.volumeSlider.value;
                 [self.delegate didFinishRecordingWith:self.audioComposition];
             }
        }];
        
        if(self.audioMonitor.isRecording)
        {
            [self.audioMonitor stop];
        }
        
        if(self.recorder.isRecording)
        {
            [self.recorder stop];
        }
        [self.recordBtn setSelected:NO];
        //close record session
        [self setRecordSessionWith:NO];
    }

}

- (IBAction)onDelete:(id)sender
{
    [self deleteAudio];
    [self onDoneBtn:nil];
}

- (IBAction)onPlay:(id)sender
{
    if(self.audioComposition.url)
    {
        [((UIButton*)sender) setSelected:!((UIButton*)sender).isSelected];
        
        if(((UIButton*)sender).isSelected)
        {
            self.isRecording = NO;
            [self.musicPlayer  play];
        }
        else
        {
            [self.musicPlayer stop];
            self.isPlaying = NO;
        }
    }
}

- (IBAction)onChangeVolume:(id)sender
{
    if(self.musicPlayer)
    {
        [self.musicPlayer setVolume:self.volumeSlider.value];
        self.audioComposition.volume = self.volumeSlider.value;
    }
}

#pragma mark - audio plaer delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(flag)
    {
        [self.playBtn setSelected:NO];
        //[self setRecordSessionWith:YES];
    }
}


@end
