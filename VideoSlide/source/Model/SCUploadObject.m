//
//  SCUploadObject.m
//  SlideshowCreator
//
//  Created 10/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCUploadObject.h"
//#import "GTMOAuth2ViewControllerTouch.h"
//#import "GTLYouTube.h"
//#import "GTLUtilities.h"
//#import "GTMHTTPUploadFetcher.h"
//#import "GTMHTTPFetcherLogging.h"

@implementation SCUploadObject

@synthesize fileName;
@synthesize uploadProgress;
@synthesize uploadStatus;
@synthesize uploadType;
@synthesize videoURL;
@synthesize uploadDate;

@synthesize _uploadFileTicket;
@synthesize _uploadLocationURL;
@synthesize connectionRateTimer;

@synthesize delegate;
@synthesize currentTotalBytes;
@synthesize currentProgressSegmentUpdated;
@synthesize fSegmentProgress;

@synthesize vineUploadThumbnailURL;
@synthesize vineUploadVideoURL;
@synthesize vineThumbnailImage;
@synthesize vineOutputURL;

- (id)init {
    self = [super init];
    if (self) {
        self.uploadProgress = 0;
        self.uploadDate = [NSDate date];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.videoURL = [NSURL fileURLWithPath:[dict objectForKey:@"videoURL" withDefaultValue:SCDictionaryDefaultString]];
        self.fileName = [dict objectForKey:@"fileName" withDefaultValue:SCDictionaryDefaultString];
        self.uploadType = ((NSNumber*)[dict objectForKey:@"uploadType" withDefaultValue:SCDictionaryDefaultInt]).intValue;
        self.uploadStatus = ((NSNumber*)[dict objectForKey:@"uploadStatus" withDefaultValue:SCDictionaryDefaultInt]).intValue;
    }
    return self;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.videoURL.path forKey:@"videoURL"];
    [dict setObject:self.fileName forKey:@"fileName"];
    [dict setObject:[NSNumber numberWithInt:self.uploadType] forKey:@"uploadType"];
    [dict setObject:[NSNumber numberWithInt:self.uploadStatus] forKey:@"uploadStatus"];
    
    return dict;
}

#pragma mark - UPLOAD
#pragma mark - Upload videos to Youtube

- (void)youtubeUploadVideo {
    
}


- (void)upload {
    
    // init status
    self.uploadStatus = SCUploadStatusUploading;
    [self.delegate onUpdateUploadStatus:SCUploadStatusUploading];
    
    // Collect the metadata for the upload from the user interface.
    
    // Status.
   /* GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus object];
    //    status.privacyStatus = [_uploadPrivacyPopup titleOfSelectedItem];
    
    // Snippet.
    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
    snippet.title = self.fileName;
    NSString *desc = @"Video Description";
    if ([desc length] > 0) {
        snippet.descriptionProperty = desc;
    }
    
    NSString *tagsStr = @"videorize,video,slideshow";
    if ([tagsStr length] > 0) {
        snippet.tags = [tagsStr componentsSeparatedByString:@","];
    }
    //    if ([_uploadCategoryPopup isEnabled]) {
    //        NSMenuItem *selectedCategory = [_uploadCategoryPopup selectedItem];
    //        snippet.categoryId = [selectedCategory representedObject];
    //    }
    
    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
    video.status = status;
    video.snippet = snippet;
    
    [self uploadVideoWithVideoObject:video
             resumeUploadLocationURL:nil];*/
}



- (void)restartUpload {
    // Restart a stopped upload, using the location URL from the previous
    // upload attempt
    if (_uploadLocationURL == nil) return;
    
    // Since we are restarting an upload, we do not need to add metadata to the
    // video object.
  /*  GTLYouTubeVideo *video = [GTLYouTubeVideo object];
    
    @try {
        [self uploadVideoWithVideoObject:video
                 resumeUploadLocationURL:_uploadLocationURL];
    }
    @catch (NSException *exception) {
        [Crittercism logHandledException:exception];
        self.uploadStatus = SCUploadStatusFailed;
        [self.delegate onUpdateUploadStatus:SCUploadStatusFailed];
    }
    @finally {
        
    }*/
    
}

