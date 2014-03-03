//
//  SCInstagramUserModel.h
//  SlideshowCreator
//
//  Created 10/22/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCInstagramUserModel : SCModel

@property (nonatomic, strong) NSString  *username;
@property (nonatomic, assign) int       numOfMedia;

- (id)init;
- (id)initWithUsername:(NSString*)username numOfMedia:(int)numOfMedia;
- (void)parseDataWithUsername:(NSString*)username numOfMedia:(int)numOfMedia;
- (void)clear;

@end
