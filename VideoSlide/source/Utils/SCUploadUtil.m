//
//  SCUploadUtil.m
//  SlideshowCreator
//
//  Created 11/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCUploadUtil.h"

@implementation SCUploadUtil

+ (NSString*)uploadStatusString:(SCUploadStatus)status {
    switch (status) {
        case SCUploadStatusUnknown:
            return @"Unknown";
            break;
        case SCUploadStatusFailed:
            return @"Failured";
            break;
        case SCUploadStatusUploading:
            return @"Uploading";
            break;
        case SCUploadStatusUploaded:
            return @"Uploaded";
            break;
        default:
            return @"Unknown";
            break;
    }
}

+ (NSString*)imageUploadType:(SCUploadType)uploadType {
    switch (uploadType) {
        case SCUploadTypeFacebook:
            return @"icon_setting_facebook.png";
            break;
        case SCUploadTypeYoutube:
            return @"icon_setting_youtube.png";
            break;
        case SCUploadTypeVine:
            return @"icon_setting_vine.png";
            break;
        default:
            break;
    }
}

+ (NSString*)imageUploadStatus:(SCUploadStatus)uploadStatus {
    switch (uploadStatus) {
        case SCUploadStatusUnknown:
            return @"btn_projectdetail_retry.png";
            break;
        case SCUploadStatusFailed:
            return @"btn_projectdetail_retry.png";
            break;
        case SCUploadStatusUploading:
            return @"btn_projectdetail_unknown.png";
            break;
        case SCUploadStatusUploaded:
            return @"btn_checked.png";
            break;
        default:
            return @"btn_projectdetail_retry.png";
            break;
    }
}

+ (UIColor*)colorUploadStatus:(SCUploadStatus)uploadStatus {
    switch (uploadStatus) {
        case SCUploadStatusUnknown:
            return [UIColor redColor];
            break;
        case SCUploadStatusFailed:
            return [UIColor redColor];
            break;
        case SCUploadStatusUploading:
            return [UIColor lightGrayColor];
            break;
        case SCUploadStatusUploaded:
            return [UIColor lightGrayColor];
            break;
        default:
            return [UIColor redColor];
            break;
    }
}

+ (BOOL)isUploadDuplicated:(SCUploadObject*)uploadObject uploadType:(SCUploadType)uploadType {
    
    for (SCUploadObject *object in [SCSocialManager getInstance].allUploadItems) {
        
        if ([uploadObject.videoURL.path isEqualToString:object.videoURL.path] && (object.uploadType == uploadType))  {
            return YES;
        }
    }
    
    return NO;
}

@end