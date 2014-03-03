//
//  SCDurationSettingView.m
//  SlideshowCreator
//
//  Created 10/17/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCDurationSettingView.h"


@interface SCDurationSettingView ()

@property (nonatomic, strong) IBOutlet UIButton *vineSelectBtn;
@property (nonatomic, strong) IBOutlet UIButton *instagramSelectBtn;
@property (nonatomic, strong) IBOutlet UIButton *customSelectBtn;
@property (nonatomic, strong) IBOutlet UIButton *increaseCustomBtn;
@property (nonatomic, strong) IBOutlet UIButton *deCreaseCustomBtn;

@property (nonatomic, strong) IBOutlet UIButton *noneTransitionBtn;
@property (nonatomic, strong) IBOutlet UIButton *disolveTransitionBtn;
@property (nonatomic, strong) IBOutlet UIButton *topTransitionBtn;
@property (nonatomic, strong) IBOutlet UIButton *bottomTransitionBtn;
@property (nonatomic, strong) IBOutlet UIButton *leftTransitionBtn;
@property (nonatomic, strong) IBOutlet UIButton *rightTransitionBtn;


@property (nonatomic, strong) IBOutlet UILabel *vineSecondLb;
@property (nonatomic, strong) IBOutlet UILabel *instagramSecondLb;
@property (nonatomic, strong) IBOutlet UILabel *customSecondLb;

@property (nonatomic)         SCVideoDurationType   durationType;
@property (nonatomic)         SCVideoTransitionType transitionType;
@property (nonatomic)         float                 totalDuration;;
@property (nonatomic)         int                   numberOfPhoto;
@property (nonatomic)         BOOL                  transitionEnable;


@property (nonatomic)         SCVideoDurationType   olderDurationType;
@property (nonatomic)         SCVideoTransitionType olderTransitionType;
@property (nonatomic)         float                 olderTotalDuration;;
@property (nonatomic)         int                   olderNumberOfPhoto;
@property (nonatomic)         BOOL                  olderTransitionEnable;
@property (nonatomic)         int                   customDuration;


@property (nonatomic, strong)         NSTimer       *durationPressTimer;
@property (nonatomic)                  BOOL         isIncreasing;
@property (nonatomic)                  BOOL         isFirstTime;



- (IBAction)onSelectVineBtn:(id)sender;
- (IBAction)onSelectInsstagramBtn:(id)sender;
- (IBAction)onSelectCustomBtn:(id)sender;

- (IBAction)onDecreaseSecondBtn:(id)sender;
- (IBAction)onIncreaseSecondBtn:(id)sender;
- (IBAction)onTouchDownDecreaseSecondBtn:(id)sender;
- (IBAction)onTouchDownIncreaseSecondBtn:(id)sender;


- (IBAction)onNoneTransitionBtn:(id)sender;
- (IBAction)onDissolveTransitionBtn:(id)sender;
- (IBAction)onTopTransitionBtn:(id)sender;
- (IBAction)onBottomTransitionBtn:(id)sender;
- (IBAction)onRightTransitionBtn:(id)sender;
- (IBAction)onLeftTransitionBtn:(id)sender;
- (IBAction)onDoneBtn:(id)sender;


- (void)updateToSlideShowSetting;
- (void)updateTransitionSetting;
- (void)updateTransitionAvailable;
- (void)setAllTransitionEnable:(BOOL)enable;
- (void)chooseTransitionWithType:(SCVideoTransitionType)transitionType;

- (void)setAllTransitionSelected:(BOOL)value;
@end


@implementation SCDurationSettingView

@synthesize delegate  =_delegate;

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
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCDurationSettingView" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        
    }
    return self;
}

- (void)awakeFromNib
{
    self.isFirstTime = YES;
}

#pragma mark - class methods

