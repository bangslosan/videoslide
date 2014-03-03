//
//  NSMutableDictionary+SCAdditions.m
//  SlideshowCreator
//
//  Created 10/28/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "NSDictionary+SCAdditions.h"

@implementation NSDictionary (SCAdditions)


- (int)integerForKey:(NSString*)key
{
    int value = 0;
    if([[self objectForKey:key] isKindOfClass:[NSNumber class]])
    {
        value = ((NSNumber*)([self valueForKey:key])).intValue;
    }
    
    return value;
}

- (float)floatForKey:(NSString*)key
{
    float value = 0;
    if([[self objectForKey:key] isKindOfClass:[NSNumber class]])
    {
        value = ((NSNumber*)([self valueForKey:key])).floatValue;
    }
    
    return value;
}

- (BOOL)boolForKey:(NSString*)key
{
    BOOL value = NO;
    if([[self objectForKey:key] isKindOfClass:[NSNumber class]])
    {
        value = ((NSNumber*)([self valueForKey:key])).boolValue;
    }
    
    return value;
}


#pragma mark - get
- (id)valueForKey:(NSString*)key withDefaultValue:(SCDictionaryDefault)defaultKey
{
    if(![self valueForKey:key] || [[self valueForKey:key] isKindOfClass:[NSNull class]])
    {
        if(defaultKey == SCDictionaryDefaultString)
            return @"";
        else if(defaultKey == SCDictionaryDefaultArray)
            return [NSArray array];
        else if(defaultKey == SCDictionaryDefaultObject)
            return [NSDictionary dictionary];
        
    }
    
    return [self valueForKey:key];
    
}

- (id)objectForKey:(NSString*)key withDefaultValue:(SCDictionaryDefault)defaultKey
{
    if(![self objectForKey:key] || [[self objectForKey:key] isKindOfClass:[NSNull class]])
    {
        if(defaultKey == SCDictionaryDefaultString)
            return @"";
        else if(defaultKey == SCDictionaryDefaultArray)
            return [NSArray array];
        else if(defaultKey == SCDictionaryDefaultObject)
            return [NSDictionary dictionary];
    }
    
    return [self objectForKey:key];
}

@end