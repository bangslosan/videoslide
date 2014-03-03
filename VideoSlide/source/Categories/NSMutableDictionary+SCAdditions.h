//
//  NSMutableDictionary+SCAdditions.h
//  SlideshowCreator
//
//  Created 10/28/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+SCAdditions.h"

@interface NSMutableDictionary (SCAdditions)

- (void)setValue:(id)value forkey:(NSString*)key withDefaultValue:(SCDictionaryDefault)defaultValue;
- (void)setObject:(NSObject*)object forkey:(NSString*)key withDefaultValue:(SCDictionaryDefault)defaultValue;


@end