- (void)updateWithSlideShowSetting
{
    self.olderNumberOfPhoto = [SCSlideShowSettingManager getInstance].numberPhotos;
    self.olderTotalDuration = [SCSlideShowSettingManager getInstance].videoTotalDuration;
    self.olderTransitionType = [SCSlideShowSettingManager getInstance].transitionType;
    self.olderTransitionEnable = [SCSlideShowSettingManager getInstance].transitionsEnabled;
    self.olderDurationType = [SCSlideShowSettingManager getInstance].videoDurationType;

    self.numberOfPhoto = [SCSlideShowSettingManager getInstance].numberPhotos;
    self.totalDuration = [SCSlideShowSettingManager getInstance].videoTotalDuration;
    self.transitionType = [SCSlideShowSettingManager getInstance].transitionType;
    self.transitionEnable = [SCSlideShowSettingManager getInstance].transitionsEnabled;
    self.durationType = [SCSlideShowSettingManager getInstance].videoDurationType;

    switch ([SCSlideShowSettingManager getInstance].videoDurationType)
    {
        case SCVideoDurationTypeVine:
        {
            [self onSelectVineBtn:self.vineSelectBtn];
            if(self.isFirstTime)
            {
                self.customDuration = self.numberOfPhoto * 3;
                self.isFirstTime  = NO;
            }
        }
        break;
        case SCVideoDurationTypeInstagram:
        {
            [self onSelectInsstagramBtn:self.instagramSelectBtn];
            if(self.isFirstTime)
            {
                self.customDuration = self.numberOfPhoto * 3;
                self.isFirstTime  = NO;
            }
        }
        break;
        case SCVideoDurationTypeCustom:
        {
            self.customDuration = self.totalDuration;
            [self onSelectCustomBtn:self.customSelectBtn];
        }
        break;
        
        default:
        break;
    }
    
    self.customSecondLb.text = [NSString stringWithFormat:@"%d",(int)self.customDuration];
    self.isFirstTime  = NO;

}

- (void)updateToSlideShowSetting
{
    if(self.transitionType == SCVideoTransitionTypeNone)
    {
        [[SCSlideShowSettingManager getInstance] updateTimeWithoutTransition:[SCSlideShowSettingManager getInstance].numberPhotos videoTotalDuration:self.totalDuration videoDurationType:self.durationType];
        self.transitionEnable = NO;
    }
    else
    {
        [[SCSlideShowSettingManager getInstance] updateTimeWith:[SCSlideShowSettingManager getInstance].numberPhotos videoTotalDuration:self.totalDuration videoDurationType:self.durationType];
        self.transitionEnable = [SCSlideShowSettingManager getInstance].transitionsEnabled;

    }
    
    [SCSlideShowSettingManager getInstance].transitionType = self.transitionType;

}


- (void)updateTransitionSetting
{
    //[self setAllTransitionEnable:NO];
    if(self.transitionType == SCVideoTransitionTypeNone)
    {
        self.noneTransitionBtn.enabled = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypeDisolve)
    {
        self.disolveTransitionBtn.enabled = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypePushFromTop)
    {
        self.topTransitionBtn.enabled = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypePushFromBottom)
    {
        self.bottomTransitionBtn.enabled = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypePushFromLeft)
    {
        self.leftTransitionBtn.enabled = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypePushFromRight)
    {
        self.rightTransitionBtn.enabled = YES;
    }
        
}

- (void)updateTransitionBtnSelected
{
    //[self setAllTransitionEnable:NO];
    if(self.transitionType == SCVideoTransitionTypeNone)
    {
        self.noneTransitionBtn.selected = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypeDisolve)
    {
        self.disolveTransitionBtn.selected = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypePushFromTop)
    {
        self.topTransitionBtn.selected = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypePushFromBottom)
    {
        self.bottomTransitionBtn.selected = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypePushFromLeft)
    {
        self.leftTransitionBtn.selected = YES;
    }
    else  if(self.transitionType == SCVideoTransitionTypePushFromRight)
    {
        self.rightTransitionBtn.selected = YES;
    }
    
}


