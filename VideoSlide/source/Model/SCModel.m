//
//  SCModel.m
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCModel.h"
#import <objc/runtime.h>


@interface SCModel ()

- (id)updateWithDictionary:(NSDictionary*)dict;

@end

@implementation SCModel

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self == nil)
        return self;
    
    return [self updateWithDictionary:dict];
}

- (id)updateWithDictionary:(NSDictionary*)dict
{
    
    //List of ivars
    unsigned int outCount;
    id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
    Ivar *ivars = class_copyIvarList(class, &outCount);
    
    //For each top-level property in the dictionary
    NSEnumerator *enumerator = [dict keyEnumerator];
    id dictKey;
    while ((dictKey = [enumerator nextObject]))
    {
        id dictValue = [dict objectForKey:dictKey];
        
        //Special case for "id" property
        if ([dictKey isEqualToString:@"id"])
            dictKey = @"ID";
        
        //If it match our ivar name, then set it
        for (unsigned int i = 0; i < outCount; i++)
        {
            Ivar ivar = ivars[i];
            NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
            NSString *ivarNameTrim = [ivarName substringFromIndex:1];
            NSString *ivarType = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
            
            if ([dictKey isEqualToString:ivarNameTrim] == NO)
                continue;
            
            //            //Empty value
            //            NSLog(@"*************************************************************");
            //            NSLog(@"dict key %@", dictKey);
            //            NSLog(@"Var name %@", ivarNameTrim);
            //            NSLog(@"Var type %@", ivarType);
            //            NSLog(@"*************************************************************");
            
            if ([dictValue isKindOfClass:[NSNull class]] ||
                ([dictValue isKindOfClass:[NSString class]] && [dictValue isEqualToString:@"null"]))
            {
                continue;
            }
            
            if([ivarType isEqualToString:@"f"] ||
               [ivarType isEqualToString:@"@\"NSString\""] ||
               [ivarType isEqualToString:@"c"] ||
               [ivarType isEqualToString:@"i"]||
               [ivarType isEqualToString:@"NSDate"] )
            {
                [self setValue:dictValue forKey:ivarName];
            }
        }
    }
    
    free(ivars);
    return self;
}

- (NSMutableDictionary*)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    //List of ivars
    unsigned int outCount;
    id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
    Ivar *ivars = class_copyIvarList(class, &outCount);
    
    //If it match our ivar name, then set it
    for (unsigned int i = 0; i < outCount; i++)
    {
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        NSString *ivarNameTrim = [ivarName substringFromIndex:1];
        NSString *ivarType = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
        
        NSLog(@"Var name %@", ivarNameTrim);
        NSLog(@"Var type %@", ivarType);
        
        //type float
        if([ivarType isEqualToString:@"f"] || [ivarType hasPrefix:@"@\"NSString\""] || [ivarType isEqualToString:@"c"]  || [ivarType isEqualToString:@"i"] || [ivarType isEqualToString:@"NSDate"])
        {
            //            NSLog(@"Float");
            [dict setValue:[self valueForKey:ivarNameTrim] forKey:ivarNameTrim];
        }
        else
        {
            //other
        }
        
    }
    
    return  dict;
}


- (void)clearAll
{
    
}



@end