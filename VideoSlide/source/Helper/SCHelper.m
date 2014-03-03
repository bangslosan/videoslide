//
//  SCHelper.m
//  SlideshowCreator
//
//  Created 9/17/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCHelper.h"

@implementation SCHelper

+ (UIColor *)colorFromSCColor:(SCColor)color
{
    UIColor *result;
    result = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:color.alpha];
    return result;
}

+ (SCColor)colorFromUIcolor:(UIColor*)color;
{
    SCColor result;
    CGColorRef cgColor = [color CGColor];
    int numComponents = CGColorGetNumberOfComponents(cgColor);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(cgColor);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        result = SCColorMake(red, green, blue, alpha);
    }
    
    return result;

}


#pragma mark - date tme to string

+ (NSString*)mediaTimeFormatFrom:(float)duration
{
    float seconds = duration;
	if (!isfinite(seconds))
    {
		seconds = 0;
	}
	int secondsInt = round(seconds);
	int minutes = secondsInt/60;
	secondsInt -= minutes*60;
	if(duration <= 0)
        return @"00:00";
	return [NSString stringWithFormat:@"%.2i:%.2i", minutes, secondsInt];
}


+ (NSString*)getCurrentDateTimeInString
{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    return dateString;
}

+ (NSString*)dateStringFrom:(NSDate*)date
{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    return dateString;
}

#pragma mark - SCSize
+ (NSArray*)arrayFromSCSize:(SCSize)size
{
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:size.width],[NSNumber numberWithFloat:size.height],nil];
}

+ (SCSize)SCSizeFromArray:(NSArray*)array
{
    SCSize size = SCSizeMake(0, 0);
    if(array.count == 2 )
    {
        size.width = ((NSNumber*)array[0]).floatValue;
        size.height = ((NSNumber*)array[1]).floatValue;
    }
    return size;
}


#pragma mark - SCVector
+ (NSArray*)arrayFromVector:(SCVector)vector
{
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:vector.x],[NSNumber numberWithFloat:vector.y],nil];
}

+ (SCVector)vectorFromArray:(NSArray*)array
{
    SCVector vector = SCVectorMake(0, 0);
    if(array.count == 2 )
    {
        vector.x = ((NSNumber*)array[0]).floatValue;
        vector.y = ((NSNumber*)array[1]).floatValue;
    }
    return vector;
}

#pragma mark - CGSize

+ (NSArray*)arrayFromSize:(CGSize)size
{
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:size.width],[NSNumber numberWithFloat:size.height],nil];

}

+ (CGSize)sizeFromArray:(NSArray*)array
{
    CGSize size = CGSizeMake(0, 0);
    if(array.count == 2 )
    {
        size.width = ((NSNumber*)array[0]).floatValue;
        size.height = ((NSNumber*)array[1]).floatValue;
    }
    return size;
}

#pragma mark - SCCOlor

+ (NSArray*)arrayFromSCColor:(SCColor)color
{
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:color.red],
                                     [NSNumber numberWithFloat:color.green],
                                     [NSNumber numberWithFloat:color.blue],
                                     [NSNumber numberWithFloat:color.alpha],nil];

}


+ (SCColor)colorFromArray:(NSArray*)array
{
    SCColor color = SCColorMake(0, 0, 0, 1);
    if(array.count >= 4)
    {
        color.red = ((NSNumber*)array[0]).floatValue;
        color.green = ((NSNumber*)array[1]).floatValue;
        color.blue = ((NSNumber*)array[2]).floatValue;
        color.alpha = ((NSNumber*)array[3]).floatValue;

    }
    return color;
}

#pragma mark - Get MIME Type of file
+ (NSString *)MIMETypeForFilename:(NSString *)filename
                  defaultMIMEType:(NSString *)defaultType {
    NSString *result = defaultType;
    NSString *extension = [filename pathExtension];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension, NULL);
    if (uti) {
        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        if (cfMIMEType) {
            result = CFBridgingRelease(cfMIMEType);
        }
        CFRelease(uti);
    }
    return result;
}

#pragma mark - Detect iOS 7
+ (BOOL)isIOS7 {
    NSString * v = [[[UIDevice currentDevice] systemVersion] substringWithRange:NSMakeRange(0, 1)];
    if ([v isEqualToString:@"7"]) {
        return YES;
    }
    
    return NO;
}

@end