- (void)setAllTransitionEnable:(BOOL)enable;
{
    self.noneTransitionBtn.enabled = enable;
    self.disolveTransitionBtn.enabled = enable;
    self.topTransitionBtn.enabled = enable;
    self.bottomTransitionBtn.enabled = enable;
    self.leftTransitionBtn.enabled = enable;
    self.rightTransitionBtn.enabled = enable;
}

- (void)updateTransitionAvailable
{
    //check to update transition enable
    if([[SCSlideShowSettingManager getInstance] transitionDurationWith:self.durationType
                                                          numberPhotos:[SCSlideShowSettingManager getInstance].numberPhotos
                                                         totalDuration:self.totalDuration] > SC_VIDEO_TRANSITION_DURATION_0)
    {
        self.transitionType = [SCSlideShowSettingManager getInstance].transitionType;
        [self setAllTransitionEnable:YES];
        [self setAllTransitionSelected:NO];
        [self updateTransitionBtnSelected];
    }
    else
    {
        [self setAllTransitionEnable:NO];
        self.transitionType = SCVideoTransitionTypeNone;
        [self setAllTransitionSelected:NO];
    }
}


- (void)chooseTransitionWithType:(SCVideoTransitionType)transitionType
{
    if([SCSlideShowSettingManager getInstance].transitionsEnabled)
    {
        [[SCSlideShowSettingManager getInstance] updateTimeWith:[SCSlideShowSettingManager getInstance].numberPhotos videoTotalDuration:[SCSlideShowSettingManager getInstance].videoTotalDuration videoDurationType:[SCSlideShowSettingManager getInstance].videoDurationType];
        [SCSlideShowSettingManager getInstance].transitionType = transitionType;
    }
}

#pragma mark - actions

- (IBAction)onDoneBtn:(id)sender
{
    BOOL hasChanged = NO;
    if(self.durationType == self.olderDurationType &&
       self.totalDuration == self.olderTotalDuration &&
       self.transitionType == self.olderTransitionType &&
       self.transitionEnable == self.olderTransitionEnable)
        hasChanged = NO;
    else
        hasChanged = YES;
    //update all setting manager information
    [self updateToSlideShowSetting];
    
    if(self.superview)
    {
        [self fadeOutWithCompletion:^{
            if([self.delegate respondsToSelector:@selector(didFinishSetting:)])
            {
                [self.delegate didFinishSetting:hasChanged];
            }
            [self removeFromSuperview];
        }];
    }
}

