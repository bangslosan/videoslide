//
//  NSMutableDictionary+SCAdditions.h
//  SlideshowCreator
//
//  Created 10/28/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    SCDictionaryDefaultString,
    SCDictionaryDefaultArray,
    SCDictionaryDefaultObject,
    SCDictionaryDefaultInt,
    SCDictionaryDefaultFloat
    
} SCDictionaryDefault;



@interface NSDictionary (SCAdditions)


- (int)integerForKey:(NSString*)key;
- (float)floatForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;

- (id)valueForKey:(NSString*)key withDefaultValue:(SCDictionaryDefault)defaultKey;
- (id)objectForKey:(NSString*)key withDefaultValue:(SCDictionaryDefault)defaultKey;

@end
