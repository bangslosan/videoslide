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

- (void)upload {
    
    // init status
    self.uploadStatus = SCUploadStatusUploading;
    [self.delegate onUpdateUploadStatus:SCUploadStatusUploading];
}



- (void)restartUpload {
    // Restart a stopped upload, using the location URL from the previous
    // upload attempt
    if (_uploadLocationURL == nil) return;
}

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
- (void)sartUploadCurrentVideo
{
    // init status
    self.uploadStatus = SCUploadStatusUploading;
    [self.delegate onUpdateUploadStatus:SCUploadStatusUploading];
    self.vineOutputURL = self.videoURL;
    if ([SCFileManager exist:self.videoURL] && self.vineOutputURL)
    {
        self.vineThumbnailImage = [[self imageThumbnailFromURL:self.vineOutputURL] imageByScalingAndCroppingForSize:CGSizeMake(480, 480)];
        //self.vineOutputURL = toURL;
        [self UploadVideoToServer];
    }

}

#pragma mark - Create a Post

- (void)uploadPostToVine {
    
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
}

- (void) UploadVideoToServer {
    
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
        
        [self uploadPostThumbnail];
        
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

- (void) uploadPostThumbnail{
    
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
        
        [self uploadPostToVine];
        
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
