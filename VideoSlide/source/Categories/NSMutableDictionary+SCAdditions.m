//
//  NSMutableDictionary+SCAdditions.m
//  SlideshowCreator
//
//  Created 10/28/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "NSMutableDictionary+SCAdditions.h"

@implementation NSMutableDictionary (SCAdditions)


- (void)setValue:(id)value forkey:(NSString*)key withDefaultValue:(SCDictionaryDefault)defaultValue
{
    if(value)
    {
        [self setValue:value forKey:key];
    }
    else
    {
        switch (defaultValue) {
            case SCDictionaryDefaultArray:
                [self setValue:[NSArray array] forKey:key];
                break;
            case SCDictionaryDefaultString:
                [self setValue:@"" forKey:key];
                break;
            case SCDictionaryDefaultObject:
                [self setValue:[NSDictionary dictionary] forKey:key];
                break;
                
            default:
                break;
        }
    }
}

- (void)setObject:(NSObject*)object forkey:(NSString*)key withDefaultValue:(SCDictionaryDefault)defaultValue
{
    if(object)
    {
        
        [self setObject:object forKey:key];
    }
    else
    {
        switch (defaultValue)
        {
            case SCDictionaryDefaultArray:
                [self setObject:[NSArray array] forKey:key];
                break;
            case SCDictionaryDefaultString:
                [self setObject:@"" forKey:key];
                break;
            case SCDictionaryDefaultObject:
                [self setObject:[NSDictionary dictionary] forKey:key];
                break;
                
            default:
                break;
        }
    }
    

}




@end
