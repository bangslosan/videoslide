//
//  SCPreviewViewController.m
//  VideoSlide
//
//  Created by Thi Huynh on 2/19/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCPreviewViewController.h"

@interface SCPreviewViewController () <SCVideoPreviewProtocol>

@property (nonatomic, strong) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) IBOutlet UIButton *backBtn;

@property (nonatomic, strong) SCVideoPreview                    *videoPreview;
@property (nonatomic, strong) SCSlideShowComposition            *slideShowComposition;
@property (nonatomic, strong) UIPanGestureRecognizer            *panGesture;


- (IBAction)onNextBtn:(id)sender;
- (IBAction)onBackBtn:(id)sender;

@end

@implementation SCPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.slideShowComposition = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_DATA];
    if(self.slideShowComposition)
    {
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            //
            //
            NSMutableArray *images = [[NSMutableArray alloc]init];
            for(SCSlideComposition *slide in self.slideShowComposition.slides)
            {
                if(slide.image)
                {
                    UIImage *image;
                    if(slide.currentScale <= 1)
                    {
                        image = [SCImageUtil imageWithImage:slide.image scaledToSize:CGSizeMake(slide.image.size.width * slide.currentScale, slide.image.size.height * slide.currentScale)];
                        image = [SCImageUtil cropImageWith:image rect:slide.rectCropped];
                        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                    }
                    else
                    {
                        image = [SCImageUtil getSubImageFrom:slide.image rect:slide.rectCropped];
                        image = [SCImageUtil imageWithImage:image scaledToSize:CGSizeMake(640, 640)];
                    }

                    [images addObject:image];
                }
            }

            if(images.count > 0)
            {
                NSURL *outPut = [SCFileManager createURLFromTempWithName:[NSString stringWithFormat:@"%@.%@",SC_OUTPUT_VIDEO,SC_MP4]];
                self.slideShowComposition.exportURL = outPut;
                if(images.count > 1)
                    [SCVideoUtil createVideoWithArrayImages:images size:SC_VIDEO_SIZE time:CMTimeGetSeconds(self.slideShowComposition.totalDuration) output:outPut];
                else
                    [SCVideoUtil createVideoWith:[images objectAtIndex:0] size:SC_VIDEO_SIZE time:CMTimeGetSeconds(self.slideShowComposition.totalDuration) output:outPut];
                
            }
            dispatch_async( dispatch_get_main_queue(), ^{
                // Add code here to update the UI/send notifications based on the
                // results of the background processing
                
                SCVideoComposition *videoComposition = [[SCVideoComposition alloc]initWithURL:self.slideShowComposition.exportURL];
                if(self.slideShowComposition.videos.count > 0)
                {
                    [self.slideShowComposition.videos removeAllObjects];
                }
                [self.slideShowComposition.videos addObject:videoComposition];
                SCBasicMediaBuilder *builder = [[SCBasicMediaBuilder alloc]initWithSlideShow:self.slideShowComposition];
                self.videoPreview = [[SCVideoPreview alloc]initWith:[builder buildMediaComposition] frame:CGRectMake(0, 0, 320, 320)];
                [self.view addSubview:self.videoPreview];
                self.videoPreview.delegate = self;
                
                self.videoPreview.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    self.videoPreview.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];

            });
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearAll
{
    [super clearAll];
    if(self.videoPreview)
    {
        [self.videoPreview clearAll];
        [self.videoPreview removeFromSuperview];
        self.videoPreview = nil;
    }
}

#pragma mark - actions

- (void)onNextBtn:(id)sender
{
    if(self.slideShowComposition.slides.count > 0)
        [self gotoScreen:SCEnumSharingScreen data:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.slideShowComposition, SC_TRANSIT_KEY_SLIDE_SHOW_DATA ,nil]];

}

- (void)onBackBtn:(id)sender
{
    [self goBack];
}

#pragma mark - video preview protocol

- (void)currentProgessFromPlayer:(float)progress
{
    
}

- (void)playerStatus:(SCMediaStatus)status
{
    
}

- (void)playerReachEndPoint
{
    
}



@end
