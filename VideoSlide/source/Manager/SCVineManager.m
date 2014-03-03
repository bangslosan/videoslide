//
//  SCVineManager.m
//  SlideshowCreator
//
//  Created 12/5/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVineManager.h"

@interface SCVineManager () <SCVineAuthenticateViewControllerDelegate>


@property (nonatomic,strong) SCVineAuthenticateViewController *vineAuthenticateViewController;
@end

@implementation SCVineManager
@synthesize _videoUrl;
@synthesize _thumbnailUrl;
@synthesize _connection;
@synthesize outputURL;
@synthesize thumbnailImage;
@synthesize vineSessionID;
@synthesize loginForString;
@synthesize uploadArray = _uploadArray;

- (id)init {
    self = [super init];
    if(self)
    {
        self.uploadArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isVineLoggedIn {

    [self loadAuthenticate];
    if ([self.vineSessionID isEqualToString:@""] || (self.vineSessionID == nil)) {
        return NO;
    } else {
        return YES;
    }
}

- (void)login {
    
    [[SCScreenManager getInstance].rootViewController presentScreen:SCEnumVineAuthenticateScreen data:nil];
    self.vineAuthenticateViewController = (SCVineAuthenticateViewController*)[SCScreenManager getInstance].rootViewController.currentPresentVC;
    self.vineAuthenticateViewController.delegate = self;
}

- (void)logout {
    [self clearAllAuthenticate];
    [self sendNotification:SCNotificationVineDidLogOut];
}

- (void)uploadVideo {
    
    NSURL *videoURL = [SCFileManager URLFromBundleWithName:@"test.MOV"];
    
    
    NSURL *newURL = [SCFileManager createURLFromTempWithName:@"output.MOV"];
    [SCVideoUtil resizeVideoWith:videoURL des:newURL];
    
    NSData *videoData = [NSData dataWithContentsOfURL:newURL];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://media.vineapp.com/upload/videos/output.MOV"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
                                                            path:@"https://media.vineapp.com/upload/videos/output.MOV"
                                                      parameters:nil];

    
    
    [request setValue:@"video/quicktime" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ios/1.3.1" forHTTPHeaderField:@"X-Vine-Client"];
    [request setValue:@"en;q=1, fr;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:self.vineSessionID forHTTPHeaderField:@"vine-session-id"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"iphone/1.3.1 (iPad; iOS 6.1.3; Scale/1.00)" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod: @"PUT"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[videoData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:videoData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //[httpClient setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse*)operation.response;
        NSDictionary *dict = res.allHeaderFields;
        self.videoUploadedURL = [dict objectForKey:@"X-Upload-Key"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

- (void)uploadThumbnail {
    NSURL *videoURL = [SCFileManager URLFromBundleWithName:@"test.jpg"];
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://media.vineapp.com/upload/thumbs/test.jpg"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
                                                            path:@"https://media.vineapp.com/upload/thumbs/test.jpg"
                                                      parameters:nil];
    
    
    
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ios/1.3.1" forHTTPHeaderField:@"X-Vine-Client"];
    [request setValue:@"en;q=1, fr;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:self.vineSessionID forHTTPHeaderField:@"vine-session-id"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"iphone/1.3.1 (iPad; iOS 6.1.3; Scale/1.00)" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod: @"PUT"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[videoData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:videoData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //[httpClient setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        // NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse*)operation.response;
        NSDictionary *dict = res.allHeaderFields;
        self.thumbnailUploadedURL = [dict objectForKey:@"X-Upload-Key"];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

- (void)createPost {
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.vineapp.com/posts"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"https://api.vineapp.com/posts"
                                                      parameters:@{@"videoUrl":self.videoUploadedURL,
                                                                   @"thumbnailUrl":self.thumbnailUploadedURL,
                                                                   @"description":@"i like this app",
                                                                   @"entities":@"",
                                                                   @"forsquareVenueId":@"4bcd909db6c49c74b27e9591",
                                                                   @"venueName":@"Sunrise City",
                                                                   @"channelId":@"2",
                                                                   }];
    
    
    [request setValue:self.vineSessionID forHTTPHeaderField:@"vine-session-id"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //[httpClient setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

#pragma mark - New Create a Vine Post flow

#pragma mark - Create a Post
- (void)uploadToVine {
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.vineapp.com/posts"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"https://api.vineapp.com/posts"
                                                      parameters:nil];
    
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ios/1.3.1" forHTTPHeaderField:@"X-Vine-Client"];
    [request setValue:@"en;q=1" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:self.vineSessionID forHTTPHeaderField:@"vine-session-id"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"iphone/1.3.1 (iPad; iOS 6.1.3; Scale/1.00)" forHTTPHeaderField:@"User-Agent"];
    NSString *strParams = [NSString stringWithFormat:@"{\"videoUrl\":\"%@\",\"thumbnailUrl\":\"%@\",\"description\":\"%@\",\"entities\":[]}", _videoUrl, _thumbnailUrl, @""];
    NSData *dataBody = [strParams dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataBody length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody:dataBody];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"create a post ok");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

- (void)convertVideoFrom:(NSURL*)fromURL to:(NSURL*)toURL {
    
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:toURL fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:480], AVVideoWidthKey,
                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
                                   //codecSettings, AVVideoCompressionPropertiesKey,
                                   AVVideoScalingModeResizeAspectFill
                                   ,AVVideoScalingModeKey, nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    
    
    
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    [videoWriter addInput:videoWriterInput];
    
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:fromURL options:nil];
    NSError *aerror = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:avAsset error:&aerror];
    
    AVAssetTrack *videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
    
    videoWriterInput.transform = videoTrack.preferredTransform;
    
    NSDictionary *videoOptions = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                  [NSNumber numberWithInt:480], kCVPixelBufferWidthKey,
                                  [NSNumber numberWithInt:480], kCVPixelBufferHeightKey,
                                  nil];
    
    AVAssetReaderTrackOutput *asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:videoOptions];
    
    [reader addOutput:asset_reader_output];
    // audio setup
    AVAssetWriterInput *audioWriterInput;
    AVAssetReader *audioReader;
    AVAssetTrack *audioTrack;
    AVAssetReaderOutput *audioReaderOutput;
    if ([[avAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
        audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
        audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:nil];
        audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        [audioReader addOutput:audioReaderOutput];
        
        [videoWriter addInput:audioWriterInput];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        
        [videoWriter startWriting];
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        [reader startReading];
        
        CMSampleBufferRef buffer;
        
        
        while ([reader status]==AVAssetReaderStatusReading)
        {
            if(![videoWriterInput isReadyForMoreMediaData])
                continue;
            
            buffer = [asset_reader_output copyNextSampleBuffer];
            
            NSLog(@"READING");
            
            if(buffer){
                [videoWriterInput appendSampleBuffer:buffer];
                CFRelease(buffer);
            }
            
            NSLog(@"WRITTING...");
            
            
        }
        
        //Finish the session:
        [videoWriterInput markAsFinished];
        
        if (audioWriterInput) {
            [videoWriter startSessionAtSourceTime:kCMTimeZero];
            [audioReader startReading];
            
            while (audioWriterInput.readyForMoreMediaData) {
                CMSampleBufferRef audioSampleBuffer;
                if ([audioReader status] == AVAssetReaderStatusReading &&
                    (audioSampleBuffer = [audioReaderOutput copyNextSampleBuffer])) {
                    if (audioSampleBuffer) {
                        printf("write audio  ");
                        [audioWriterInput appendSampleBuffer:audioSampleBuffer];
                    }
                    CFRelease(audioSampleBuffer);
                } else {
                    [audioWriterInput markAsFinished];
                    switch ([audioReader status]) {
                        case AVAssetReaderStatusCompleted:
                        {
                            
                        }
                    }
                }
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [videoWriter endSessionAtSourceTime:avAsset.duration];
            [videoWriter finishWritingWithCompletionHandler:^{
            }];
            
            self.thumbnailImage = [[self imageThumbnailFromURL:toURL] imageByScalingAndCroppingForSize:CGSizeMake(480, 480)];
            self.outputURL = toURL.path;
            [self putVideoFile];

        });
    });

}

- (void) putVideoFile{

    NSData *videoData = [NSData dataWithContentsOfFile:self.outputURL];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://media.vineapp.com/upload/videos/1.3.1.mp4"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
                                                            path:@"https://media.vineapp.com/upload/videos/1.3.1.mp4"
                                                      parameters:nil];
    
    [request setValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ios/1.3.1" forHTTPHeaderField:@"X-Vine-Client"];
    [request setValue:@"en;q=1, fr;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:self.vineSessionID forHTTPHeaderField:@"vine-session-id"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"iphone/1.3.1 (iPad; iOS 6.1.3; Scale/1.00)" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod: @"PUT"];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[videoData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:videoData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse*)operation.response;
        NSDictionary *dict = res.allHeaderFields;
        self._videoUrl = [dict objectForKey:@"X-Upload-Key"];
        NSLog(@"upload video ok");
        
        [self putThumbnailFile];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

- (void) putThumbnailFile{
    
    NSData *data = UIImageJPEGRepresentation(self.thumbnailImage, 1);
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://media.vineapp.com/upload/thumbs/1.3.1.mp4.jpg"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
                                                            path:@"https://media.vineapp.com/upload/thumbs/1.3.1.mp4.jpg"
                                                      parameters:nil];
    
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ios/1.3.1" forHTTPHeaderField:@"X-Vine-Client"];
    [request setValue:@"en;q=1, fr;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:self.vineSessionID forHTTPHeaderField:@"vine-session-id"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"iphone/1.3.1 (iPad; iOS 6.1.3; Scale/1.00)" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod: @"PUT"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse*)operation.response;
        NSDictionary *dict = res.allHeaderFields;
        self.thumbnailUploadedURL = [dict objectForKey:@"X-Upload-Key"];
        
        [self uploadToVine];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}


- (UIImage *) imageThumbnailFromURL:(NSURL *) url{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 10);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    return thumbnail;
}

#pragma mark - Save Authenticate to cache & remember login
- (void)saveAuthenticate {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.vineSessionID forKey:SC_VINE_AUTHENTICATE_KEY];
    [userDefault synchronize];
}

- (void)loadAuthenticate {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.vineSessionID = [userDefault objectForKey:SC_VINE_AUTHENTICATE_KEY];
}

- (void)clearAllAuthenticate {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:nil forKey:SC_VINE_AUTHENTICATE_KEY];
    [userDefault synchronize];
}

#pragma mark - Vine Authenticate VC delegate
- (void)didVineLoginSuccess {
    if ([self.loginForString isEqualToString:SCNotificationVineDidLogInForUpload]) {
        [self sendNotification:SCNotificationVineDidLogInForUpload];
        self.loginForString = @"";
    } else {
        [self sendNotification:SCNotificationVineDidLoginIn];
    }
}

@end