- (IBAction)onSelectVineBtn:(id)sender
{
    if([SCSlideShowSettingManager getInstance].numberPhotos <= SC_VIDEO_VINE_DURATION)
    {
        [self.vineSelectBtn setSelected:YES];
        [self.instagramSelectBtn setSelected:NO];
        [self.customSelectBtn setSelected:NO];
        NSLog(@"Set Vine Mode");
        self.totalDuration = SC_VIDEO_VINE_DURATION;
        self.durationType = SCVideoDurationTypeVine;
        //de enable 2 button
        //self.customSecondLb.text = [NSString stringWithFormat:@"%d",(int)self.totalDuration];
        
        //update transition enable
        [self updateTransitionAvailable];

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Vine mode disable" message:@"Mode with maximum 6 photos" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)onSelectInsstagramBtn:(id)sender
{
    if([SCSlideShowSettingManager getInstance].numberPhotos <= SC_VIDEO_INSTAGRAM_DURATION)
    {
        [self.vineSelectBtn setSelected:NO];
        [self.instagramSelectBtn setSelected:YES];
        [self.customSelectBtn setSelected:NO];
        NSLog(@"Set Instagram Mode");
        self.totalDuration = SC_VIDEO_INSTAGRAM_DURATION;
        self.durationType = SCVideoDurationTypeInstagram;

        //de enable 2 button
        //self.customSecondLb.text = [NSString stringWithFormat:@"%d",(int)self.totalDuration];
        
        //update transition enable
        [self updateTransitionAvailable];

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instagram mode disable" message:@"Mode with maximum 15 photos" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)onSelectCustomBtn:(id)sender
{
    if(self.customSelectBtn.isSelected)
        return;
    if([SCSlideShowSettingManager getInstance].numberPhotos <= self.totalDuration)
    {
        self.totalDuration = self.customDuration;
        [self.vineSelectBtn setSelected:NO];
        [self.instagramSelectBtn setSelected:NO];
        [self.customSelectBtn setSelected:YES];
        self.durationType = SCVideoDurationTypeCustom;

        NSLog(@"Set Custom Mode");
        //update transition enable
        [self updateTransitionAvailable];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom mode disable" message:[NSString stringWithFormat:@"Custom time is less than number of photo[%d]",[SCSlideShowSettingManager getInstance].numberPhotos] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

    }
    
    //self.customSecondLb.text = [NSString stringWithFormat:@"%d",(int)self.totalDuration];
}

- (IBAction)onDecreaseSecondBtn:(id)sender
{
    if(self.customSecondLb.text.intValue > [SCSlideShowSettingManager getInstance].numberPhotos)
    {
        //self.customSecondLb.text = [NSString stringWithFormat:@"%d",self.customSecondLb.text.intValue - 1];
        self.totalDuration = self.customSecondLb.text.intValue;
        self.customDuration = self.totalDuration;
        //update transition enable
        [self updateTransitionAvailable];
    }
    
    if(self.durationPressTimer.isValid)
    {
        [self.durationPressTimer invalidate];
        self.durationPressTimer = nil;
    }
}

- (IBAction)onIncreaseSecondBtn:(id)sender
{
    [self onSelectCustomBtn:self.customSelectBtn];
    if(self.customSecondLb.text.intValue < SC_VIDEO_CUSTOM_MAX_DURATION)
    {
        //self.customSecondLb.text = [NSString stringWithFormat:@"%d",self.customSecondLb.text.intValue + 1];
        self.totalDuration = self.customSecondLb.text.intValue;
        self.customDuration = self.totalDuration;
        //update transition enable
        [self updateTransitionAvailable];
    }
    
    if(self.durationPressTimer.isValid)
    {
        [self.durationPressTimer invalidate];
        self.durationPressTimer = nil;
    }
}

- (IBAction)onTouchDownDecreaseSecondBtn:(id)sender
{
    [self onSelectCustomBtn:self.customSelectBtn];
    if(self.durationPressTimer.isValid)
    {
        [self.durationPressTimer invalidate];
        self.durationPressTimer = nil;

    }
    self.isIncreasing = NO;
    self.durationPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onPress:) userInfo:nil repeats:YES];
    
}

- (IBAction)onTouchDownIncreaseSecondBtn:(id)sender
{
    [self onSelectCustomBtn:self.customSelectBtn];
    if(self.durationPressTimer.isValid)
    {
        [self.durationPressTimer invalidate];
        self.durationPressTimer = nil;

    }
    self.isIncreasing = YES;
    self.durationPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onPress:) userInfo:nil repeats:YES];

}


- (void)onPress:(id)sender
{
    if(self.isIncreasing)
    {
        if(self.customSecondLb.text.intValue < SC_VIDEO_CUSTOM_MAX_DURATION)
        {
            self.customSecondLb.text = [NSString stringWithFormat:@"%d",self.customSecondLb.text.intValue + 1];
            self.totalDuration = self.customSecondLb.text.intValue;
            //update transition enable
            [self updateTransitionAvailable];
        }
    }
    else
    {
        if(self.customSecondLb.text.intValue > [SCSlideShowSettingManager getInstance].numberPhotos)
        {
            self.customSecondLb.text = [NSString stringWithFormat:@"%d",self.customSecondLb.text.intValue - 1];
            self.totalDuration = self.customSecondLb.text.intValue;
            //update transition enable
            [self updateTransitionAvailable];
        }
    }
}

