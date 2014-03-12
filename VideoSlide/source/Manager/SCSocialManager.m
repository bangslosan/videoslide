//
//  SCSocialManager.m
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSocialManager.h"
//#import "GTMOAuth2ViewControllerTouch.h"



static SCSocialManager *instance;

@implementation SCSocialManager


@synthesize allUploadItems = _allUploadItems;
// manage num of share
@synthesize vineManager;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.vineManager = [[SCVineManager alloc] init];
        
        self.allUploadItems = [[NSMutableArray alloc] init];
        
        [self loadAllUploadItems];
    }
    return self;
}

+ (SCSocialManager*)getInstance
{
    @synchronized([SCSocialManager class])
    {
        if(!instance)
            instance = [[self alloc] init];
        return instance;
    }
    
    return nil;
}


#pragma mark - GOOGLE PLUS API
#pragma mark - Google Plus Authentication

- (void)test {
    
}

- (void)saveAllUploadItems {

    NSMutableArray *_uploadedItems = [[NSMutableArray alloc] init];
    for (SCUploadObject *object in _allUploadItems) {
        [_uploadedItems addObject:[object toDictionary]];
    }
    
    NSMutableDictionary *_uploadedDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_uploadedItems, @"allUploadItems", nil];
    NSURL *url = [SCFileManager URLFromLibraryWithName:SC_UPLOAD_FILE_NAME];
    
    if ([SCFileManager exist:url]) {
        [SCFileManager deleteFileWithURL:url];
    }
    
    [_uploadedDict writeToURL:url atomically:YES];
}

- (void)loadAllUploadItems {
    
    NSMutableDictionary *_uploadedDict;
    NSURL *url = [SCFileManager URLFromLibraryWithName:SC_UPLOAD_FILE_NAME];
    
    if ([SCFileManager exist:url]) {
        _uploadedDict = [[NSMutableDictionary alloc] initWithContentsOfFile:url.path];
        NSMutableArray *_uploadedArray = [_uploadedDict objectForKey:@"allUploadItems"];
        for (NSDictionary *dict in _uploadedArray) {
            
            SCUploadObject *object = [[SCUploadObject alloc] initWithDictionary:dict];
            
            // when read from files, if status is Uploading -> Failed;
            if ((object.uploadStatus == SCUploadStatusUploading) || (object.uploadStatus == SCUploadStatusUnknown)) {
                object.uploadStatus = SCUploadStatusFailed;
            }
            
             if (object.uploadType == SCUploadTypeVine) {
                [self.vineManager.uploadArray addObject:object];
            }
        }
    }
}

#pragma mark - Get/Set Uploads
- (NSMutableArray*)allUploadItems {
    
    if (_allUploadItems.count > 0) {
        [_allUploadItems removeAllObjects];
    }
    
    _allUploadItems = nil;
    _allUploadItems = [[NSMutableArray alloc] init];
    for (SCUploadObject *object in self.vineManager.uploadArray) {
        [_allUploadItems addObject:object];
    }
    //TODO: add facebook upload objects
    
    return _allUploadItems;
}


#pragma mark - Manage number of sharings
- (void)loadNumberOfSharing {
   // NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];}
}
- (void)saveNumberOfSharing {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault synchronize];
}

@end
