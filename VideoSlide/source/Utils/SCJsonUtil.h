//
//  SCJsonUtil.h
//  SlideshowCreator
//
//  Created 9/9/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCJsonUtil : NSObject

+ (NSDictionary*)dictionaryFromJsonFileInBundle:(NSString*)filename;
+ (NSDictionary*)dictionaryFromJsonFileInDocument:(NSString*)fileName;
+ (void)writeDictToJsonFile:(NSDictionary*)data fileName:(NSString*)fileName;


@end