/*- (void)uploadVideoWithVideoObject:(GTLYouTubeVideo *)video
           resumeUploadLocationURL:(NSURL *)locationURL {
    
    // Get a file handle for the upload data.
    NSString *path = self.videoURL.path;  //[SCFileManager URLFromBundleWithName:@"Project Title.mov"].path;
    NSString *filename = [path lastPathComponent];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (fileHandle) {
        
        NSString *mimeType = [self MIMETypeForFilename:filename
                                       defaultMIMEType:@"video/quicktime"];
        GTLUploadParameters *uploadParameters =
        [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
                                                   MIMEType:mimeType];
        
        uploadParameters.uploadLocationURL = locationURL;
        
        GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video
                                                                            part:@"snippet,status"
                                                                uploadParameters:uploadParameters];
        
        GTLServiceYouTube *service = [SCSocialManager getInstance].youtubeManager.youTubeService;
        _uploadFileTicket = [service executeQuery:query
                                completionHandler:^(GTLServiceTicket *ticket,
                                                    GTLYouTubeVideo *uploadedVideo,
                                                    NSError *error) {
                                    @try {
                                        // Callback
                                        _uploadFileTicket = nil;
                                        if (error == nil) {
                                            
                                            NSLog(@"OK 1");
                                            self.uploadStatus = SCUploadStatusUploaded;
                                            self.uploadProgress = 100;
                                            [self.delegate onUpdateUploadStatus:SCUploadStatusUploaded];
                                        } else {
                                            
                                            NSLog(@"Error 1");
                                            self.uploadStatus = SCUploadStatusFailed;
                                            [self.delegate onUpdateUploadStatus:SCUploadStatusFailed];
                                        }
                                        
                                        _uploadLocationURL = nil;
                                    }
                                    @catch (NSException *exception) {
                                        NSLog(@"CATCHED 2: Assertion failure in -[GTMHTTPUploadFetcher connectionDidFinishLoading:], GTMHTTPUploadFetcher.m:399");
                                    }
                                    @finally {
                                        
                                    }
                                    
                                    
                                }];
        
         __weak typeof(self) weakSelf = self;
        _uploadFileTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
                                                  unsigned long long numberOfBytesRead,
                                                  unsigned long long dataLength) {
            @try {
                double progressPercent = ((double)numberOfBytesRead / (double)dataLength) * 100;
                NSLog(@"%f %%", progressPercent);
                weakSelf.uploadProgress = progressPercent;
                [weakSelf.delegate onUpdateUploadProgress:weakSelf.uploadProgress];
                
                if (progressPercent >= 100) {
                    weakSelf.uploadStatus = SCUploadStatusUploaded;
                    weakSelf.uploadProgress = 100;
                    [weakSelf.delegate onUpdateUploadStatus:SCUploadStatusUploaded];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"CATCHED 1: Assertion failure in -[GTMHTTPUploadFetcher connectionDidFinishLoading:], GTMHTTPUploadFetcher.m:399");
            }
            @finally {
                
            }
            
            
        };
        
        // To allow restarting after stopping, we need to track the upload location
        // URL.
        //
        // For compatibility with systems that do not support Objective-C blocks
        // (iOS 3 and Mac OS X 10.5), the location URL may also be obtained in the
        // progress callback as ((GTMHTTPUploadFetcher *)[ticket objectFetcher]).locationURL
        
        GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[_uploadFileTicket objectFetcher];
        uploadFetcher.locationChangeBlock = ^(NSURL *url) {
            @try {
                _uploadLocationURL = url;
            }
            @catch (NSException *exception) {
                NSLog(@"CATCHED 3: Assertion failure in -[GTMHTTPUploadFetcher connectionDidFinishLoading:], GTMHTTPUploadFetcher.m:399");
            }
            @finally {
                
            }
            
        };
        
    } else {
        // Could not read file data.
        NSLog(@"File Not Found %@", path);
        self.uploadStatus = SCUploadStatusFailed;
    }
}
*/
- (NSString *)MIMETypeForFilename:(NSString *)filename
                  defaultMIMEType:(NSString *)defaultType {
    NSString *result = defaultType;
    NSString *extension = [filename pathExtension];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension, NULL);
    if (uti) {
        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        if (cfMIMEType) {
            result = CFBridgingRelease(cfMIMEType);
        }
        CFRelease(uti);
    }
    return result;
}

