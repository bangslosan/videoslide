//
//  SCInstagramManager.m
//  SlideshowCreator
//
//  Created 11/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCInstagramManager.h"

@implementation SCInstagramManager
@synthesize instagramPhotoArray = _instagramPhotoArray;
@synthesize selectedInstagramPhotoArray = _selectedInstagramPhotoArray;
@synthesize nextMaxIDPaging = _nextMaxIDPaging;
@synthesize instagramAuthenticateViewController = _instagramAuthenticateViewController;
@synthesize instagramUserModel = _instagramUserModel;
@synthesize currentRequest = _currentRequest;
@synthesize loginFor = _loginFor;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.instagramPhotoArray = [[NSMutableArray alloc] init];
        self.selectedInstagramPhotoArray = [[NSMutableArray alloc] init];
        self.nextMaxIDPaging = nil;
        self.instagramUserModel = [[SCInstagramUserModel alloc] init];
        self.currentRequest = @"";
    }
    return self;
}

#pragma mark - Instagram: Authenticate
- (void)instagramLogIn {
    
    [[SCScreenManager getInstance].rootViewController presentScreen:SCEnumInstagramAuthenticateScreen data:nil];
    
    self.instagramAuthenticateViewController = (SCInstagramAuthenticateViewController*)[SCScreenManager getInstance].rootViewController.currentPresentVC;
    self.instagramAuthenticateViewController.delegate = self;

}

- (void)instagramLogOut {
    
    [NRGramKit logout];
    
    [self.instagramUserModel clear];
    
    [self.instagramPhotoArray removeAllObjects];
    [self.selectedInstagramPhotoArray removeAllObjects];
    
    self.nextMaxIDPaging = nil;
    
    [self sendNotification:SCNotificationInstagramDidLogOut];
    
}

- (BOOL)isInstagramLoggedIn {
    return [NRGramKit isLoggedIn];
}

- (void)dismissAuthenticatedInstagram {
    
    if ([self.loginFor isEqualToString:SCNotificationInstagramDidLogInAlbumList]) {
        [self sendNotification:SCNotificationInstagramDidLogInAlbumList];
    } else {
        [self sendNotification:SCNotificationInstagramDidLogIn];
    }
    
    self.loginFor = @"";
    
    [self requestInstagramPhotoInBackground];
}

- (void)requestInstagramPhotoInBackground {
    
    self.currentRequest = SCInstagramRequestPhoto;
    
    [self.instagramPhotoArray removeAllObjects];
    
    [NRGramKit getMediaRecentInUserWithId:[NRGramKit loggedInUser].Id
                                    count:28
                                    minId:nil
                                    maxId:nil
                             minTimestamp:nil
                             maxTimestamp:nil
                             withCallback:^(NSArray *array, IGPagination *pagination) {
                                 
                                 for (IGMedia *igMedia in array) {
                                     SCInstagramImage *image = [[SCInstagramImage alloc] init];
                                     image.thumbnailURL = igMedia.image.thumbnail;
                                     image.standardURL  = igMedia.image.standard_resolution;
                                     [self.instagramPhotoArray addObject:image];
                                 }
                         
                                 self.nextMaxIDPaging = pagination.nextMaxId;
                                 
                                 [self populateSelectedArray];
                         
                                 self.currentRequest = @"";
                                 [self sendNotification:SCNotificationInstagramDidLoadPhoto];

                             }];
}

- (void)requestMoreInstagramPhoto {
    
    if ((self.nextMaxIDPaging == nil) || ([self.nextMaxIDPaging isEqualToString:@""])) {
        
        self.currentRequest = @"";
        
        //[self sendNotification:SCNotificationInstagramDidFailedLoadMorePhoto];
        
        [self sendNotification:SCNotificationInstagramDidLoadMorePhotoFailed];
        
        return;
    }
    
    self.currentRequest = SCInstagramRequestMorePhoto;
    
    [NRGramKit getMediaRecentInUserWithId:[NRGramKit loggedInUser].Id
                                    count:28
                                    minId:nil
                                    maxId:self.nextMaxIDPaging
                             minTimestamp:nil
                             maxTimestamp:nil
                             withCallback:^(NSArray *array, IGPagination *pagination) {
                                 
                                 for (IGMedia *igMedia in array) {
                                     SCInstagramImage *image = [[SCInstagramImage alloc] init];
                                     image.thumbnailURL = igMedia.image.thumbnail;
                                     image.standardURL  = igMedia.image.standard_resolution;
                                     [self.instagramPhotoArray addObject:image];
                                 }
                                 
                                 self.nextMaxIDPaging = pagination.nextMaxId;
                                 
                                 [self populateSelectedArray];
                                 
                                 self.currentRequest = @"";
                                 [self sendNotification:SCNotificationInstagramDidLoadMorePhoto];
                                 
                             }];
}

- (NSString*)instagramUsername {
    if ([self isInstagramLoggedIn]) {
        return ((IGUser*)[NRGramKit loggedInUser]).username;
    } else {
        return @"";
    }
}

- (NSString*)instagramMediaCount {
    if ([self isInstagramLoggedIn]) {
        return [NSString stringWithFormat:@"%d", [((IGUser*)[NRGramKit loggedInUser]).media_count integerValue]];
    } else {
        return @"0";
    }
}

- (NSString*)instagramAvatar {
    if ([self isInstagramLoggedIn]) {
        return ((IGUser*)[NRGramKit loggedInUser]).profile_picture;
    } else {
        return @"icon_instagram_large.png";
    }
}

- (void)populateSelectedArray {
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.instagramPhotoArray count]];
    for (int i=0; i < [self.instagramPhotoArray count]; i++) {
        if ((self.selectedInstagramPhotoArray.count > 0) && (i < self.selectedInstagramPhotoArray.count)) {
            NSNumber *selected = [self.selectedInstagramPhotoArray objectAtIndex:i];
            if ([selected boolValue]) {
                [array addObject:[NSNumber numberWithBool:YES]];
            } else {
                [array addObject:[NSNumber numberWithBool:NO]];
            }
        } else {
            [array addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [self.selectedInstagramPhotoArray removeAllObjects];
    self.selectedInstagramPhotoArray = array;
}

- (void)resetSelectedArray {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.instagramPhotoArray count]];
    for (int i=0; i < [self.instagramPhotoArray count]; i++) {
        [array addObject:[NSNumber numberWithBool:NO]];
    }
    [self.selectedInstagramPhotoArray removeAllObjects];
    self.selectedInstagramPhotoArray = array;
}

@end
