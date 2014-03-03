//
//  SCModel.h
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCModel : NSObject


- (id)initWithDictionary:(NSDictionary*)dict;
- (NSMutableDictionary*)toDictionary;

- (void)clearAll;
@end