#pragma mark - Facebook Upload
- (void)facebookUpload {
    
   /* // init status
    self.uploadStatus = SCUploadStatusUploading;
    [self.delegate onUpdateUploadStatus:SCUploadStatusUploading];
    
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    NSString *fbFilename = [videoURL.path lastPathComponent];
    
    self.currentTotalBytes = [videoData length];
    float needTime = self.currentTotalBytes / (SC_CONNECTION_RATE * 1024);
    float fTimeRate = needTime/0.1;
    float percent95ProgressBar = SC_UPLOAD_BAR_PROGRESS_WIDTH / 100 * 95;
    self.fSegmentProgress = percent95ProgressBar / fTimeRate;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:videoData forKey:fbFilename];
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/videos" parameters:parameters HTTPMethod:@"POST"];

    //[SVProgressHUD showWithStatus:@"uploading..."];
    
    [self startConnectionRateWithBytes];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
      //  [SVProgressHUD dismiss];
        NSLog(@"result: %@, error: %@", result, error);
        
        [self endConnectionRate];

        if (error == nil) {
            self.uploadStatus = SCUploadStatusUploaded;
            [self.delegate onUpdateUploadProgressWithSegment:SC_UPLOAD_BAR_PROGRESS_WIDTH];
            [self.delegate onUpdateUploadStatus:SCUploadStatusUploaded];
        } else {
            self.uploadStatus = SCUploadStatusFailed;
            [self.delegate onUpdateUploadStatus:SCUploadStatusFailed];
        }
        
    }];*/
}

#pragma mark - Connection Rate Timer
- (void)startConnectionRateWithBytes {
    if (!self.connectionRateTimer.isValid) {
        self.connectionRateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                    target:self
                                                                  selector:@selector(connectionRateTimerTick:)
                                                                  userInfo:nil
                                                                   repeats:YES];
    }
}

- (void)endConnectionRate {
    if(self.connectionRateTimer.isValid)
    {
        [self.connectionRateTimer invalidate];
        self.connectionRateTimer = nil;
    }
}

- (void)connectionRateTimerTick:(NSTimer*)dt {
    self.currentProgressSegmentUpdated += fSegmentProgress;
    if (self.currentProgressSegmentUpdated > (SC_UPLOAD_BAR_PROGRESS_WIDTH /100*95)) {
        self.currentProgressSegmentUpdated = SC_UPLOAD_BAR_PROGRESS_WIDTH /100*95;
    }
    [self.delegate onUpdateUploadProgressWithSegment:self.currentProgressSegmentUpdated];
}

#pragma mark - Vine Upload
- (void)vineUpload {
    
    // init status
    self.uploadStatus = SCUploadStatusUploading;
    [self.delegate onUpdateUploadStatus:SCUploadStatusUploading];
    self.vineOutputURL = self.videoURL;
    if ([SCFileManager exist:self.videoURL] && self.vineOutputURL) {
        [self convertVideoToVine];
    }

}

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
    [request setValue:[SCSocialManager getInstance].vineManager.vineSessionID forHTTPHeaderField:@"vine-session-id"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"iphone/1.3.1 (iPad; iOS 6.1.3; Scale/1.00)" forHTTPHeaderField:@"User-Agent"];
    NSString *strParams = [NSString stringWithFormat:@"{\"videoUrl\":\"%@\",\"thumbnailUrl\":\"%@\",\"description\":\"%@\",\"entities\":[]}", self.vineUploadVideoURL, self.vineUploadThumbnailURL, @""];
    NSData *dataBody = [strParams dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataBody length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody:dataBody];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id payload = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dict = (NSDictionary*)payload;
        NSString *postId = [[dict objectForKey:@"data" withDefaultValue:SCDictionaryDefaultObject] objectForKey:@"postId" withDefaultValue:SCDictionaryDefaultString];
        
        [self vineUploadValidateID:postId];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.delegate onUpdateUploadStatus:SCUploadStatusFailed];
    }];
    [operation start];
}

