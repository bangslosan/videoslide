//
//  SCInstagramUserModel.m
//  SlideshowCreator
//
//  Created 10/22/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCInstagramUserModel.h"

@implementation SCInstagramUserModel
@synthesize username = _username;
@synthesize numOfMedia = _numOfMedia;

- (id)init {
    self = [super init];
    if (self) {
        self.username = @"";
        self.numOfMedia = 0;
    }
    return self;
}

- (id)initWithUsername:(NSString*)username numOfMedia:(int)numOfMedia {
    self = [super init];
    if (self) {
        self.username = username;
        self.numOfMedia = numOfMedia;
    }
    return self;
}

- (void)parseDataWithUsername:(NSString*)username numOfMedia:(int)numOfMedia {
    self.username = username;
    self.numOfMedia = numOfMedia;
}

- (void)clear {
    self.username = @"";
    self.numOfMedia = 0;
}

@end
