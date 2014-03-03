//
//  SCTextUtil.h
//  SlideshowCreator
//
//  Created 10/15/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCTextUtil : NSObject

+ (BOOL)isEmptyString:(NSString *)string;

+ (SCColor)colorPickerText:(ColorPickerText)color;

+ (CGFloat)heightWithText:(NSString *)textString size:(float)size font:(NSString*)fontName;

+ (CGFloat)widthWithText:(NSString *)textString size:(float)size font:(NSString*)fontName;

+ (CGSize)sizeWithText:(NSString *)textString size:(float)size font:(NSString*)fontName;

+ (CGFloat)heightWithAttributedText:(NSString *)attrString
                               size:(float)size
                               font:(NSString*)fontName
                        lineSpacing:(int)lineSpacing
                   characterSpacing:(int)characterSpacing;

+ (CGSize)sizeWithAttributedText:(NSString *)attrString
                            size:(float)size
                            font:(NSString*)fontName
                     lineSpacing:(int)lineSpacing
                characterSpacing:(int)characterSpacing;

+ (NSTextAlignment)textAlign:(SCTextAlignment)alignment;

@end