#pragma mark - transition action
- (IBAction)onNoneTransitionBtn:(id)sender
{
    if([[SCSlideShowSettingManager getInstance] transitionDurationWith:self.durationType
                                                          numberPhotos:[SCSlideShowSettingManager getInstance].numberPhotos
                                                         totalDuration:self.totalDuration] > SC_VIDEO_TRANSITION_DURATION_0)
    {
        self.transitionType = SCVideoTransitionTypeNone;
        [self updateTransitionSetting];

        [self setAllTransitionSelected:NO];
        [self.noneTransitionBtn setSelected:YES];
    }
}

- (IBAction)onDissolveTransitionBtn:(id)sender
{
    if([[SCSlideShowSettingManager getInstance] transitionDurationWith:self.durationType
                                                          numberPhotos:[SCSlideShowSettingManager getInstance].numberPhotos
                                                         totalDuration:self.totalDuration] > SC_VIDEO_TRANSITION_DURATION_0)
    {
        self.transitionType = SCVideoTransitionTypeDisolve;
        [self updateTransitionSetting];

        [self setAllTransitionSelected:NO];
        [self.disolveTransitionBtn setSelected:YES];


    }
}

- (IBAction)onTopTransitionBtn:(id)sender
{
    if([[SCSlideShowSettingManager getInstance] transitionDurationWith:self.durationType
                                                          numberPhotos:[SCSlideShowSettingManager getInstance].numberPhotos
                                                         totalDuration:self.totalDuration] > SC_VIDEO_TRANSITION_DURATION_0)
    {
        self.transitionType = SCVideoTransitionTypePushFromTop;
        [self updateTransitionSetting];
        
        [self setAllTransitionSelected:NO];
        [self.topTransitionBtn setSelected:YES];


    }}

- (IBAction)onBottomTransitionBtn:(id)sender
{
    if([[SCSlideShowSettingManager getInstance] transitionDurationWith:self.durationType
                                                          numberPhotos:[SCSlideShowSettingManager getInstance].numberPhotos
                                                         totalDuration:self.totalDuration] > SC_VIDEO_TRANSITION_DURATION_0)
    {
        self.transitionType = SCVideoTransitionTypePushFromBottom;
        [self updateTransitionSetting];
        
        [self setAllTransitionSelected:NO];
        [self.bottomTransitionBtn setSelected:YES];


    }
}

- (IBAction)onRightTransitionBtn:(id)sender
{
    if([[SCSlideShowSettingManager getInstance] transitionDurationWith:self.durationType
                                                          numberPhotos:[SCSlideShowSettingManager getInstance].numberPhotos
                                                         totalDuration:self.totalDuration] > SC_VIDEO_TRANSITION_DURATION_0)
     {
         self.transitionType = SCVideoTransitionTypePushFromRight;
         [self updateTransitionSetting];
         
         [self setAllTransitionSelected:NO];
         [self.rightTransitionBtn setSelected:YES];
     }
}

- (IBAction)onLeftTransitionBtn:(id)sender
{
    if([[SCSlideShowSettingManager getInstance] transitionDurationWith:self.durationType
                                                          numberPhotos:[SCSlideShowSettingManager getInstance].numberPhotos
                                                         totalDuration:self.totalDuration] > SC_VIDEO_TRANSITION_DURATION_0)
    {
        self.transitionType = SCVideoTransitionTypePushFromLeft;
        [self updateTransitionSetting];
        
        [self setAllTransitionSelected:NO];
        [self.leftTransitionBtn setSelected:YES];
    }
}


- (void)setAllTransitionSelected:(BOOL)value
{
    [self.noneTransitionBtn setSelected:value];
    [self.disolveTransitionBtn setSelected:value];
    [self.leftTransitionBtn setSelected:value];
    [self.rightTransitionBtn setSelected:value];
    [self.topTransitionBtn setSelected:value];
    [self.bottomTransitionBtn setSelected:value];

}

@end