- (void)vineUploadValidateID:(NSString*)vineID {
    //1019894339884769280
    NSString *validateString = [NSString stringWithFormat:@"https://api.vineapp.com/timelines/posts/%@", vineID];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.vineapp.com/"]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:validateString parameters:nil];
    
    //check request timeout
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json)
                                         {
                                             self.uploadStatus = SCUploadStatusUploaded;
                                             [self.delegate onUpdateUploadProgress:100];
                                             [self.delegate onUpdateUploadStatus:SCUploadStatusUploaded];
                                         }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError *error, NSString *json)
                                         {
                                             [self.delegate onUpdateUploadStatus:SCUploadStatusFailed];
                                         }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
    
    
    /*
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.vineapp.com/"]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:validateString
                                                      parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
     */
}

- (void)convertVideoToVine {
    
    /*NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:self.vineOutputURL fileType:AVFileTypeMPEG4 error:&error];
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
    
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
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
    /*if ([[avAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
        audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
        audioReader = [AVAssetReader assetReaderWithAsset:avAsset error:nil];
        audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        [audioReader addOutput:audioReaderOutput];
        
        [videoWriter addInput:audioWriterInput];
    }*/
    
   /* dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        
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
            
            self.vineThumbnailImage = [[self imageThumbnailFromURL:self.vineOutputURL] imageByScalingAndCroppingForSize:CGSizeMake(480, 480)];
            //self.vineOutputURL = toURL;
            [self putVideoFile];
            
        });
    });*/
    
    self.vineThumbnailImage = [[self imageThumbnailFromURL:self.vineOutputURL] imageByScalingAndCroppingForSize:CGSizeMake(480, 480)];
    //self.vineOutputURL = toURL;
    [self putVideoFile];

    
}

- (void) putVideoFile {
    
    NSData *videoData = [NSData dataWithContentsOfFile:self.vineOutputURL.path];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://media.vineapp.com/upload/videos/1.3.1.mp4"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
                                                            path:@"https://media.vineapp.com/upload/videos/1.3.1.mp4"
                                                      parameters:nil];
    
    [request setValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ios/1.3.1" forHTTPHeaderField:@"X-Vine-Client"];
    [request setValue:@"en;q=1, fr;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:[SCSocialManager getInstance].vineManager.vineSessionID forHTTPHeaderField:@"vine-session-id"];
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
        self.vineUploadVideoURL = [dict objectForKey:@"X-Upload-Key"];
        
        NSLog(@"upload video ok: %@", self.vineUploadVideoURL);
        
        [self putThumbnailFile];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.delegate onUpdateUploadStatus:SCUploadStatusFailed];
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
        
        double progressPercent = ((double)totalBytesWritten / (double)totalBytesExpectedToWrite) * 100;
        NSLog(@"%f %%", progressPercent);
        self.uploadProgress = progressPercent;
        
        if (self.uploadProgress > 95) {
            self.uploadProgress = 95;
        }
        
        [self.delegate onUpdateUploadProgress:self.uploadProgress];
    }];
    
    [operation start];
}

- (void) putThumbnailFile{
    
    NSData *data = UIImageJPEGRepresentation(self.vineThumbnailImage, 1);
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://media.vineapp.com/upload/thumbs/1.3.1.mp4.jpg"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT"
                                                            path:@"https://media.vineapp.com/upload/thumbs/1.3.1.mp4.jpg"
                                                      parameters:nil];
    
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ios/1.3.1" forHTTPHeaderField:@"X-Vine-Client"];
    [request setValue:@"en;q=1, fr;q=0.9, de;q=0.8, ja;q=0.7, nl;q=0.6, it;q=0.5" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:[SCSocialManager getInstance].vineManager.vineSessionID forHTTPHeaderField:@"vine-session-id"];
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
        self.vineUploadThumbnailURL = [dict objectForKey:@"X-Upload-Key"];
        
        [self uploadToVine];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.delegate onUpdateUploadStatus:SCUploadStatusFailed];
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


@end
