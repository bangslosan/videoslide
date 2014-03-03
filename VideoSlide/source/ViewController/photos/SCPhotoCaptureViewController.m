//
//  SCPhotoCaptureViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotoCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@interface SCPhotoCaptureViewController ()
{
    SCCameraOverlayView *cameraOverlayView;
    BOOL isUsingFrontFacingCamera;
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    IBOutlet UIView *overlayContainer;
}
@property(nonatomic, strong) AVCaptureStillImageOutput  *stillImageOutput;
//@property(nonatomic, strong) IBOutlet UIImageView       *quickImgView;
@property(nonatomic, strong) IBOutlet UIButton          *flashCameraBtn;
@property(nonatomic, strong) IBOutlet UIButton          *captureBtn;
@property(nonatomic, assign) CameraFlashMode            currentCameraFlashMode;
@property(nonatomic)         BOOL                       stopCapture;


- (void)stopCaptureSession;
@end

@implementation SCPhotoCaptureViewController
@synthesize stillImageOutput;
//@synthesize quickImgView;
@synthesize currentCameraFlashMode;
@synthesize flashCameraBtn;
@synthesize delegate;

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
 
    self.currentCameraFlashMode = CameraFlashModeAuto;
    [self updateCameraFlashMode];
    
    isUsingFrontFacingCamera = NO;
    cameraOverlayView = [[SCCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    cameraOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [overlayContainer addSubview:cameraOverlayView];
    self.stopCapture = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
	session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPreset640x480;
    
	CALayer *viewLayer = cameraOverlayView.layer;
	NSLog(@"viewLayer = %@", viewLayer);
	captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	captureVideoPreviewLayer.frame = cameraOverlayView.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[cameraOverlayView.layer addSublayer:captureVideoPreviewLayer];
	
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
	[session addInput:input];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:self.stillImageOutput];
    
	[session startRunning];
    
    device = nil;
    input = nil;
    captureVideoPreviewLayer = nil;
}



#pragma mark - actions

- (IBAction)back:(id)sender {
    [self clearAll];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)captureNow
{
    if(self.stopCapture)
        return;
	__block AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in stillImageOutput.connections)
	{
		for (AVCaptureInputPort *port in [connection inputPorts])
		{
			if ([[port mediaType] isEqual:AVMediaTypeVideo] )
			{
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { break; }
	}
	self.stopCapture = YES;
	NSLog(@"about to request a capture from: %@", stillImageOutput);
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         [self stopCaptureSession];
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         image = [image resizedImageWithMinimumSize:SC_CROP_PHOTO_SIZE];
         imageData = nil;
        
         SCSlideComposition *slide = [[SCSlideComposition alloc] init];
         //slide.image = [SCImageUtil imageWithCenterCrop:image size:SC_CROP_PHOTO_SIZE];
         //slide.thumbnailImage = [slide.image resizedImageWithMinimumSize:SC_THUMBNAIL_IMAGE_SIZE];
         slide.image = image;
         slide.originalImage = image;
         //slide.isCropped = YES;
         
         image = nil;
         imageSampleBuffer = nil;
         videoConnection = nil;
         [self dismissViewControllerAnimated:YES completion:^
          {
              if([self.delegate respondsToSelector:@selector(photoTakeWithCamera:)])
                  [self.delegate photoTakeWithCamera:slide];
              [self clearAll];        
          }];
         
         
	 }];
}


- (IBAction)switchCamera:(id)sender {
    if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ]) {
        [self switchCameras];
    }
}


- (IBAction)onFlashCameraBtn:(id)sender {
    [self doChangeCameraFlashMode];
}

#pragma mark - class methods

- (void)stopCaptureSession
{
    if(session.isRunning)
    {
        AVCaptureInput* input = [session.inputs objectAtIndex:0];
        [session removeInput:input];
        [session removeOutput:self.stillImageOutput];
        [session stopRunning];
        self.stillImageOutput = nil;
    }
    session = nil;
}


- (void) switchCameras
{
    AVCaptureDevicePosition desiredPosition;
    if (isUsingFrontFacingCamera) {
        desiredPosition = AVCaptureDevicePositionBack;
    } else {
        desiredPosition = AVCaptureDevicePositionFront;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in [session inputs]) {
                [session removeInput:oldInput];
            }
            [session addInput:input];
            [session commitConfiguration];
            break;
        }
    }
    isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
    
}


- (void)doChangeCameraFlashMode {
    switch (self.currentCameraFlashMode) {
        case CameraFlashModeAuto:
            [self toCameraFlashModeON];
            self.currentCameraFlashMode = CameraFlashModeON;
            break;
        case CameraFlashModeON:
            [self toCameraFlashModeOFF];
            self.currentCameraFlashMode = CameraFlashModeOFF;
            break;
        case CameraFlashModeOFF:
            [self toCameraFlashModeAuto];
            self.currentCameraFlashMode = CameraFlashModeAuto;
            break;
        default:
            break;
    }
    
    [self updateCameraFlashMode];
}

- (BOOL)isHasFlash {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL hasFlash = [device hasFlash];
    if (hasFlash) {
        return YES;
    }
    return NO;
}

- (void)updateCameraFlashMode {
    switch (self.currentCameraFlashMode) {
        case CameraFlashModeAuto:
            [self.flashCameraBtn setImage:[UIImage imageNamed:@"btn_photoview_flash_auto.png"]
                                 forState:UIControlStateNormal];
            break;
        case CameraFlashModeON:
            [self.flashCameraBtn setImage:[UIImage imageNamed:@"btn_photoview_flash_on.png"]
                                 forState:UIControlStateNormal];
            break;
        case CameraFlashModeOFF:
            [self.flashCameraBtn setImage:[UIImage imageNamed:@"btn_photoview_flash_off.png"]
                                 forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)toCameraFlashModeAuto {
    if (![self isHasFlash]) {
        return;
    }
    NSArray* devices = [AVCaptureDevice devices];
    for(AVCaptureDevice* device in devices)
    {
        if([device hasFlash])
        {
            if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                
                if([device lockForConfiguration:nil])
                {
                    device.flashMode = AVCaptureFlashModeAuto;
                }
                
            }
        }
    }
}

- (void)toCameraFlashModeON {
    if (![self isHasFlash]) {
        return;
    }
    NSArray* devices = [AVCaptureDevice devices];
    for(AVCaptureDevice* device in devices)
    {
        if([device hasFlash])
        {
            if ([device isFlashModeSupported:AVCaptureFlashModeOn]) {
                
                if([device lockForConfiguration:nil])
                {
                    device.flashMode = AVCaptureFlashModeOn;
                }
                
            }
        }
    }
}

- (void)toCameraFlashModeOFF {
    if (![self isHasFlash]) {
        return;
    }
    
    NSArray* devices = [AVCaptureDevice devices];
    //    NSLog(@"%d devices found", [devices count]);
    
    for(AVCaptureDevice* device in devices)
    {
        if([device hasFlash])
        {
            if ([device isFlashModeSupported:AVCaptureFlashModeOff]) {
                
                if([device lockForConfiguration:nil])
                {
                    device.flashMode = AVCaptureFlashModeOff;
                }
                
            }
        }
    }
}

#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    [captureVideoPreviewLayer removeFromSuperlayer];
    captureVideoPreviewLayer =nil;
    [cameraOverlayView removeFromSuperview];
    cameraOverlayView = nil;
    [self stopCaptureSession];
    self.delegate = nil;

}

@end
