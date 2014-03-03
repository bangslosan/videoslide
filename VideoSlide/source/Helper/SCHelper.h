//
//  SCHelper.h
//  SlideshowCreator
//
//  Created 9/17/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHelper : NSObject

+ (UIColor*)colorFromSCColor:(SCColor)color;
+ (SCColor)colorFromUIcolor:(UIColor*)color;

+ (NSString*)mediaTimeFormatFrom:(float)duration;
+ (NSString*)getCurrentDateTimeInString;
+ (NSString*)dateStringFrom:(NSDate*)date;


+ (NSArray*)arrayFromVector:(SCVector)vector;
+ (SCVector)vectorFromArray:(NSArray*)array;

+ (NSArray*)arrayFromSize:(CGSize)size;
+ (CGSize)sizeFromArray:(NSArray*)array;

+ (NSArray*)arrayFromSCColor:(SCColor)color;
+ (SCColor)colorFromArray:(NSArray*)array;

+ (NSArray*)arrayFromSCSize:(SCSize)size;
+ (SCSize)SCSizeFromArray:(NSArray*)array;

+ (NSString *)MIMETypeForFilename:(NSString *)filename defaultMIMEType:(NSString *)defaultType;
+ (BOOL)isIOS7;

@end
